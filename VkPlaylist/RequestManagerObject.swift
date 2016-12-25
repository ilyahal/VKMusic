//
//  RequestManagerObject.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// Запрос на сервер
class RequestManagerObject {
    
    /// Ключ запроса
    internal(set) var key: String
    
    
    // Состояние при инициализации
    
    /// Статус по умолчанию
    private let defaultState: State
    /// Ошибка по умолчанию
    private let defaultError: ErrorRequest
    
    
    // Текущее состояние
    
    /// Статус выполнения
    internal(set) var state: State
    /// Ошибка при выполнении
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
    
    
    /// Выполнение запроса без аргументов
    func performRequest(completion: (Bool) -> Void) {
        performRequest([:], withCompletionHandler: completion)
    }
    
    /// Выполнение запроса с аргументами
    func performRequest(parameters: [Argument : AnyObject], withCompletionHandler completion: (Bool) -> Void) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    /// Отменяет выполенение запроса
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
    
    /// Удаление состояние выполнения запроса
    func removeActivState() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        removeObservers() // Удаляем слушателей для оповещений о состоянии выполнения запроса
        removeFromActiveRequests() // Удаляем из списка активных запросов
    }
    
    /// Удаляет слушателей для текущего запроса
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// Удаление запроса из списка активных
    func removeFromActiveRequests() {
        RequestManager.sharedInstance.activeRequests[key] = nil
    }
    
    /// Сбрасывание состояния запроса до состояния инициализации
    func dropState() {
        state = defaultState
        error = defaultError
        
        removeObservers()
    }
    
}


// MARK: Типы данных

private typealias _RequestManagerObjectDataTypes = RequestManagerObject
extension _RequestManagerObjectDataTypes {
    
    /// Состояния выполнения запросов
    enum State {
        
        /// Поиск еще не был выполен (или была ошибка)
        case NotSearchedYet
        /// Результат загружается
        case Loading
        /// Ничего не найдено
        case NoResults
        /// Результат поиска
        case Results
        
    }
    
    /// Ошибки при запросах
    enum ErrorRequest {
        
        /// Нет ошибок
        case None
        /// Проблемы при подключении к интернету
        case NetworkError
        /// Проблемы с доступом
        case AccessError
        /// Неизвестная ошибка
        case UnknownError
        
    }
    
    /// Ключи аргументов запросов
    enum Argument {
        
        /// Поисковый запрос
        case RequestText
        /// Идентификатор альбома
        case AlbumID
        /// Идентификатор пользователя
        case OwnerID
        
    }
    
}