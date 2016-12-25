//
//  SearchTableViewController.swift
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
