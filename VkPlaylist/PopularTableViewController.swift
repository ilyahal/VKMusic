//
//  PopularTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class PopularTableViewController: MusicFromInternetTableViewController {
    
    private var toDelete = true // Флаг на отчистку загруженных результатов
    
    override var getRequest: (() -> Void)! {
        return getPopularAudio
    }
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getPopularAudio.state
    }
    
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getPopularAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getRequest()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toDelete = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if toDelete {
            DownloadManager.sharedInstance.deleteDelegate(self)
            
            DataManager.sharedInstance.popularMusic.clear()
            if !RequestManager.sharedInstance.getPopularAudio.cancel() {
                RequestManager.sharedInstance.getPopularAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение популярных аудиозаписей
    
    func getPopularAudio() {
        RequestManager.sharedInstance.getPopularAudio.performRequest() { success in
            self.music = DataManager.sharedInstance.popularMusic.array
            
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
        return "Нет популярных"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var textForNoAuthorizedRow: String {
        return "Для отображения списка популярных аудиозаписей необходимо авторизоваться"
    }
    
}
