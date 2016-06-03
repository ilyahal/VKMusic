//
//  PopularMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий таблицу со списком популярных аудиозаписей
class PopularMusicTableViewController: MusicFromInternetTableViewController {
    
    /// Флаг на отчистку загруженных результатов
    private var toDelete = true
    
    /// Запрос на получение данных с сервера
    override var getRequest: (() -> Void)! {
        return getPopularAudio
    }
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getPopularAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getPopularAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getRequest()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        toDelete = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if toDelete {
            DownloadManager.sharedInstance.deleteDelegate(self)
            DataManager.sharedInstance.deleteDataManagerDownloadsDelegate(self)
            
            DataManager.sharedInstance.popularMusic.clear()
            if !RequestManager.sharedInstance.getPopularAudio.cancel() {
                RequestManager.sharedInstance.getPopularAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение популярных аудиозаписей
    
    /// Запрос на получение популярных аудиозаписей с сервера
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
    override var noResultsLabelText: String {
        return "Нет популярных"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }
    
}
