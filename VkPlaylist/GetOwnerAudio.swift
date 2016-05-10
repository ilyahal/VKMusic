//
//  GetOwnerAudio.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Получение списка аудиозаписей владельца

class GetOwnerAudio: RequestManagerObject {
    
    override func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        super.performRequest(parameters, withCompletionHandler: completion)
        
        cancel()
        DataManager.sharedInstance.ownerMusic.clear()
        
        let ownerID = parameters[.OwnerID]! as! Int
        
        
        if !Reachability.isConnectedToNetwork() {
            state = .NotSearchedYet
            error = .NetworkError
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            completion(false)
            
            return
        }
        
        
        // Слушатель для уведомления об успешном завершении получения аудиозаписей
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetAudioForOwnerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            let result = notification.userInfo!["Audio"] as! [Track]
            
            // Сохраняем данные
            DataManager.sharedInstance.ownerMusic.update(result)
            self.state = DataManager.sharedInstance.ownerMusic.array.count == 0 ? .NoResults : .Results
            self.error = .None
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioForOwnerNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.ownerMusic.clear()
            self.state = .NotSearchedYet
            self.error = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        // Слушатель для получения уведомления об ошибке при доступе к аудиозаписям владельца
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioForOwnerAccessErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.ownerMusic.clear()
            self.state = .NotSearchedYet
            self.error = .AccessError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioForOwnerErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.ownerMusic.clear()
            self.state = .NotSearchedYet
            self.error = .UnknownError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        
        let request = VKAPIManager.audioGetWithOwnerID(ownerID)
        
        state = .Loading
        error = .None
        
        RequestManager.sharedInstance.activeRequests[key] = request
    }
    
}