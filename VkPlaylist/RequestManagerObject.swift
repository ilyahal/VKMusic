//
//  RequestManagerObject.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class RequestManagerObject {
    
    private let defaultState: State
    private let defaultError: ErrorRequest
    
    internal(set) var state: State
    internal(set) var error: ErrorRequest
    internal(set) var key: String
    
    init(defaultState: State, defaultError: ErrorRequest, key: String) {
        self.defaultState = defaultState
        self.defaultError = defaultError
        state = self.defaultState
        error = self.defaultError
        self.key = key
    }
    
    deinit {
        removeObservers()
    }
    
    
    // Выполнение запроса
    func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    // Удаляет слушателей для текущего запроса
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Сбрасывает состояние запроса
    func dropState() {
        state = defaultState
        error = defaultError
        
        removeObservers()
    }
    
    func removeFromActiveRequests() {
        RequestManager.sharedInstance.activeRequests[key] = nil
    }
    
    // Отменяет выполенение запроса
    func cancel() {
        if let activeRequest = RequestManager.sharedInstance.activeRequests[key] {
            activeRequest.cancel()
            removeFromActiveRequests()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            dropState()
        }
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
        case UnknownError // Неизвестная ошибка
    }
    
    // Ключи аргументов запросов
    enum Argument {
        case RequestText
    }
    
}