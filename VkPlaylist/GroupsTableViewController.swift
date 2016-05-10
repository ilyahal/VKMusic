//
//  GroupsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    private var imageCache: NSCache!
    
    private var groups: [Group]!
    private var filteredGroups: [Group]! // Массив для результатов поиска по уже загруженному списку групп
    
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            imageCache = NSCache()
            
            getGroups()
        }
        
        
        // Настройка поисковой панели
        searchController = UISearchController(searchResultsController: nil)
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
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    // Подготовка к выполнению перехода
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGroupAudioSegue" {
            let ownerMusicTableViewController = segue.destinationViewController as! OwnerMusicTableViewController
            let group = sender as! Group
            
            ownerMusicTableViewController.id = group.id! * -1
            ownerMusicTableViewController.name = group.name
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
            searchController.searchBar.alpha = 1
            tableView.tableHeaderView = searchController.searchBar
            tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame)) // Прячем строку поиска
        } else {
            searchController.searchBar.alpha = 0
            searchController.active = false
            tableView.tableHeaderView = nil
            tableView.contentOffset = CGPointZero
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredGroups = groups.filter { group in
            return group.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
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
            case .Loading:
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии групп
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredGroups.count == 0 ? 1 : filteredGroups.count + 1 // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных друзей
                }
                
                return groups.count + 1
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getGroups.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getGroups.error == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                cell.messageLabel.text = "Список групп пуст"
                
                return cell
            case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                cell.activityIndicator.startAnimating()
                
                return cell
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredGroups.count == 0 {
                    let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                    nothingFoundCell.messageLabel.text = "Измените поисковый запрос"
                    
                    return nothingFoundCell
                }
                
                
                let count: Int?
                
                if searchController.active && searchController.searchBar.text != "" && filteredGroups.count == indexPath.row {
                    count = filteredGroups.count
                } else if groups.count == indexPath.row {
                    count = groups.count
                } else {
                    count = nil
                }
                
                if let count = count {
                    let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                    numberOfRowsCell.configureForType(.Group, withCount: count)
                    
                    return numberOfRowsCell
                }
                
                
                var group: Group
                
                if searchController.active && searchController.searchBar.text != "" {
                    group = filteredGroups[indexPath.row]
                } else {
                    group = groups[indexPath.row]
                }
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.groupCell, forIndexPath: indexPath) as! GroupCell
                cell.configureForGroup(group, withImageCacheStorage: imageCache)
                
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = "Для отображения списка групп необходимо авторизоваться"
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias GroupsTableViewControllerDelegate = GroupsTableViewController
extension GroupsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getGroups.state == .Results {
                let count: Int?
                
                if searchController.active && searchController.searchBar.text != "" && filteredGroups.count == indexPath.row {
                    count = filteredGroups.count
                } else if groups.count == indexPath.row {
                    count = groups.count
                } else {
                    count = nil
                }
                
                if let _ = count {
                    return 44
                }
            }
        }
        
        return 62
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getGroups.state == .Results {
                if searchController.active && searchController.searchBar.text != "" && filteredGroups.count == 0 {
                    return
                }
                
                var group: Group
                
                if searchController.active && searchController.searchBar.text != "" {
                    group = filteredGroups[indexPath.row]
                } else {
                    group = groups[indexPath.row]
                }
                
                performSegueWithIdentifier("ShowGroupAudioSegue", sender: group)
            }
        }
    }
    
}


// MARK: UISearchBarDelegate

extension GroupsTableViewController: UISearchBarDelegate {
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
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