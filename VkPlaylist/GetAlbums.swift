//
//  GetAlbums.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Получение списка альбомов

class GetAlbums: RequestManagerObject {
    
    override func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        super.performRequest(parameters, withCompletionHandler: completion)
        
        cancel()
        DataManager.sharedInstance.albums.clear()
        
        
        if !Reachability.isConnectedToNetwork() {
            state = .NotSearchedYet
            error = .NetworkError
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            completion(false)
            
            return
        }
        
        
        // Слушатель для уведомления об успешном завершении получения альбомов
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetAlbumsNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            let result = notification.userInfo!["Albums"] as! [Album]
            
            // Сохраняем данные
            DataManager.sharedInstance.albums.update(result)
            self.state = DataManager.sharedInstance.albums.array.count == 0 ? .NoResults : .Results
            self.error = .None
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAlbumsNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.albums.clear()
            self.state = .NotSearchedYet
            self.error = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAlbumsErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.albums.clear()
            self.state = .NotSearchedYet
            self.error = .UnknownError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        
        let request = VKAPIManager.audioGetAlbums()
        
        state = .Loading
        error = .None
        
        RequestManager.sharedInstance.activeRequests[key] = request
    }
    
}