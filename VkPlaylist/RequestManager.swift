//
//  RequestManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import SwiftyVK

/// Отвечает за обработку запросов на загрузку данных с сервера VK

class RequestManager {
    
    /* Паттерн Singleton */
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: RequestManager? = nil
    }
    
    class var sharedInstance : RequestManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = RequestManager()
        }
        
        return Static.instance!
    }
    
    /* */
    
    
    private init() {
        activeRequests = [:]
        
        
        getAudioState = State.NotSearchedYet
        getAudioError = ErrorRequest.None
        
        
        searchAudioState = State.NotSearchedYet
        searchAudioError = ErrorRequest.None
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Работа с активными запросами
    
    private var activeRequests: [String : Request]
    
    // Отмена запросов при деавторизации
    func cancelRequestInCaseOfDeavtorization() {
        getAudioRequestCancel()
        searchAudioRequestCancel()
    }
    
    
    // MARK: Получение личных аудиозаписей
    
    private(set) var getAudioState: State
    private(set) var getAudioError: ErrorRequest
    
    
    // MARK: Получение искомых аудиозаписей
    
    private(set) var searchAudioState: State
    private(set) var searchAudioError: ErrorRequest
    
}


// MARK: Типы данных

private typealias RequestManagerDataTypes = RequestManager
extension RequestManagerDataTypes {
    
    // Состояния выполнения запросов
    enum State {
        case NotSearchedYet // Поиск еще не был выполен (или была ошибка)
        case Loading // Результат загружается
        case NoResults // Ничего не найдено
        case Results // Результат поиска
    }
    
    // Ошибки при запросах
    enum ErrorRequest {
        case None // Нет ошибок
        case NetworkError // Проблемы при подключении к интернету
        case UnknownError // Неизвестная ошибка
    }
    
    // Ключи для запросов
    enum requestKeys: String {
        case GetAudio = "getAudio" // Ключ на получение личных аудиозаписей
        case SearchAudio = "searchAudio" // Ключ на получение искомых аудиозаписей
    }
    
}


// MARK: Получение личных аудиозаписей

private typealias RequestManagerGetAudio = RequestManager
extension RequestManagerGetAudio {
    
    func getAudio(completion: (Bool) -> Void) {
        getAudioRequestCancel()
        
        if !Reachability.isConnectedToNetwork() {
            
            // Сохраняем данные
            DataManager.sharedInstance.clearMyMusic()
            getAudioState = .NotSearchedYet
            getAudioError = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.getAudioRemoveObservers()
            self.activeRequests[requestKeys.GetAudio.rawValue] = nil
            
            completion(false)
            
            
            return
        }
        
        // Слушатель для уведомления об успешном завершении получения аудиозаписей
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidGetAudioNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            let myMusicResult = notification.userInfo!["Audio"] as! [Track]
            
            // Сохраняем данные
            DataManager.sharedInstance.updateMyMusic(myMusicResult)
            self.getAudioState = DataManager.sharedInstance.myMusic.count == 0 ? .NoResults : .Results
            self.getAudioError = .None
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.getAudioRemoveObservers()
            self.activeRequests[requestKeys.GetAudio.rawValue] = nil
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.clearMyMusic()
            self.getAudioState = .NotSearchedYet
            self.getAudioError = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.getAudioRemoveObservers()
            self.activeRequests[requestKeys.GetAudio.rawValue] = nil
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerGetAudioErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.clearMyMusic()
            self.getAudioState = .NotSearchedYet
            self.getAudioError = .UnknownError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.getAudioRemoveObservers()
            self.activeRequests[requestKeys.GetAudio.rawValue] = nil
            
            completion(false)
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let request = VKAPIManager.audioGet()
        
        getAudioState = .Loading
        getAudioError = .None
        
        activeRequests[requestKeys.GetAudio.rawValue] = request
    }
    
    // Удаляет слушателей для уведомлений о получении личных аудиозаписей
    private func getAudioRemoveObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerDidGetAudioNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerGetAudioNetworkErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerGetAudioErrorNotification, object: nil)
    }
    
    // Сбрасывает состояние для запроса о личных аудиозаписях
    private func getAudioDropeState() {
        getAudioState = .NotSearchedYet
        getAudioError = .None
        
        getAudioRemoveObservers()
    }
    
    // Отменяет выполнение запроса на получение личных аудиозаписей
    private func getAudioRequestCancel() {
        
        // Если есть активный запрос на получение личных аудиозаписей
        if let activeRequest = activeRequests[requestKeys.GetAudio.rawValue] {
            activeRequest.cancel()
            activeRequests[requestKeys.GetAudio.rawValue] = nil
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            getAudioDropeState()
        }
    }
    
}


// MARK: Получение искомых аудиозаписей

private typealias RequestManagerSearchAudio = RequestManager
extension RequestManagerSearchAudio {
    
    func searchAudio(search: String, withCompletionHandler completion: (Bool) -> Void) {
        searchAudioRequestCancel()
        
        if !Reachability.isConnectedToNetwork() {
            
            // Сохраняем данные
            DataManager.sharedInstance.clearSearchMusic()
            searchAudioState = .NotSearchedYet
            searchAudioError = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.searchAudioRemoveObservers()
            self.activeRequests[requestKeys.SearchAudio.rawValue] = nil
            
            completion(false)
            
            
            return
        }
        
        // Слушатель для уведомления об успешном завершении получения аудиозаписей
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerDidSearchAudioNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            let searchMusicResult = notification.userInfo!["Audio"] as! [Track]
            
            // Сохраняем данные
            DataManager.sharedInstance.updateSearchMusic(searchMusicResult)
            self.searchAudioState = DataManager.sharedInstance.searchMusic.count == 0 ? .NoResults : .Results
            self.searchAudioError = .None
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.searchAudioRemoveObservers()
            self.activeRequests[requestKeys.SearchAudio.rawValue] = nil
            
            completion(true)
        }
        
        // Слушатель для получения уведомления об ошибке при подключении к интернету
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerSearchAudioNetworkErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.clearSearchMusic()
            self.searchAudioState = .NotSearchedYet
            self.searchAudioError = .NetworkError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.searchAudioRemoveObservers()
            self.activeRequests[requestKeys.SearchAudio.rawValue] = nil
            
            completion(false)
        }
        
        // Слушатель для уведомления о других ошибках
        NSNotificationCenter.defaultCenter().addObserverForName(VKAPIManagerSearchAudioErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            
            // Сохраняем данные
            DataManager.sharedInstance.clearSearchMusic()
            self.searchAudioState = .NotSearchedYet
            self.searchAudioError = .UnknownError
            
            // Убираем состояние выполнения запроса
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.searchAudioRemoveObservers()
            self.activeRequests[requestKeys.SearchAudio.rawValue] = nil
            
            completion(false)
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let request = VKAPIManager.audioSearch(search)
        
        searchAudioState = .Loading
        searchAudioError = .None
        
        activeRequests[requestKeys.SearchAudio.rawValue] = request
    }
    
    // Удаляет слушателей для уведомлений о получении искомых аудиозаписей
    private func searchAudioRemoveObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerDidSearchAudioNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerSearchAudioNetworkErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VKAPIManagerSearchAudioErrorNotification, object: nil)
    }
    
    // Сбрасывает состояние для запроса о искомых аудиозаписях
    private func searchAudioDropeState() {
        searchAudioState = .NotSearchedYet
        searchAudioError = .None
        
        searchAudioRemoveObservers()
    }
    
    // Отменяет выполнение запроса на получение искомых аудиозаписей
    private func searchAudioRequestCancel() {
        
        // Если есть активный запрос на получение искомых аудиозаписей
        if let activeRequest = activeRequests[requestKeys.SearchAudio.rawValue] {
            activeRequest.cancel()
            activeRequests[requestKeys.SearchAudio.rawValue] = nil
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            searchAudioDropeState()
        }
    }
    
}