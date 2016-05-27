//
//  SearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class SearchTableViewController: MusicFromInternetWithSearchTableViewController {
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.searchAudio.state
    }
    
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
        
        if let music = music where !music.isEmpty {
            return
        }
        
        tableView.contentOffset = CGPointMake(0, -64) // Отображаем строку поиска
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
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
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var textForNoResultsRow: String {
        return "Ничего не найдено"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var textForNoAuthorizedRow: String {
        return "Для поиска аудиозаписей необходимо авторизоваться"
    }
    
}


// MARK: UISearchBarDelegate

private typealias SearchTableViewControllerUISearchBarDelegate = SearchTableViewController
extension SearchTableViewControllerUISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    override func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            return true
        }
        
        return false
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    override func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
        
        pullToRefreshEnable(false)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchController.searchBar.text!.isEmpty {
            searchMusic(searchController.searchBar.text!)
        }

        reloadTableView()
    }
    
    override func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        music?.removeAll()
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
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        super.updateSearchResultsForSearchController(searchController)
        
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