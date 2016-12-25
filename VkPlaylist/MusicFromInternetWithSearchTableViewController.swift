//
//  MusicFromInternetWithSearchTableViewController.swift
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

/// Контроллер отображающий музыку из интернета, с возможностью Pull-To-Refresh и поиском
class MusicFromInternetWithSearchTableViewController: MusicFromInternetTableViewController {
    
    /// Контроллер поиска
    let searchController = UISearchController(searchResultsController: nil)
    /// Выполняется ли сейчас поиск
    var isSearched: Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    /// Массив аудиозаписей, полученный в результате выполнения поискового запроса
    var filteredMusic = [Track]()
    /// Массив аудиозаписей, отображаемых на экране
    override var activeArray: [Track] {
        if isSearched {
            return filteredMusic
        } else {
            return music
        }
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
        
        searchEnable(VKAPIManager.isAuthorized)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            searchEnable(VKAPIManager.isAuthorized)
            
            if !VKAPIManager.isAuthorized {
                filteredMusic.removeAll()
            }
        }
        
        if let _ = tableView.tableHeaderView {
            if tableView.contentOffset.y == 0 {
                tableView.hideSearchBar()
            }
        }
    }
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
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
    
    /// Выполнение поискового запроса
    func filterContentForSearchText(searchText: String) {
        filteredMusic = music.filter { track in
            return track.title.lowercaseString.containsString(searchText.lowercaseString) || track.artist.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Список пуст"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    /// Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
    }
    
}


// MARK: UITableViewDataSource

private typealias _MusicFromInternetWithSearchTableViewControllerDataSource = MusicFromInternetWithSearchTableViewController
extension _MusicFromInternetWithSearchTableViewControllerDataSource {
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .Results:
                if isSearched && filteredMusic.count == 0 {
                    return getCellForNothingFoundRowForIndexPath(indexPath)
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
    
    // Пользователь хочет начать поиск
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
        filteredMusic.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension MusicFromInternetWithSearchTableViewController: UISearchResultsUpdating {
    
    // Поле поиска получило фокус или значение поискового запроса изменилось
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}