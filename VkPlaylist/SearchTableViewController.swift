//
//  SearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий таблицу со списком искомых аудиозаписей
class SearchTableViewController: MusicFromInternetWithSearchTableViewController {
    
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.searchAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.searchAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            reloadTableView()
        }
        
        pullToRefreshEnable(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !music.isEmpty {
            return
        }
        
        tableView.contentOffset = CGPointMake(0, -64) // Отображаем строку поиска
    }
    
    
    // MARK: Выполнение запроса на получение искомых аудиозаписей
    
    /// Запрос на получение искомых аудиозаписей с сервера
    func searchMusic(search: String) {
        RequestManager.sharedInstance.searchAudio.performRequest([.RequestText : search]) { success in
            self.music = DataManager.sharedInstance.searchMusic.array
            self.filteredMusic = self.music
            
            self.reloadTableView()
            
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
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var noResultsLabelText: String {
        return "Ничего не найдено"
    }
    
    /// Текст для ячейки с сообщением о необходимости авторизоваться
    override var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }
    
}


// MARK: UITableViewDataSource

private typealias SearchTableViewControllerDataSource = SearchTableViewController
extension SearchTableViewControllerDataSource {
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .Loading:
                return getCellForLoadingRowInTableView(tableView, forIndexPath: indexPath)
            case .Results:
                if isSearched && filteredMusic.count == 0 {
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

private typealias SearchTableViewControllerUISearchBarDelegate = SearchTableViewController
extension SearchTableViewControllerUISearchBarDelegate {
    
    // Пользователь хочет начать поиск
    override func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return VKAPIManager.isAuthorized
    }
    
    // Пользователь закончил редактирование поискового текста
    override func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
        
        pullToRefreshEnable(false)
    }
    
    // На клавиатуре была нажата кнопка "Искать"
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchMusic(searchController.searchBar.text!)

        reloadTableView()
    }
    
    // В поисковой панели была нажата кнопка "Отмена"
    override func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        music.removeAll()
        filteredMusic.removeAll()
        
        DataManager.sharedInstance.searchMusic.clear()
        if !RequestManager.sharedInstance.searchAudio.cancel() {
            RequestManager.sharedInstance.searchAudio.dropState()
        }
        
        reloadTableView()
    }
    
}


// MARK: UISearchResultsUpdating

private typealias SearchTableViewControllerUISearchResultsUpdating = SearchTableViewController
extension SearchTableViewControllerUISearchResultsUpdating {
    
    // Поле поиска получило фокус или значение поискового запроса изменено
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // FIXME: При отправлении запроса с каждым изменением текстового поля программа периодически крашится
        
//        DataManager.sharedInstance.searchMusic.clear()
//        
//        if !searchController.searchBar.text!.isEmpty {
//            searchMusic(searchController.searchBar.text!)
//        }
//        
//        reloadTableView()
    }
    
}