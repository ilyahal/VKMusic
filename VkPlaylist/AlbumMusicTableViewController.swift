//
//  AlbumMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 12.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий таблицу со списком аудиозаписей выбранного плейлиста
class AlbumMusicTableViewController: MusicFromInternetWithSearchTableViewController {
    
    /// Выбранный альбом
    var album: Album!
    
    /// Запрос на получение данных с сервера
    override var getRequest: (() -> Void)! {
        return getAlbumMusic
    }
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getAlbumAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getAlbumAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if VKAPIManager.isAuthorized {
            getRequest()
        }
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей альбома
    
    /// Запрос на получение аудиозаписей альбома с сервера
    func getAlbumMusic() {
        RequestManager.sharedInstance.getAlbumAudio.performRequest([.AlbumID : album.id]) { success in
            self.playlistIdentifier = NSUUID().UUIDString
            
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
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var noResultsLabelText: String {
        return "Альбом пустой"
    }
    
    /// Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    override var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    /// Текст для ячейки с сообщением о необходимости авторизоваться
    override var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }

}
