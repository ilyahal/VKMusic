//
//  VKAPIManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import SwiftyVK

/// Отвечает за взаимодействие с VK
class VKAPIManager {
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: VKAPIManager? = nil
    }
    
    class var sharedInstance : VKAPIManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = VKAPIManager()
        }
        
        return Static.instance!
    }
    
    
    private init() {}
    
    
    /// ID приложения
    static let applicationID = "5443807"
    /// Права приложения
    static let scope: [VK.Scope] = [ // https://vk.com/dev/permissions
        .friends, // Друзья пользователя
        .audio, // Аудиозаписи пользователя
        .status, // Статус пользователя
        .groups, // Группы пользователя
        .offline // Доступ к API в любое время (бессрочный токен)
    ]
    
    
    /// Авторизация пользователя
    class func autorize() {
        VK.logOut()
        VK.autorize()
    }
    
    /// Деавторизация пользователя
    class func logout() {
        VK.logOut()
    }
    
    /// Авторизован ли пользователь
    class var isAuthorized: Bool {
        return VK.state == .Authorized
    }
    
    
    /// Получение личных аудиозаписей
    class func audioGet() -> Request {
        let request = VK.API.Audio.get()
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAudioNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету (-1009) или превышен лимит времени на запрос (-1001)
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGet fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение слов с указанным id
    class func audioGetLyrics(lyrics_id: Int) -> Request {
        let request = VK.API.Audio.getLyrics([
            .lyricsId : "\(lyrics_id)" // Идентификатор слов
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseLyrics(response)
            VKAPIManager.sharedInstance.lyricsWereReceived(result, withID: lyrics_id)
        }
        request.errorBlock = { error in
            VKAPIManager.sharedInstance.lyricsErrorWithID(lyrics_id)
            
            print("SwiftyVK: audioGetLyrics fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Поиск аудиозаписей
    class func audioSearch(search: String) -> Request {
        let request = VK.API.Audio.search([
            .q : search, // Поисковый запрос
            .sort : "2", // Сортировка по популярности
            .count : "100" // Количество аудиозаписей, которые вернет запрос
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidSearchAudioNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerSearchAudioNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerSearchAudioErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioSearch fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка альбомов
    class func audioGetAlbums() -> Request {
        let request = VK.API.Audio.getAlbums()
        request.successBlock = { response in
            let result = VKJSONParser.parseAlbums(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAlbumsNotification, object: nil, userInfo: ["Albums": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету (-1009) или превышен лимит времени на запрос (-1001)
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAlbumsNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAlbumsErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGetAlbums fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка аудиозаписей указанного альбома альбомов
    class func audioGetWithAlbumID(id: Int) -> Request {
        let request = VK.API.Audio.get([
            .albumId : "\(id)" // Идентификатор альбома
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAudioForAlbumNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForAlbumNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForAlbumErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGetWithAlbumID fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка друзей
    class func friendsGet() -> Request {
        let request = VK.API.Friends.get([
            .fields : "photo_200_orig" // Получение фотографии пользователя
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseFriends(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetFriendsNotification, object: nil, userInfo: ["Friends": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetFriendsNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetFriendsErrorNotification, object: nil)
            }
            
            print("SwiftyVK: friendsGet fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка групп
    class func groupsGet() -> Request {
        let request = VK.API.Groups.get([
            .extended : "1" // Получение полной информации о группах
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseGroups(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetGroupsNotification, object: nil, userInfo: ["Groups": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetGroupsNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetGroupsErrorNotification, object: nil)
            }
            
            print("SwiftyVK: groupsGet fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение аудиозаписей владельца с указанным id
    class func audioGetWithOwnerID(id: Int) -> Request {
        let request = VK.API.Audio.get([
            .ownerId : "\(id)" // Идентификатор владельца
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAudioForOwnerNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForOwnerNetworkErrorNotification, object: nil)
            } else if error.domain == "APIError" && error.code == 201 { // Если аудиозаписи владельца закрыты
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForOwnerAccessErrorNotification, object: nil)
            } else if error.domain == "APIError" && error.code == 15 { // Если аудиозаписи владельца отключены
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForOwnerAccessErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetAudioForOwnerErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGetWithOwnerID fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка рекомендуемых аудиозаписей
    class func audioGetRecommendations() -> Request {
        let request = VK.API.Audio.getRecommendations([
            .count : "100", // Количество рекомендуемых аудиозаписей
            .shuffle : "1" // Случайный порядок
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetRecommendationsAudioNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету (-1009) или превышен лимит времени на запрос (-1001)
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetRecommendationsAudioNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetRecommendationsAudioErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGetRecommendations fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    /// Получение списка популярных аудиозаписей
    class func audioGetPopular() -> Request {
        let request = VK.API.Audio.getPopular([
            .onlyEng : "1", // Только зарубежные
            .count : "100", // Количество популярных аудиозаписей
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetPopularAudioNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && (error.code == -1009 || error.code == -1001) { // Если ошибка при подключении к интернету (-1009) или превышен лимит времени на запрос (-1001)
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetPopularAudioNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetPopularAudioErrorNotification, object: nil)
            }
            
            print("SwiftyVK: audioGetPopular fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    // MARK: Получение слов аудиозаписи
    
    /// Делегаты запроса на получение слов аудиозаписи
    private var lyricsDelegates = [VKAPIManagerLyricsDelegate]()
    
    /// Добавление нового делегата для запроса на получение слов аудиозаписи
    func addLyricsDelegate(delegate: VKAPIManagerLyricsDelegate) {
        if let _ = lyricsDelegates.indexOf({ $0 === delegate}) {
            return
        }
        
        lyricsDelegates.append(delegate)
    }
    
    /// Удаление делегата для запроса на получение слов аудиозаписи
    func deleteLyricsDelegate(delegate: VKAPIManagerLyricsDelegate) {
        if let index = lyricsDelegates.indexOf({ $0 === delegate}) {
            lyricsDelegates.removeAtIndex(index)
        }
    }
    
    /// Запроса на получение слов аудиозаписи успешно завершен
    func lyricsWereReceived(lyrics: String, withID lyricsID: Int) {
        lyricsDelegates.forEach { delegate in
            delegate.VKAPIManagerLyricsDelegateGetLyrics(lyrics, forLyricsID: lyricsID)
        }
    }
    
    /// Запрос на получение слов был завершен с ошибкой
    func lyricsErrorWithID(lyricsID: Int) {
        lyricsDelegates.forEach { delegate in
            delegate.VKAPIManagerLyricsDelegateErrorLyricsWithID(lyricsID)
        }
    }
    
}


// MARK: Парсеры JSON ответов с сервера

private typealias VKJSONParser = VKAPIManager
extension VKJSONParser {
    
    /// Парсит ответ на получение аудиозаписей
    private class func parseAudio(audio: JSON) -> [Track] {
        var trackList = [Track]()
        
        let itemsList: [JSON]?
        
        if let list = audio["items"].array {
            itemsList = list
        } else {
            itemsList = audio.array
        }
        
        if let itemsList = itemsList {
            for audio in itemsList {
                let artist = audio["artist"].string
                let lyrics_id = audio["lyrics_id"].int
                let id = audio["id"].int32
                let title = audio["title"].string
                let duration = audio["duration"].int32
                let owner_id = audio["owner_id"].int32
                let url = audio["url"].string
                
                let track = Track(artist: artist, lyrics_id: lyrics_id, id: id, title: title, duration: duration, owner_id: owner_id, url: url)
                
                trackList.append(track)
            }
        }
        
        return trackList
    }
    
    /// Парсит ответ на получение слов аудиозаписи
    private class func parseLyrics(lyrics: JSON) -> String {
        if let result = lyrics["text"].string {
            return result
        } else {
            return ""
        }
    }
    
    /// Парсит ответ на получение альбомов
    private class func parseAlbums(albums: JSON) -> [Album] {
        var albumList = [Album]()
        
        let itemsList = albums["items"].array
        
        if let itemsList = itemsList {
            for item in itemsList {
                let id = item["id"].int
                let title = item["title"].string
                
                let album = Album(id: id, title: title)
                
                albumList.append(album)
            }
        }
        
        return albumList
    }
    
    /// Парсит ответ на получение друзей
    private class func parseFriends(friends: JSON) -> [Friend] {
        var friendList = [Friend]()
        
        let itemsList = friends["items"].array
        
        if let itemsList = itemsList {
            for item in itemsList {
                let id = item["id"].int
                let last_name = item["last_name"].string
                let photo_200_orig = item["photo_200_orig"].string
                let first_name = item["first_name"].string
                
                let friend = Friend(id: id, last_name: last_name, photo_200_orig: photo_200_orig, first_name: first_name)
                
                friendList.append(friend)
            }
        }
        
        return friendList
    }
    
    /// Парсит ответ на получение групп
    private class func parseGroups(groups: JSON) -> [Group] {
        var groupList = [Group]()
        
        let itemsList = groups["items"].array
        
        if let itemsList = itemsList {
            for item in itemsList {
                let id = item["id"].int
                let name = item["name"].string
                let photo_200 = item["photo_200"].string
                
                let group = Group(id: id, name: name, photo_200: photo_200)
                
                groupList.append(group)
            }
        }
        
        return groupList
    }
    
}