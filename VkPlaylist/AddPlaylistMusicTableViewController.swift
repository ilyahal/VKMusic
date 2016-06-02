//
//  AddPlaylistMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

/// Контроллер содержащий таблицу со списком аудиозаписей доступных для добавления в плейлист
class AddPlaylistMusicTableViewController: UITableViewController {

    weak var delegate: AddPlaylistMusicDelegate?
    
    /// Контроллер массива загруженных аудиозаписей
    var downloadsFetchedResultsController: NSFetchedResultsController {
        return DataManager.sharedInstance.downloadsFetchedResultsController
    }
    
    /// Массив уже загруженных аудиозаписей
    var downloaded: [TrackInPlaylist] { // Загруженные треки
        return downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist]
    }
    // Массив для результатов поиска по скаченным аудиозаписям
    var filteredTracks = [TrackInPlaylist]()
    
    /// Массив аудиозаписей отображаемый на экране
    var activeArray: [TrackInPlaylist] {
        if isSearched {
            return filteredTracks
        } else {
            return downloaded
        }
    }
    
    /// Массив уже выбранных треков
    var selectedTracks = [String : OfflineTrack]()
    
    /// Контроллер поиска
    let searchController = UISearchController(searchResultsController: nil)
    /// Выполняется ли сейчас поиск
    var isSearched: Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        definesPresentationContext = true
        
        searchEnable(downloaded.count != 0)
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = tableView.tableHeaderView {
            if tableView.contentOffset.y == 0 {
                tableView.hideSearchBar()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataManager.sharedInstance.addDataManagerDownloadsDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        DataManager.sharedInstance.deleteDataManagerDownloadsDelegate(self)
    }
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
    }

    /// Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Работа с клавиатурой
    
    /// Распознаватель тапов по экрану
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    /// Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Поиск
    
    /// Управление доступностью поиска
    func searchEnable(enable: Bool) {
        if enable {
            if tableView.tableHeaderView == nil {
                searchController.searchBar.alpha = 1
                tableView.tableHeaderView = searchController.searchBar
                tableView.hideSearchBar()
            }
        } else {
            if let _ = tableView.tableHeaderView {
                searchController.searchBar.alpha = 0
                searchController.active = false
                tableView.tableHeaderView = nil
                tableView.contentOffset = CGPointZero
            }
        }
    }
    
    /// Выполнение поиска
    func filterContentForSearchText(searchText: String) {
        filteredTracks = downloaded.filter { trackInPlaylist in
            let track = trackInPlaylist.track
            return track.title.lowercaseString.containsString(searchText.lowercaseString) || track.artist.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что загруженные аудиозаписи отсутствуют
    var noResultsLabelText: String {
        return "Нет загруженных треков"
    }
    
    // Получение количества аудиозаписей в списке для ячейки с количеством аудиозаписей
    func numberOfOfflineAudioForIndexPath(indexPath: NSIndexPath) -> Int? {
        if activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var nothingFoundLabelText: String {
        return "Измените поисковый запрос"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением что нет загруженных треков
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noResultsLabelText
        
        return cell
    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = activeArray[indexPath.row]
        let track = trackInPlaylist.track
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.addToPlaylistCell, forIndexPath: indexPath) as! AddToPlaylistCell
        cell.delegate = self
        cell.configureForName(track.title, andArtist: track.artist, isAdded: selectedTracks["\(track.id)_\(track.ownerID)"] == nil ? false : true)
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством аудиозаписей
    func getCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = numberOfOfflineAudioForIndexPath(indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Audio, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = nothingFoundLabelText
        
        return nothingFoundCell
    }

}


// MARK: UITableViewDataSource

private typealias _AddPlaylistMusicTableViewControllerDataSource = AddPlaylistMusicTableViewController
extension _AddPlaylistMusicTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeArray.count + 1
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if downloaded.count == 0 {
            return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
        } else {
            if isSearched && filteredTracks.count == 0 {
                return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
            }
            
            if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                return numberOfRowsCell
            }
            
            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
        }
    }
    
}


// MARK: UITableViewDelegate

private typealias _AddPlaylistMusicTableViewControllerDelegate = AddPlaylistMusicTableViewController
extension _AddPlaylistMusicTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activeArray.count != 0 {
            if activeArray.count == indexPath.row {
                return 44
            }
        }
        
        return 53
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}


// MARK: UISearchBarDelegate

extension AddPlaylistMusicTableViewController: UISearchBarDelegate {
    
    // Пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return downloaded.count != 0
    }
    
    // Пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // В поисковой панели была нажата кнопка "Отмена"
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredTracks.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension AddPlaylistMusicTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}


// MARK: DataManagerDownloadsDelegate

extension AddPlaylistMusicTableViewController: DataManagerDownloadsDelegate {
    
    // Контроллер массива загруженных аудиозаписей начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер массива загруженных аудиозаписей совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер массива загруженных аудиозаписей закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        if isSearched {
            filterContentForSearchText(searchController.searchBar.text!)
        } else {
            if tableView.tableHeaderView == nil {
                searchEnable(true)
            }
        }
        
        reloadTableView()
    }
    
}


// MARK: AddToPlaylistCellDelegate

extension AddPlaylistMusicTableViewController: AddToPlaylistCellDelegate {
    
    // Вызывается при нажатии по кнопке "+"
    func addTapped(cell: AddToPlaylistCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let trackInPlaylist = activeArray[indexPath.row]
            let track = trackInPlaylist.track
            
            delegate?.addPlaylistMusicDelegateAddTrack(track)
            selectedTracks["\(track.id)_\(track.ownerID)"] = track
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
        }
    }
    
}
