//
//  AlbumMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 12.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AlbumMusicTableViewController: MusicFromInternetWithSearchTableViewController {

    private var toDelete = true // Флаг на отчистку загруженных результатов
    
    var id: Int! // Идентификатор альбома, чьи аудиозаписи загружаются
    var name: String? // Название альбома
    
    override var getRequest: (() -> Void)! {
        return getAlbumMusic
    }
    
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getAlbumAudio.state
    }
    
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getAlbumAudio.error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if VKAPIManager.isAuthorized {
            getRequest()
        }
        
        // Настройка навигационной панели
        title = name
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toDelete = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if toDelete {
            DataManager.sharedInstance.albumMusic.clear()
            if !RequestManager.sharedInstance.getAlbumAudio.cancel() {
                RequestManager.sharedInstance.getAlbumAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей альбома
    
    func getAlbumMusic() {
        RequestManager.sharedInstance.getAlbumAudio.performRequest([.AlbumID : id]) { success in
            self.music = DataManager.sharedInstance.albumMusic.array
            
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
    
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var textForNoResultsRow: String {
        return "Список аудиозаписей пуст"
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    override var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    override var textForNoAuthorizedRow: String {
        return "Необходимо авторизоваться"
    }

}
