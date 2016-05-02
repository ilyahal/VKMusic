//
//  MyMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MyMusicTableViewController: UITableViewController {

    var authorizationNavigationController: UINavigationController? // view controller для авторизации
    
    private var searchController: UISearchController!
    private var filteredMusic = [Track]() // Массив для результатов поиска по уже загруженным личным аудиозаписям
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame)) // Прячем строку поиска
        
        
        // Настройка Pull-To-Refresh
        pullToRefreshEnable(true)
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка ничего не найдено
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка загрузка
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        // Наблюдатели за авторизацией пользователя
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidAutorize), name: VKAPIManagerDidAutorizeNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidUnautorize), name: VKAPIManagerDidUnautorizeNotification, object: nil) // Добавляем слушателя для события деавторизации
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !VKAPIManager.isAuthorized {
            showAuthorizationViewController()
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
                    let alertController = UIAlertController(title: "Ошибка", message: "Проверьте соединение с интернетом!", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: false, completion: nil)
                    }
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
    
    
    // MARK: Авторизация пользователя
    
    // Показать экран с авторизацией пользователя
    private func showAuthorizationViewController() {
        if authorizationNavigationController == nil {
            authorizationNavigationController = storyboard?.instantiateViewControllerWithIdentifier("AuthorizationNavigationController") as? UINavigationController
            presentViewController(authorizationNavigationController!, animated: true, completion: nil)
        }
    }
    
    // Скрыть экран с авторизацией пользователя
    private func hideAuthorizationViewController() {
        if let _ = authorizationNavigationController {
            dismissViewControllerAnimated(true, completion: nil)
            authorizationNavigationController = nil
        }
    }
    
    // Пользователь авторизовался
    @objc private func userDidAutorize() {
        hideAuthorizationViewController()
        
        getMusic()
        reloadTableView()
    }
    
    // Пользователь деавторизовался
    @objc private func userDidUnautorize() {
        DataManager.sharedInstance.clearMyMusic()
        RequestManager.sharedInstance.cancelRequestInCaseOfDeavtorization()
        
        reloadTableView()
        if let refreshControl = refreshControl where refreshControl.refreshing {
            refreshControl.endRefreshing()
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
    
    private func filterContentForSearchText(searchText: String) {
        filteredMusic = DataManager.sharedInstance.myMusic.filter { track in
            return track.title!.lowercaseString.containsString(searchText.lowercaseString) || track.artist!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        reloadTableView()
    }
    
    
    // MARK: Pull-to-Refresh
    
    private func pullToRefreshEnable(enable: Bool) {
        if enable {
            refreshControl = UIRefreshControl()
            //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...")
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
        switch RequestManager.sharedInstance.getAudioState {
        case .NoResults, .Loading:
            return 1
        case .Results:
            if searchController.active && searchController.searchBar.text != "" {
                return filteredMusic.count
            }
            
            return DataManager.sharedInstance.myMusic.count
        default:
            return 0
        }
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch RequestManager.sharedInstance.getAudioState {
        case .NoResults:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
            
            cell.messageLabel.text = "Список аудиозаписей пуст"
            
            return cell
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
            
            cell.activityIndicator.startAnimating()
            
            return cell
        case .Results:
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
    }
    
}


// MARK: UISearchBarDelegate

extension MyMusicTableViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        switch RequestManager.sharedInstance.getAudioState {
        case .NotSearchedYet, .NoResults, .Loading:
            return false
        case .Results:
            if let refreshControl = refreshControl {
                return !refreshControl.refreshing
            }
            
            return true
        }
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
    }
    
}