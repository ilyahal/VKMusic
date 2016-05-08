//
//  MyMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MyMusicTableViewController: UITableViewController {
    
    private var searchController: UISearchController!
    private var filteredMusic = [Track]() // Массив для результатов поиска по уже загруженным личным аудиозаписям
    
    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        if VKAPIManager.isAuthorized {
            getMusic()
        }
        
        
        // Настройка кнопки назад на дочерних экранах
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
        
        
        // Настройка поисковой панели
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Поиск в Моей музыке"
        definesPresentationContext = true
        
        if VKAPIManager.isAuthorized {
            searchEnable(true)
        }
        
        
        // Настройка Pull-To-Refresh
        if VKAPIManager.isAuthorized {
            pullToRefreshEnable(true)
        }
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            if VKAPIManager.isAuthorized {
                getMusic()
                pullToRefreshEnable(true)
                searchEnable(true)
            } else {
                pullToRefreshEnable(false)
                searchEnable(false)
            }
            
            reloadTableView()
        }
    }
    
    // Заново отрисовать таблицу
    private func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
    private func getMusic() {
        RequestManager.sharedInstance.getAudio { success in
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
            }
            
            if !success {
                switch RequestManager.sharedInstance.getAudioError {
                case .NetworkError:
                    break
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
    
    
    // MARK: Работа с клавиатурой
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    @objc private func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Поиск
    
    func searchEnable(enable: Bool) {
        if enable {
            tableView.tableHeaderView = searchController.searchBar
            tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame)) // Прячем строку поиска
        } else {
            if searchController.active {
                searchController.active = false
            }
            tableView.tableHeaderView = nil
            tableView.contentOffset = CGPointZero
        }
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredMusic = DataManager.sharedInstance.myMusic.filter { track in
            return track.title!.lowercaseString.containsString(searchText.lowercaseString) || track.artist!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    private func pullToRefreshEnable(enable: Bool) {
        if enable {
            refreshControl = UIRefreshControl()
            //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
            refreshControl!.addTarget(self, action: #selector(refreshMyMusic), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
        } else {
            refreshControl?.removeTarget(self, action: #selector(refreshMyMusic), forControlEvents: .ValueChanged)
            refreshControl = nil
        }
    }
    
    @objc private func refreshMyMusic() {
        getMusic()
    }
    
}


// MARK: Типы данных

private typealias MyMusicTableViewControllerDataTypes = MyMusicTableViewController
extension MyMusicTableViewControllerDataTypes {
    
    // Идентификаторы ячеек
    private struct TableViewCellIdentifiers {
        static let noAuthorizedCell = "NoAuthorizedCell" // Ячейка с сообщением об отсутствии авторизации
        static let networkErrorCell = "NetworkErrorCell" // Ячейка с сообщением об ошибке при подключении к интернету
        static let nothingFoundCell = "NothingFoundCell" // Ячейка с сообщением "ничего не найдено"
        static let loadingCell = "LoadingCell" // Ячейка с сообщением о загрузке данных
        static let audioCell = "AudioCell" // Ячейка для вывода аудиозаписи
    }
    
}


// MARK: AudioCellDelegate

extension MyMusicTableViewController: AudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: AudioCell) {
        print("pause" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: AudioCell) {
        print("resume" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: AudioCell) {
        print("cancel" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Скачать
    func downloadTapped(cell: AudioCell) {
        print("download" + cell.nameLabel.text!)
    }
    
}


// MARK: UITableViewDataSource

private typealias MyMusicTableViewControllerDataSource = MyMusicTableViewController
extension MyMusicTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudioState {
            case .NotSearchedYet where RequestManager.sharedInstance.getAudioError == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    return 0
                }
                
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии личных аудиозаписей
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredMusic.count == 0 ? 1 : filteredMusic.count // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных аудиозаписей
                }
                
                return DataManager.sharedInstance.myMusic.count
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudioState {
            case .NotSearchedYet where RequestManager.sharedInstance.getAudioError == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath)
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                
                cell.messageLabel.text = "Список аудиозаписей пуст"
                
                return cell
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    if DataManager.sharedInstance.myMusic.count != 0 {
                        let trackCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                        let track = DataManager.sharedInstance.myMusic[indexPath.row]
                        
                        trackCell.delegate = self
                        
                        trackCell.nameLabel.text = track.title
                        trackCell.artistLabel.text = track.artist
                        
                        return trackCell
                    }
                }
                
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                
                cell.activityIndicator.startAnimating()
                
                return cell
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == 0 {
                    let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                    
                    nothingFoundCell.messageLabel.text = "Измените поисковый запрос"
                    
                    return nothingFoundCell
                }
                
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                var track: Track
                
                if searchController.active && searchController.searchBar.text != "" {
                    track = filteredMusic[indexPath.row]
                } else {
                    track = DataManager.sharedInstance.myMusic[indexPath.row]
                }
                
                cell.delegate = self
                
                cell.nameLabel.text = track.title
                cell.artistLabel.text = track.artist
                
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        
        cell.messageLabel.text = "Для отображения списка личных аудиозаписей необходимо авторизоваться"
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias MyMusicTableViewControllerDelegate = MyMusicTableViewController
extension MyMusicTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is AudioCell {
            let track = DataManager.sharedInstance.myMusic[indexPath.row]
            let trackURL = NSURL(string: track.url!)
            
            PlayerManager.sharedInstance.playFile(trackURL!)
        }
    }
    
}


// MARK: UISearchBarDelegate

extension MyMusicTableViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudioState {
            case .Results:
                if let refreshControl = refreshControl {
                    return !refreshControl.refreshing
                }
                
                return true
            default:
                return false
            }
        }
        
        return false
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
        pullToRefreshEnable(false)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
        pullToRefreshEnable(true)
    }
    
}


// MARK: UISearchResultsUpdating

extension MyMusicTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
        reloadTableView()
    }
    
}