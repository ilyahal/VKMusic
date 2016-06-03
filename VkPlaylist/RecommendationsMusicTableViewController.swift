//
//  RecommendationsMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контейнер содержащий контейнер со списком рекомендуемых аудиозаписей
class RecommendationsMusicTableViewController: MusicFromInternetTableViewController {

    /// Флаг на отчистку загруженных результатов
    private var toDelete = true
    
    /// Запрос на получение данных с сервера
    override var getRequest: (() -> Void)! {
        return getRecommendationsAudio
    }
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getRecommendationsAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getRecommendationsAudio.error
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
            
            DataManager.sharedInstance.recommendationsMusic.clear()
            if !RequestManager.sharedInstance.getRecommendationsAudio.cancel() {
                RequestManager.sharedInstance.getRecommendationsAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение рекомендуемых аудиозаписей
    
    /// Запрос на получение рекомендуемых аудиозаписей с сервера
    func getRecommendationsAudio() {
        RequestManager.sharedInstance.getRecommendationsAudio.performRequest() { success in
            self.music = DataManager.sharedInstance.recommendationsMusic.array
            
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
        return "Нет рекомендаций"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }

}
