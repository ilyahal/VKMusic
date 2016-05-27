//
//  MyMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MyMusicTableViewController: MusicFromInternetWithSearchTableViewController {
    
    override var getRequest: (() -> Void)! {
        return getMusic
    }
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getAudio.state
    }
    
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getRequest()
        }
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск в Моей музыке"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            if VKAPIManager.isAuthorized {
                getRequest()
            }
            
            reloadTableView()
        }
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
    func getMusic() {
        RequestManager.sharedInstance.getAudio.performRequest() { success in
            self.music = DataManager.sharedInstance.myMusic.array
            
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
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
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var textForNoResultsRow: String {
        return "Список пуст"
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    override var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var textForNoAuthorizedRow: String {
        return "Для отображения списка личных аудиозаписей необходимо авторизоваться"
    }
    
}
