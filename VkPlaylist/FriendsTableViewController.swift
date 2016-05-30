//
//  FriendsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    private var imageCache: NSCache!
    private var names: [String: [Friend]]!
    private var nameSectionTitles: [String]!
    
    private var friends: [Friend]!
    private var filteredFriends: [Friend]! // Массив для результатов поиска по уже загруженному списку друзей
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            imageCache = NSCache()
            names = [:]
            
            getFriends()
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
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством друзей
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    deinit{
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
        if segue.identifier == "ShowFriendAudioSegue" {
            let ownerMusicTableViewController = segue.destinationViewController as! OwnerMusicTableViewController
            let friend = sender as! Friend
            
            ownerMusicTableViewController.id = friend.id
            ownerMusicTableViewController.name = friend.getFullName()
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
    
    
    // MARK: Выполнение запроса на получение списка друзей
    
    func getFriends() {
        RequestManager.sharedInstance.getFriends.performRequest() { success in
            self.friends = DataManager.sharedInstance.friends.array
            
            // Распределяем по секциям
            if RequestManager.sharedInstance.getFriends.state == .Results {
                for friend in self.friends {
                    
                    // Устанавливаем по какому значению будем сортировать
                    let name = friend.last_name!
                    
                    var firstCharacter = String(name.characters.first!)
                    
                    let characterSet = NSCharacterSet(charactersInString: "абвгдеёжзийклмнопрстуфхцчшщъыьэюя" + "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" + "abcdefghijklmnopqrstuvwxyz" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
                    if (NSString(string: firstCharacter).rangeOfCharacterFromSet(characterSet.invertedSet).location != NSNotFound){
                        firstCharacter = "#"
                    }
                    
                    if self.names[String(firstCharacter)] == nil {
                        self.names[String(firstCharacter)] = []
                    }
                    
                    self.names[String(firstCharacter)]!.append(friend)
                }
                
                self.nameSectionTitles = self.names.keys.sort { (left: String, right: String) -> Bool in
                    return left.localizedStandardCompare(right) == .OrderedAscending // Сортировка по возрастанию
                }
                
                if self.nameSectionTitles.first == "#" {
                    self.nameSectionTitles.removeFirst()
                    self.nameSectionTitles.append("#")
                }
                
                // Сортируем имена в каждой секции
                for (key, section) in self.names {
                    self.names[key] = section.sort { (left: Friend, right: Friend) -> Bool in
                        let leftFullName = left.last_name! + " " + left.first_name!
                        let rightFullName = right.last_name! + " " + right.first_name!
                        
                        return leftFullName.localizedStandardCompare(rightFullName) == .OrderedAscending // Сортировка по возрастанию
                    }
                }
            }
            
            self.reloadTableView()
            
            
            if !success {
                switch RequestManager.sharedInstance.getFriends.error {
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
                tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame)) // Прячем строку поиска
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
        filteredFriends = friends.filter { friend in
            return friend.first_name!.lowercaseString.containsString(searchText.lowercaseString) || friend.last_name!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }

}

// MARK: UITableViewDataSource

private typealias FriendsTableViewControllerDataSource = FriendsTableViewController
extension FriendsTableViewControllerDataSource {
    
    // Получение количество секций
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getFriends.state {
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return 1
                }
                
                return nameSectionTitles.count
            default:
                return 1
            }
        }
        
        return 1
    }
    
    // Получение заголовков секций
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getFriends.state {
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return nil
                }
                
                return nameSectionTitles[section]
            default:
                return nil
            }
        }
        
        return nil
    }
    
    // Получение количества строк таблицы в указанной секции
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getFriends.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getFriends.error == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .Loading:
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии друзей
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredFriends.count == 0 ? 1 : filteredFriends.count + 1 // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных друзей
                }
                
                let sectionTitle = nameSectionTitles[section]
                let sectionNames = names[sectionTitle]
                
                var count = sectionNames!.count
                
                if nameSectionTitles.count - 1 == section {
                    count += 1 // Для ячейки с количеством друзей в последней секции
                }
                
                return count
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getFriends.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getFriends.error == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                cell.messageLabel.text = "Список друзей пуст"
                
                return cell
            case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                cell.activityIndicator.startAnimating()
                
                return cell
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredFriends.count == 0 {
                    let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                    nothingFoundCell.messageLabel.text = "Измените поисковый запрос"
                    
                    return nothingFoundCell
                }
                
                
                let sectionTitle = nameSectionTitles[indexPath.section]
                let sectionNames = names[sectionTitle]
                
                
                let count: Int?
                
                if searchController.active && !searchController.searchBar.text!.isEmpty && filteredFriends.count == indexPath.row {
                    count = filteredFriends.count
                } else if searchController.searchBar.text!.isEmpty && sectionNames!.count == indexPath.row {
                    count = friends.count
                } else {
                    count = nil
                }
                
                if let count = count {
                    let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                    numberOfRowsCell.configureForType(.Friend, withCount: count)
                    
                    return numberOfRowsCell
                }
                
                
                var friend: Friend
                
                if searchController.active && searchController.searchBar.text != "" {
                    friend = filteredFriends[indexPath.row]
                } else {
                    friend = sectionNames![indexPath.row]
                }
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.friendCell, forIndexPath: indexPath) as! FriendCell
                cell.configureForFriend(friend, withImageCacheStorage: imageCache)
                
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = "Для отображения списка друзей необходимо авторизоваться"
        
        return cell
    }
    
    // Получение массива индексов секций таблицы
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getFriends.state {
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return nil
                }
                
                return nameSectionTitles
            default:
                return nil
            }
        }
        
        return nil
    }
    
}


// MARK: UITableViewDelegate

private typealias FriendsTableViewControllerDelegate = FriendsTableViewController
extension FriendsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getFriends.state == .Results {
                let sectionTitle = nameSectionTitles[indexPath.section]
                let sectionNames = names[sectionTitle]
                
                let count: Int?
                
                if searchController.active && searchController.searchBar.text != "" && filteredFriends.count == indexPath.row {
                    count = filteredFriends.count
                } else if sectionNames!.count == indexPath.row {
                    count = sectionNames!.count
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
        
        if tableView.cellForRowAtIndexPath(indexPath) is FriendCell {
            var friend: Friend
                
            if searchController.active && !searchController.searchBar.text!.isEmpty {
                friend = filteredFriends[indexPath.row]
            } else {
                let sectionTitle = nameSectionTitles[indexPath.section]
                let sectionNames = names[sectionTitle]
                
                friend = sectionNames![indexPath.row]
            }
            
            performSegueWithIdentifier("ShowFriendAudioSegue", sender: friend)
        }
    }
    
}


// MARK: UISearchBarDelegate

extension FriendsTableViewController: UISearchBarDelegate {
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredFriends.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension FriendsTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}