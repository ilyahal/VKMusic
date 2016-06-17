//
//  SearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий таблицу со списком искомых аудиозаписей
class SearchTableViewController: MusicFromInternetTableViewController {
    
    var searchRequest = "" {
        didSet {
            if searchRequest != "" {
                searchMusic(searchRequest)
                reloadTableView()
            }
        }
    }
    
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.searchAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.searchAudio.error
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            reloadTableView()
        }
        
        pullToRefreshEnable(false)
    }
    
    
    // MARK: Выполнение запроса на получение искомых аудиозаписей
    
    /// Запрос на получение искомых аудиозаписей с сервера
    func searchMusic(search: String) {
        RequestManager.sharedInstance.searchAudio.performRequest([.RequestText : search]) { success in
            self.playlistIdentifier = NSUUID().UUIDString
            
            self.music = DataManager.sharedInstance.searchMusic.array
            
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

private typealias _SearchTableViewControllerDataSource = SearchTableViewController
extension _SearchTableViewControllerDataSource {
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .Loading:
                return getCellForLoadingRowForIndexPath(indexPath)
            default:
                break
            }
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
}
