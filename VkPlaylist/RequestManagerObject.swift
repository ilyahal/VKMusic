//
//  RequestManagerObject.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class RequestManagerObject {
    
    internal(set) var key: String // Ключ запроса
    
    // Состояние при инициализации
    private let defaultState: State
    private let defaultError: ErrorRequest
    
    // Текущее состояние
    internal(set) var state: State
    internal(set) var error: ErrorRequest
    
    
    init(defaultState: State, defaultError: ErrorRequest, key: String) {
        self.key = key
        
        self.defaultState = defaultState
        state = self.defaultState
        
        self.defaultError = defaultError
        error = self.defaultError
    }
    
    deinit {
        removeObservers()
    }
    
    
    // Выполнение запроса без аргументов
    func performRequest(completion: (Bool) -> Void) {
        performRequest([:], withCompletionHandler: completion)
    }
    
    // Выполнение запроса с аргументами
    func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    // Отменяет выполенение запроса
    func cancel() -> Bool {
        if let activeRequest = RequestManager.sharedInstance.activeRequests[key] {
            activeRequest.cancel() // Отменяем выполнение запроса
            removeFromActiveRequests() // Удаляем запрос из списка активных
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            dropState() // Сбрасываем до состояние при инициализации
            
            return true
        }
        
        return false
    }
    
    // Удаление состояние выполнения запроса
    func removeActivState() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        removeObservers() // Удаляем слушателей для оповещений о состоянии выполнения запроса
        removeFromActiveRequests() // Удаляем из списка активных запросов
    }
    
    // Удаляет слушателей для текущего запроса
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Удаление запроса из списка активных
    func removeFromActiveRequests() {
        RequestManager.sharedInstance.activeRequests[key] = nil
    }
    
    // Сбрасывание состояния запроса до состояния инициализации
    func dropState() {
        state = defaultState
        error = defaultError
        
        removeObservers()
    }
    
}


// MARK: Типы данных

private typealias RequestManagerObjectDataTypes = RequestManagerObject
extension RequestManagerObjectDataTypes {
    
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
        case AccessError // Проблемы с доступом
        case UnknownError // Неизвестная ошибка
    }
    
    // Ключи аргументов запросов
    enum Argument {
        case RequestText // Поисковый запрос
        case AlbumID // Идентификатор альбома
        case OwnerID // Идентификатор пользователя
    }
    
}