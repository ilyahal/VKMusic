//
//  GroupsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    private var toDelete = true // Флаг на отчистку загруженных результатов
    
    private var imageCache: NSCache!
    
    private var groups: [Group]!
    private var filteredGroups: [Group]! // Массив для результатов поиска по уже загруженному списку групп
    
    var activeArray: [Group] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredGroups
        } else {
            return groups
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            imageCache = NSCache()
            
            getGroups()
        }
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        
        if VKAPIManager.isAuthorized {
            searchEnable(true)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        toDelete = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if toDelete {
            imageCache?.removeAllObjects()
            DataManager.sharedInstance.groups.clear()
            if !RequestManager.sharedInstance.getGroups.cancel() {
                RequestManager.sharedInstance.getGroups.dropState()
            }
        }
    }
    
    deinit {
        if let superView = searchController.view.superview
        {
            superView.removeFromSuperview()
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
        if segue.identifier == "ShowGroupAudioViewControllerSegue" {
            let ownerMusicViewController = segue.destinationViewController as! OwnerMusicViewController
            let group = sender as! Group
            
            ownerMusicViewController.id = group.id! * -1
            ownerMusicViewController.name = group.name
            
            toDelete = false
        }
    }
    
    
    // MARK: Работа с клавиатурой
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Выполнение запроса на получение списка групп
    
    func getGroups() {
        RequestManager.sharedInstance.getGroups.performRequest() { success in
            self.groups = DataManager.sharedInstance.groups.array
            
            self.reloadTableView()
            
            if !success {
                switch RequestManager.sharedInstance.getGroups.error {
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
    
    func filterContentForSearchText(searchText: String) {
        filteredGroups = groups.filter { group in
            return group.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var textForNoResultsRow: String {
        return "Список групп пуст"
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    // Получение количества групп в списке для ячейки с количеством групп
    func getCountForCellForNumberOfGroupsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        if activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    var textForNoAuthorizedRow: String {
        return "Необходимо авторизоваться"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
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
        cell.messageLabel.text = textForNoResultsRow
        
        return cell
    }
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
    }
    
    // Ячейка для строки с сообщением о загрузке
    func getCellForLoadingRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством групп
    func getCellForNumberOfGroupsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = getCountForCellForNumberOfGroupsRowInTableView(tableView, forIndexPath: indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Group, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с группой
    func getCellForRowWithGroupInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let group = activeArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.groupCell, forIndexPath: indexPath) as! GroupCell
        cell.configureForGroup(group, withImageCacheStorage: imageCache)
        
        return cell
    }
    
    // Ячейка для строки с сообщением о необходимости авторизоваться
    func getCellForNoAuthorizedRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = textForNoAuthorizedRow
        
        return cell
    }
    
}

// MARK: UITableViewDataSource

private typealias GroupsTableViewControllerDataSource = GroupsTableViewController
extension GroupsTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getGroups.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getGroups.error == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .NotSearchedYet:
                return 0
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
            switch RequestManager.sharedInstance.getGroups.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getGroups.error == .NetworkError:
                return getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView, forIndexPath: indexPath)
            case .NotSearchedYet:
                return getCellForNotSearchedYetRowInTableView(tableView, forIndexPath: indexPath)
            case .NoResults:
                return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
            case .Loading:
                return getCellForLoadingRowInTableView(tableView, forIndexPath: indexPath)
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredGroups.count == 0 {
                    return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
                } else if let numberOfRowsCell = getCellForNumberOfGroupsRowInTableView(tableView, forIndexPath: indexPath) {
                    return numberOfRowsCell
                }
                return getCellForRowWithGroupInTableView(tableView, forIndexPath: indexPath)
            }
        }
        
        return getCellForNoAuthorizedRowInTableView(tableView, forIndexPath: indexPath)
    }
    
}


// MARK: UITableViewDelegate

private typealias GroupsTableViewControllerDelegate = GroupsTableViewController
extension GroupsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getGroups.state == .Results {
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
            performSegueWithIdentifier("ShowGroupAudioViewControllerSegue", sender: activeArray[indexPath.row])
        }
    }
    
}


// MARK: UISearchBarDelegate

extension GroupsTableViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if groups.count != 0 {
            return true
        }
        
        return false
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // В поисковой панели была нажата отмена
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