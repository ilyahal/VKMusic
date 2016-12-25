//
//  RequestManager.swift
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
import SwiftyVK

/// Отвечает за обработку запросов на загрузку данных с сервера VK
class RequestManager {
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: RequestManager? = nil
    }
    
    class var sharedInstance: RequestManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = RequestManager()
        }
        
        return Static.instance!
    }
    
    private init() {
        activeRequests = [:]
        
        getAudio = GetAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetAudio)
        searchAudio = SearchAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.SearchAudio)
        getAlbums = GetAlbums(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetAlbums)
        getAlbumAudio = GetAlbumAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetAlbumAudio)
        getFriends = GetFriends(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetFriends)
        getGroups = GetGroups(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetGroups)
        getOwnerAudio = GetOwnerAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetOwnerAudio)
        getRecommendationsAudio = GetRecommendationsAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetRecommendationsAudio)
        getPopularAudio = GetPopularAudio(defaultState: .NotSearchedYet, defaultError: .None, key: requestKeys.GetPopularAudio)
    }
    
    
    // MARK: Работа с активными запросами
    
    /// Активные запросы
    var activeRequests: [String : Request]
    
    /// Отмена запросов при деавторизации
    func userDidUnautorize() {
        getAudio.cancel()
        getAudio.dropState()
        searchAudio.cancel()
        searchAudio.dropState()
        getAlbums.cancel()
        getAlbums.dropState()
        getAlbumAudio.cancel()
        getAlbumAudio.dropState()
        getFriends.cancel()
        getFriends.dropState()
        getGroups.cancel()
        getGroups.dropState()
        getOwnerAudio.cancel()
        getOwnerAudio.dropState()
        getRecommendationsAudio.cancel()
        getRecommendationsAudio.dropState()
        getPopularAudio.cancel()
        getPopularAudio.dropState()
    }
    
    
    /// Получение личных аудиозаписей
    let getAudio: RequestManagerObject
    
    /// Получение искомых аудиозаписей
    let searchAudio: RequestManagerObject
    
    /// Получение альбомов
    let getAlbums: RequestManagerObject
    
    /// Получение аудиозаписей из альбома
    let getAlbumAudio: RequestManagerObject
    
    /// Получение друзей
    let getFriends: RequestManagerObject
    
    /// Получение групп
    let getGroups: RequestManagerObject
    
    /// Получение аудиозаписей владельца
    let getOwnerAudio: RequestManagerObject
    
    /// Получение рекомендуемых аудиозаписей
    let getRecommendationsAudio: RequestManagerObject
    
    /// Получение популярных аудиозаписей
    let getPopularAudio: RequestManagerObject
    
}


// MARK: Типы данных

private typealias _RequestManagerDataTypes = RequestManager
extension _RequestManagerDataTypes {
    
    /// Ключи для запросов
    struct requestKeys {
        
        /// Ключ на получение личных аудиозаписей
        static let GetAudio = "getAudio"
        /// Ключ на получение искомых аудиозаписей
        static let SearchAudio = "searchAudio"
        /// Ключ на получение списка альбомов
        static let GetAlbums = "getAlbums"
        /// Ключ на получение списка аудиозаписей альбома
        static let GetAlbumAudio = "getAlbumAudio"
        /// Ключ на получение списка друзей
        static let GetFriends = "getFriends"
        /// Ключ на получение списка групп
        static let GetGroups = "getGroups"
        /// Ключ на получение списка аудиозаписей пользователя
        static let GetOwnerAudio = "getOwnerAudio"
        /// Ключ на получение рекомендуемых аудиозаписей
        static let GetRecommendationsAudio = "getRecommendationsAudio"
        /// Ключ на получение популярных аудиозаписей
        static let GetPopularAudio = "getPopularAudio"
        
    }
    
}