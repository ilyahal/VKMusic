//
//  OwnerMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контейнер содержащий таблицу со списком аудиозаписей владельца
class OwnerMusicTableViewController: MusicFromInternetWithSearchTableViewController {

    /// Флаг на отчистку загруженных результатов
    private var toDelete = true
    
    /// Идентификатор владельца, чьи аудиозаписи загружаются
    var id: Int!
    
    /// Запрос на получение данных с сервера
    override var getRequest: (() -> Void)! {
        return getOwnerMusic
    }
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getOwnerAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getOwnerAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getRequest()
        }
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
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
            
            DataManager.sharedInstance.ownerMusic.clear()
            if !RequestManager.sharedInstance.getOwnerAudio.cancel() {
                RequestManager.sharedInstance.getOwnerAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей владельца
    
    /// Запрос на получение аудиозаписей владельца с сервера
    func getOwnerMusic() {
        RequestManager.sharedInstance.getOwnerAudio.performRequest([.OwnerID : id]) { success in
            self.music = DataManager.sharedInstance.ownerMusic.array
            
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
    
}
