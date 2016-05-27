//
//  GetAlbumAudio.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 12.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Получение списка аудиозаписей альбома

class GetAlbumAudio: RequestManagerObject {
    
    override func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        super.performRequest(parameters, withCompletionHandler: completion)
        
        // Отмена выполнения предыдущего запроса и удаление загруженной информации
        cancel()
        DataManager.sharedInstance.albumMusic.clear()
        
        let albumID = parameters[.AlbumID]! as! Int
        
        // Если нет подключения к интернету
        if !Reachability.isConnectedToNetwork() {
            state = .NotSearchedYet
            error = .NetworkError
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            completion(false)
            
            return
        }
        
        
        // Слушатель для уведомления об успешном завершении получения аудиозаписей
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetAudioForAlbumNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            let result = notification.userInfo!["Audio"] as! [Track]
            
            DataManager.sharedInstance.albumMusic.update(result)
            self.state = DataManager.sharedInstance.albumMusic.array.count == 0 ? .NoResults : .Results
            self.error = .None
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioForAlbumNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            DataManager.sharedInstance.albumMusic.clear()
            self.state = .NotSearchedYet
            self.error = .NetworkError
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioForAlbumErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            DataManager.sharedInstance.albumMusic.clear()
            self.state = .NotSearchedYet
            self.error = .UnknownError
            
            completion(false)
        }
        
        
        let request = VKAPIManager.audioGetWithAlbumID(albumID)
        
        state = .Loading
        error = .None
        
        RequestManager.sharedInstance.activeRequests[key] = request
    }
    
}