//
//  GroupsTableViewController.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// Контроллер содержащий таблицу со списком групп
class GroupsTableViewController: UITableViewController {
    
    /// Выполняется ли обновление
    var isRefreshing: Bool {
        if let refreshControl = refreshControl where refreshControl.refreshing {
            return true
        } else {
            return false
        }
    }
    
    /// Статус выполнения запроса к серверу
    var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getGroups.state
    }
    /// Ошибки при выполнении запроса к серверу
    var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getGroups.error
    }
    
    /// Кэш аватарок групп
    private var imageCache: NSCache!
    
    /// Массив групп, загруженный с сервера
    private var groups: [Group]!
    /// Массив групп, полученный в результате поиска
    private var filteredGroups: [Group]!
    
    /// Массив групп, отображаемый на экрнае
    var activeArray: [Group] {
        if isSearched {
            return filteredGroups
        } else {
            return groups
        }
    }
    
    // Поисковый контроллер
    let searchController = UISearchController(searchResultsController: nil)
    /// Выполняется ли сейчас поиск
    var isSearched: Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            imageCache = NSCache()
            
            getGroups()
        }
        
        // Настройка Pull-To-Refresh
        pullToRefreshEnable(VKAPIManager.isAuthorized)
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        
        searchEnable(VKAPIManager.isAuthorized)
        
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
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством групп
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showGroupAudioViewControllerSegue {
            let ownerMusicViewController = segue.destinationViewController as! OwnerMusicViewController
            let group = sender as! Group
            
            ownerMusicViewController.id = group.id * -1
            ownerMusicViewController.name = group.name
        }
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
    
    
    // MARK: Pull-to-Refresh
    
    /// Управление доступностью Pull-to-Refresh
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            if refreshControl == nil {
                refreshControl = UIRefreshControl()
                //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
                refreshControl!.addTarget(self, action: #selector(getGroups), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
            }
        } else {
            if let refreshControl = refreshControl {
                if refreshControl.refreshing {
                    refreshControl.endRefreshing()
                }
                
                refreshControl.removeTarget(self, action: #selector(getGroups), forControlEvents: .ValueChanged) // Удаляем обработчик контроллера обновления
            }
            
            refreshControl = nil
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
    
    
    // MARK: Выполнение запроса на получение списка групп
    
    /// Запрос на получение личных списка групп с сервера
    func getGroups() {
        RequestManager.sharedInstance.getGroups.performRequest() { success in
            self.groups = DataManager.sharedInstance.groups.array
            
            self.reloadTableView()
            
            if self.isRefreshing { // Если данные обновляются
                self.refreshControl!.endRefreshing() // Говорим что обновление завершено
            }
            
            if !success {
                switch self.requestManagerError {
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
    
    /// Выполнение поискового запроса
    func filterContentForSearchText(searchText: String) {
        filteredGroups = groups.filter { group in
            return group.name.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var noResultsLabelText: String {
        return "Список групп пуст"
    }
    
    /// Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var nothingFoundLabelText: String {
        return "Измените поисковый запрос"
    }
    
    /// Получение количества групп в списке для ячейки с количеством групп
    func numberOfGroupsForIndexPath(indexPath: NSIndexPath) -> Int? {
        if activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    /// Текст для ячейки с сообщением о необходимости авторизоваться
    var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    /// Ячейка для строки когда поиск еще не выполнялся и была получена ошибка при подключении к интернету
    func getCellForNotSearchedYetRowWithInternetErrorForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
        
        return cell
    }
    
    /// Ячейка для строки когда поиск еще не выполнялся
    func getCellForNotSearchedYetRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // Ячейка для строки с сообщением что сервер вернул пустой массив
    func getCellForNoResultsRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noResultsLabelText
        
        return cell
    }
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = nothingFoundLabelText
        
        return nothingFoundCell
    }
    
    // Ячейка для строки с сообщением о загрузке
    func getCellForLoadingRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством групп
    func getCellForNumberOfGroupsRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        let count = numberOfGroupsForIndexPath(indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Group, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с группой
    func getCellForRowWithGroupForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let group = activeArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.groupCell, forIndexPath: indexPath) as! GroupCell
        cell.configureForGroup(group, withImageCacheStorage: imageCache)
        
        return cell
    }
    
    // Ячейка для строки с сообщением о необходимости авторизоваться
    func getCellForNoAuthorizedRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = noAuthorizedLabelText
        
        return cell
    }
    
}


// MARK: UITableViewDataSource

private typealias _GroupsTableViewControllerDataSource = GroupsTableViewController
extension _GroupsTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .NotSearchedYet where requestManagerError == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .NotSearchedYet:
                return 0
            case .Loading where isRefreshing:
                return activeArray.count + 1
            case .Loading:
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии групп
            case .Results:
                return activeArray.count + 1
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .NotSearchedYet where requestManagerError == .NetworkError:
                return getCellForNotSearchedYetRowWithInternetErrorForIndexPath(indexPath)
            case .NotSearchedYet:
                return getCellForNotSearchedYetRowForIndexPath(indexPath)
            case .NoResults:
                return getCellForNoResultsRowForIndexPath(indexPath)
            case .Loading where isRefreshing:
                if let numberOfRowsCell = getCellForNumberOfGroupsRowForIndexPath(indexPath) {
                    return numberOfRowsCell
                }
                
                return getCellForRowWithGroupForIndexPath(indexPath)
            case .Loading:
                return getCellForLoadingRowForIndexPath(indexPath)
            case .Results:
                if isSearched && filteredGroups.count == 0 {
                    return getCellForNothingFoundRowForIndexPath(indexPath)
                }
                
                if let numberOfRowsCell = getCellForNumberOfGroupsRowForIndexPath(indexPath) {
                    return numberOfRowsCell
                }
                
                return getCellForRowWithGroupForIndexPath(indexPath)
            }
        }
        
        return getCellForNoAuthorizedRowForIndexPath(indexPath)
    }
    
}


// MARK: UITableViewDelegate

private typealias _GroupsTableViewControllerDelegate = GroupsTableViewController
extension _GroupsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if requestManagerStatus == .Results || requestManagerStatus == .Loading && isRefreshing {
                if activeArray.count != 0 {
                    if activeArray.count == indexPath.row {
                        return 44
                    }
                }
            }
        }
        
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is GroupCell {
            performSegueWithIdentifier(SegueIdentifiers.showGroupAudioViewControllerSegue, sender: activeArray[indexPath.row])
        }
    }
    
}


// MARK: UISearchBarDelegate

extension GroupsTableViewController: UISearchBarDelegate {
    
    // Пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .Results:
                if let refreshControl = refreshControl {
                    return !refreshControl.refreshing
                }
                
                return groups.count != 0
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    // Пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
        
        pullToRefreshEnable(false)
    }
    
    // Пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
        
        pullToRefreshEnable(true)
    }
    
    // В поисковой панели была нажата кнопка "Отмена"
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredGroups.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension GroupsTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}