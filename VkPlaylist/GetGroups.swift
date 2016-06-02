//
//  GetGroups.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Получение списка групп
class GetGroups: RequestManagerObject {
    
    override func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        super.performRequest(parameters, withCompletionHandler: completion)
        
        // Отмена выполнения предыдущего запроса и удаление загруженной информации
        cancel()
        DataManager.sharedInstance.groups.clear()
        
        // Если нет подключения к интернету
        if !Reachability.isConnectedToNetwork() {
            state = .NotSearchedYet
            error = .NetworkError
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            completion(false)
            
            return
        }
        
        
        // Слушатель для уведомления об успешном завершении получения групп
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetGroupsNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            let result = notification.userInfo!["Groups"] as! [Group]
            
            DataManager.sharedInstance.groups.saveNewArray(result)
            self.state = DataManager.sharedInstance.groups.array.count == 0 ? .NoResults : .Results
            self.error = .None
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetGroupsNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            DataManager.sharedInstance.groups.clear()
            self.state = .NotSearchedYet
            self.error = .NetworkError
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetGroupsErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.removeActivState() // Удаление состояние выполнения запроса
            
            // Сохранение данных
            DataManager.sharedInstance.groups.clear()
            self.state = .NotSearchedYet
            self.error = .UnknownError
            
            completion(false)
        }
        
        
        let request = VKAPIManager.groupsGet()
        
        state = .Loading
        error = .None
        
        RequestManager.sharedInstance.activeRequests[key] = request
    }
    
}