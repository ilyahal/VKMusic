//
//  PlaylistsViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

class PlaylistsViewController: UIViewController {
    
    private var selected = SelectedType.Playlists {
        didSet {
            if VKAPIManager.isAuthorized && selected == .Albums {
                pullToRefreshEnable(true)
                return
            }
            
            pullToRefreshEnable(false)
        }
    }
    
    var playlists: [Playlist] { // Массив для оффлайн плейлистов
        return DataManager.sharedInstance.playlistsFetchedResultsController.sections!.first!.objects as! [Playlist]
    }
    private var albums: [Album]! // Массив для альбомов ВК

    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAlbums), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    var pullToRefreshEnable = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.sharedInstance.addDataManagerPlaylistsDelegate(self)
        if VKAPIManager.isAuthorized {
            getAlbums()
        }
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        // Настройка навигационной панели, содержащей segmented control
        navigationBar.barTintColor = UIColor.whiteColor()
        navigationBar.tintColor = (UIApplication.sharedApplication().delegate! as! AppDelegate).tintColor
        
        // Настройка table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        tableView.contentInset = UIEdgeInsets(top: navigationBar.bounds.height, left: 0, bottom: 0, right: 0) // Верхний отступ для контента, что бы первая ячейка не скрывалась под навигационным баром
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.playlistCell, bundle: nil) // Ячейка с плейлистом
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.playlistCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.albumCell, bundle: nil) // Ячейка с альбомом
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.albumCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            if VKAPIManager.isAuthorized {
                if selected == .Albums {
                    pullToRefreshEnable(true)
                }
                
                getAlbums()
            } else {
                pullToRefreshEnable(false)
            }
            
            // Если открыта вкладка с альбомами ВК
            if selected == .Albums {
                reloadTableView()
            }
        }
        
        // Необходимо для корректного отображения Refresh Controller
        if pullToRefreshEnable {
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl.beginRefreshing()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    // Подготовка к выполнению перехода
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAlbumAudioSegue" {
            let albumMusicViewController = segue.destinationViewController as! AlbumMusicViewController
            let album = sender as! Album
            
            albumMusicViewController.album = album
        } else if segue.identifier == "ShowPlaylistAudioSegue" {
            let playlistMusicViewController = segue.destinationViewController as! PlaylistMusicViewController
            let playlist = sender as! Playlist
            
            playlistMusicViewController.playlist = playlist
        }
    }
    
    
    // MARK: Обработка пользовательских событий
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selected = .Playlists
        case 1:
            selected = .Albums
        default:
            return
        }
        
        reloadTableView()
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    // Кнопка +
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        switch selected {
        case .Playlists:
            performSegueWithIdentifier("ShowAddPlaylistViewControllerSegue", sender: nil)
        case .Albums:
            let alertController = UIAlertController(title: nil, message: "Добавление альбомов будет доступно позже..", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Выполнение запроса на получение альбомов ВК
    
    func getAlbums() {
        RequestManager.sharedInstance.getAlbums.performRequest() { success in
            self.albums = DataManager.sharedInstance.albums.array
            
            if self.selected == .Albums {
                self.reloadTableView()
            }
            
            if self.refreshControl.refreshing { // Если данные обновляются
                self.refreshControl.endRefreshing() // Говорим что обновление завершено
            }
            
            if !success {
                switch RequestManager.sharedInstance.getAlbums.error {
                case .UnknownError:
                    let alertController = UIAlertController(title: "Ошибка", message: "Произошла какая-то ошибка, попробуйте еще раз...", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: false, completion: nil)
                    }
                default:
                    break
                }
            }
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            if !pullToRefreshEnable {
                tableView.addSubview(self.refreshControl)
                pullToRefreshEnable = true
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl.beginRefreshing()
                    self.refreshControl.endRefreshing()
                }
            }
        } else {
            if pullToRefreshEnable {
                refreshControl.removeFromSuperview()
                pullToRefreshEnable = false
            }
        }
    }
    
    func refreshAlbums() {
        getAlbums()
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что нет плейлистов
    var textForNoPlaylistsRow: String {
        return "Нет плейлистов"
    }
    
    // Получение количества плейлистов в списке для ячейки с количеством плейлистов
    func getCountForCellForNumberOfPlaylistsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        if playlists.count == indexPath.row {
            return playlists.count
        } else {
            return nil
        }
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    var textForNoAuthorizedRow: String {
        return "Необходимо авторизоваться"
    }
    
    // Текст для ячейки с сообщением о том, что нет альбомов
    var textForNoAlbumsRow: String {
        return "Нет альбомов"
    }
    
    // Получение количества треков в списке для ячейки с количеством альбомов
    func getCountForCellForNumberOfAlbumsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        if albums.count == indexPath.row {
            return albums.count
        } else {
            return nil
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением что нет плейлистов
    func getCellForNoPlaylistsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoPlaylistsRow
        
        return cell
    }
    
    // Ячейка для строки с плейлистом
    func getCellForPlaylistRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let playlist = playlists[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.playlistCell, forIndexPath: indexPath) as! PlaylistCell
        cell.titleLabel.text = playlist.title
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством плейлистов
    func getCellForNumberOfPlaylistsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = getCountForCellForNumberOfPlaylistsRowInTableView(tableView, forIndexPath: indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Playlist, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки когда поиск еще не выполнялся и была получена ошибка при подключении к интернету
    func getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
        
        return cell
    }
    
    // Ячейка для строки когда поиск еще не выполнялся
    func getCellForNotSearchedYetRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // Ячейка для строки с сообщением что сервер вернул пустой массив
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoAlbumsRow
        
        return cell
    }
    
    // Ячейка для строки с сообщением о загрузке
    func getCellForLoadingRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством альбомов
    func getCellForNumberOfAlbumsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = getCountForCellForNumberOfAlbumsRowInTableView(tableView, forIndexPath: indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Album, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с альбомом
    func getCellForAlbumRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.albumCell, forIndexPath: indexPath) as! AlbumCell
        cell.titleLabel.text = album.title
        
        return cell
    }
    
    // Ячейка для строки с сообщением о необходимости авторизоваться
    func getCellForNoAuthorizedRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = textForNoAuthorizedRow
        
        return cell
    }

}


// MARK: Типы данных

private typealias PlaylistsViewControllerDataTypes = PlaylistsViewController
extension PlaylistsViewControllerDataTypes {

    // Выбранное состояние
    enum SelectedType {
        case Playlists // Локальные плейлисты
        case Albums // Альбомы ВК
    }
    
}


// MARK: UITableViewDataSource

extension PlaylistsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selected {
        case .Playlists:
            if playlists.count == 0 {
                return 1
            } else {
                return playlists.count + 1
            }
        case .Albums:
            if VKAPIManager.isAuthorized {
                switch RequestManager.sharedInstance.getAlbums.state {
                case .NotSearchedYet where RequestManager.sharedInstance.getAlbums.error == .NetworkError:
                    return 1 // Ячейка с сообщением об отсутствии интернет соединения
                case .NotSearchedYet:
                    return 0
                case .Loading:
                    if refreshControl.refreshing {
                        return albums.count + 1
                    }
                    
                    return 1 // Ячейка с индикатором загрузки
                case .NoResults:
                    return 1 // Ячейки с сообщением об отсутствии альбомов
                case .Results:
                    return albums.count + 1 // +1 - ячейка для вывода количества строк
                }
            }
            
            return 1 // Ячейка с сообщением о необходимости авторизоваться
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch selected {
        case .Playlists:
            if playlists.count == 0 {
                return getCellForNoPlaylistsRowInTableView(tableView, forIndexPath: indexPath)
            }
            
            if let numberOfRowsCell = getCellForNumberOfPlaylistsRowInTableView(tableView, forIndexPath: indexPath) {
                return numberOfRowsCell
            }
            
            return getCellForPlaylistRowInTableView(tableView, forIndexPath: indexPath)
        case .Albums:
            if VKAPIManager.isAuthorized {
                switch RequestManager.sharedInstance.getAlbums.state {
                case .NotSearchedYet where RequestManager.sharedInstance.getAlbums.error == .NetworkError:
                    return getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView, forIndexPath: indexPath)
                case .NotSearchedYet:
                    return getCellForNotSearchedYetRowInTableView(tableView, forIndexPath: indexPath)
                case .NoResults:
                    return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
                case .Loading:
                    if refreshControl.refreshing {
                        if albums.count == 0 {
                            return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
                        }
                        
                        if let numberOfRowsCell = getCellForNumberOfPlaylistsRowInTableView(tableView, forIndexPath: indexPath) {
                            return numberOfRowsCell
                        }
                            
                        return getCellForAlbumRowInTableView(tableView, forIndexPath: indexPath)
                    }
                    
                    return getCellForLoadingRowInTableView(tableView, forIndexPath: indexPath)
                case .Results:
                    if albums.count == 0 {
                        return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
                    }
                    
                    if let numberOfRowsCell = getCellForNumberOfAlbumsRowInTableView(tableView, forIndexPath: indexPath) {
                        return numberOfRowsCell
                    }
                    
                    return getCellForAlbumRowInTableView(tableView, forIndexPath: indexPath)
                }
            }
            
            return getCellForNoAuthorizedRowInTableView(tableView, forIndexPath: indexPath)
        }
    }
    
    // Возможно ли редактировать ячейку
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch selected {
        case .Playlists:
            if tableView.cellForRowAtIndexPath(indexPath) is PlaylistCell {
                return true
            }
        case .Albums:
            return false
        }
        
        return false
    }
    
    // Обработка удаления ячейки
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let playlist = playlists[indexPath.row]
            
            if !DataManager.sharedInstance.deletePlaylist(playlist) {
                let alertController = UIAlertController(title: "Ошибка", message: "При удалении плейлиста произошла ошибка, попробуйте еще раз..", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
}


// MARK: UITableViewDelegate

extension PlaylistsViewController: UITableViewDelegate {
    
    // Вызывается при тапе по строке таблицы
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch selected {
        case .Playlists:
            if tableView.cellForRowAtIndexPath(indexPath) is PlaylistCell {
                let playlist = playlists[indexPath.row]
                performSegueWithIdentifier("ShowPlaylistAudioSegue", sender: playlist)
            }
        case .Albums:
            if tableView.cellForRowAtIndexPath(indexPath) is AlbumCell {
                let album = albums[indexPath.row]
                performSegueWithIdentifier("ShowAlbumAudioSegue", sender: album)
            }
        }
    }
    
}


// MARK: DataManagerPlaylistsDelegate

extension PlaylistsViewController: DataManagerPlaylistsDelegate {
    
    // Контроллер начал изменять контент
    func dataManagerPlaylistsControllerWillChangeContent() {}
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerPlaylistsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер закончил изменять контент
    func dataManagerPlaylistsControllerDidChangeContent() {
        if selected == .Playlists {
            reloadTableView()
        }
    }
    
}