//
//  RecommendationsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class RecommendationsTableViewController: MusicFromInternetTableViewController {

    private var toDelete = true // Флаг на отчистку загруженных результатов
    
    override var getRequest: (() -> Void)! {
        return getRecommendationsAudio
    }
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getRecommendationsAudio.state
    }
    
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getRecommendationsAudio.error
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
            DataManager.sharedInstance.recommendationsMusic.clear()
            if !RequestManager.sharedInstance.getRecommendationsAudio.cancel() {
                RequestManager.sharedInstance.getRecommendationsAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение рекомендуемых аудиозаписей
    
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
    override var textForNoResultsRow: String {
        return "Нет рекомендаций"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var textForNoAuthorizedRow: String {
        return "Для отображения списка рекомендуемых аудиозаписей необходимо авторизоваться"
    }

}
