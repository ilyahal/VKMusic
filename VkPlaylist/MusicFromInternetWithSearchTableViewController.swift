//
//  MusicFromInternetWithSearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MusicFromInternetWithSearchTableViewController: MusicFromInternetTableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredMusic: [Track]! = [] // Массив для результатов поиска по уже загруженным личным аудиозаписям
    override var activeArray: [Track] { // Массив аудиозаписей отображаемый на экране
        let array: [Track]!
        
        if searchController.active && searchController.searchBar.text != "" {
            array = filteredMusic
        } else {
            array = music
        }
        
        return array
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
        
        if VKAPIManager.isAuthorized {
            searchEnable(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            if VKAPIManager.isAuthorized {
                searchEnable(true)
            } else {
                searchEnable(false)
            }
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Список пуст"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
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
    
    
    // MARK: Поиск
    
    // Управление доступностью поиска
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
    
    // Выполнение поиска
    func filterContentForSearchText(searchText: String) {
        filteredMusic = music.filter { track in
            return track.title!.lowercaseString.containsString(searchText.lowercaseString) || track.artist!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias MusicFromInternetWithSearchTableViewControllerDataSource = MusicFromInternetWithSearchTableViewController
extension MusicFromInternetWithSearchTableViewControllerDataSource {
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    if music.count != 0 {
                        if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == 0 {
                            return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
                        }
                    }
                }
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == 0 {
                    return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
                }
            default:
                break
            }
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
}


// MARK: UISearchBarDelegate

extension MusicFromInternetWithSearchTableViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
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
    
    // В поисковой панели была нажата отмена
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredMusic.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension MusicFromInternetWithSearchTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}