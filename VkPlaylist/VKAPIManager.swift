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
    
    static let applicationID = "5443807" // ID приложения
    static let scope: [VK.Scope] = [ // Права приложения https://vk.com/dev/permissions
        .friends, // Друзья пользователя
        .audio, // Аудиозаписи пользователя
        .status, // Статус пользователя
        .groups, // Группы пользователя
        .offline // Доступ к API в любое время (бессрочный токен)
    ]
    
    
    // Авторизация пользователя
    class func autorize() {
        VK.logOut()
        VK.autorize()
    }
    
    // Деавторизация пользователя
    class func logout() {
        VK.logOut()
    }
    
    // Авторизован ли пользователь
    class var isAuthorized: Bool {
        return VK.state == .Authorized
    }
    
    
    // Получение личных аудиозаписей
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
    
    
    // Поиск аудиозаписей
    class func audioSearch(search: String) -> Request {
        let request = VK.API.Audio.search([
            .q : search, // Поисковый запрос
            .autoComplete : "1", // Автоматическое исправление возможных ошибок
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
    
    
    // Получение списка друзей
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
    
    
    // Получение списка групп
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
    
    
    // Получение аудиозаписей владельца с указанным id
    class func audioGetWithOwnerID(id: Int) -> Request {
        let request = VK.API.Audio.get([
            .ownerId : String(id) // Идентификатор владельца
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
    
    
    // Получение списка рекомендуемых аудиозаписей
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
    
    
    // Получение списка популярных аудиозаписей
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
    
    
    // Получение списка альбомов
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
    
}


// MARK: Парсеры JSON ответов с сервера

private typealias VKJSONParser = VKAPIManager
extension VKJSONParser {
    
    // Парсит ответ на получение аудиозаписей
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
                let id = audio["id"].int
                let title = audio["title"].string
                let date = audio["date"].int
                let duration = audio["duration"].int
                let genre_id = audio["genre_id"].int
                let owner_id = audio["owner_id"].int
                let url = audio["url"].string
                
                let track = Track(artist: artist, lyrics_id: lyrics_id, id: id, title: title, date: date, duration: duration, genre_id: genre_id, owner_id: owner_id, url: url)
                
                trackList.append(track)
            }
        }
        
        return trackList
    }
    
    // Парсит ответ на получение альбомов
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
    
    // Парсит ответ на получение друзей
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
    
    // Парсит ответ на получение групп
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