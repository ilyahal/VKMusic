//
//  GetFriends.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Получение списка личных аудиозаписей

class GetFriends: RequestManagerObject {
    
    override func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        super.performRequest(parameters, withCompletionHandler: completion)
        
        cancel()
        DataManager.sharedInstance.friends.clear()
        
        
        if !Reachability.isConnectedToNetwork() {
            state = .NotSearchedYet
            error = .NetworkError
            
            completion(false)
            
            return
        }
        
        
        // Слушатель для уведомления об успешном завершении получения друзей
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetFriendsNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            let result = notification.userInfo!["Friends"] as! [Friend]
            
            // Сохраняем данные
            DataManager.sharedInstance.friends.update(result)
            self.state = DataManager.sharedInstance.friends.array.count == 0 ? .NoResults : .Results
            self.error = .None
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetFriendsNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.friends.clear()
            self.state = .NotSearchedYet
            self.error = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetFriendsErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.friends.clear()
            self.state = .NotSearchedYet
            self.error = .UnknownError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.removeObservers()
            self.removeFromActiveRequests()
            
            completion(false)
        }
        
        
        let request = VKAPIManager.friendsGet()
        
        state = .Loading
        error = .None
        
        RequestManager.sharedInstance.activeRequests[key] = request
    }
    
}