//
//  OwnerMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class OwnerMusicTableViewController: MusicFromInternetWithSearchTableViewController {

    private var toDelete = true // Флаг на отчистку загруженных результатов
    
    var id: Int! // Идентификатор владельца, чьи аудиозаписи загружаются
    
    override var getRequest: (() -> Void)! {
        return getOwnerMusic
    }
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getOwnerAudio.state
    }
    
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
            
            DataManager.sharedInstance.ownerMusic.clear()
            if !RequestManager.sharedInstance.getOwnerAudio.cancel() {
                RequestManager.sharedInstance.getOwnerAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей владельца
    
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
