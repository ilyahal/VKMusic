//
//  VKAPIManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import SwiftyVK

// Уведомления о событиях при авторизации
let VKAPIManagerDidAutorizeNotification = "VKAPIManagerDidAutorizeNotification" // Уведомление о том, что авторизация успешно пройдена
let VKAPIManagerDidUnautorizeNotification = "VKAPIManagerDidUnautorizeNotification" // Уведомление о том, что была произведена деавторизация
let VKAPIManagerAutorizationFailedNotification = "VKAPIManagerAutorizationFailedNotification" // Уведомление о том, что при авторизации была ошибка

// Уведомления о событиях при получения личных аудиозаписей
let VKAPIManagerDidGetAudioNotification = "VKAPIManagerDidGetAudioNotification" // Уведомление о том, что список личных аудиозаписей был получен
let VKAPIManagerGetAudioNetworkErrorNotification = "VKAPIManagerGetAudioNetworkErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioErrorNotification = "VKAPIManagerGetAudioErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка

// Уведомления о событиях при получения искомых аудиозаписей
let VKAPIManagerDidSearchAudioNotification = "VKAPIManagerDidSearchAudioNotification" // Уведомление о том, что список искомых аудиозаписей был получен
let VKAPIManagerSearchAudioNetworkErrorNotification = "VKAPIManagerSearchAudioNetworkErrorNotification" // Уведомление о том, что при получении искомых аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerSearchAudioErrorNotification = "VKAPIManagerSearchAudioErrorNotification" // Уведомление о том, что при получении искомых аудиозаписей произошла ошибка

// Уведомления о событиях при получения списка друзей
let VKAPIManagerDidGetFriendsNotification = "VKAPIManagerDidGetFriendsNotification" // Уведомление о том, что список друзей был получен
let VKAPIManagerGetFriendsNetworkErrorNotification = "VKAPIManagerGetFriendsNetworkErrorNotification" // Уведомление о том, что при получении друзей произошла ошибка при подключении к интернету
let VKAPIManagerGetFriendsErrorNotification = "VKAPIManagerGetFriendsErrorNotification" // Уведомление о том, что при получении друзей произошла ошибка

// Уведомления о событиях при получения списка групп
let VKAPIManagerDidGetGroupsNotification = "VKAPIManagerDidGetGroupsNotification" // Уведомление о том, что список групп был получен
let VKAPIManagerGetGroupsNetworkErrorNotification = "VKAPIManagerGetGroupsNetworkErrorNotification" // Уведомление о том, что при получении групп произошла ошибка при подключении к интернету
let VKAPIManagerGetGroupsErrorNotification = "VKAPIManagerGetGroupsErrorNotification" // Уведомление о том, что при получении групп произошла ошибка

// Уведомления о событиях при получения списка друзей
let VKAPIManagerDidGetAudioForOwnerNotification = "VKAPIManagerDidGetAudioForOwnerNotification" // Уведомление о том, что список аудиозаписей указанного пользователя был получен
let VKAPIManagerGetAudioForOwnerNetworkErrorNotification = "VKAPIManagerGetAudioForOwnerNetworkErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioForOwnerAccessErrorNotification = "VKAPIManagerGetAudioForOwnerAccessErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка доступа
let VKAPIManagerGetAudioForOwnerErrorNotification = "VKAPIManagerGetAudioForOwnerErrorNotification" // Уведомление о том, что при получении аудиозаписей указанного пользователя произошла ошибка

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
            if error.domain == "NSURLErrorDomain" && error.code == -1009 { // Если ошибка при подключении к интернету
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
            if error.domain == "NSURLErrorDomain" && error.code == -1009 { // Если ошибка при подключении к интернету
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
            .fields : "photo_200_orig"
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseFriends(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetFriendsNotification, object: nil, userInfo: ["Friends": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && error.code == -1009 { // Если ошибка при подключении к интернету
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetFriendsNetworkErrorNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerGetFriendsErrorNotification, object: nil)
            }
            
            print("SwiftyVK: friendsGet fail \n \(error)")
        }
        request.send()
        
        return request
    }
    
    
    // Получение списка друзей
    class func groupsGet() -> Request {
        let request = VK.API.Groups.get([
            .extended : "1" // Получение полной информации о группах
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseGroups(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetGroupsNotification, object: nil, userInfo: ["Groups": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && error.code == -1009 { // Если ошибка при подключении к интернету
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
            .ownerId: String(id)
        ])
        request.successBlock = { response in
            let result = VKJSONParser.parseAudio(response)
            
            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAudioForOwnerNotification, object: nil, userInfo: ["Audio": result])
        }
        request.errorBlock = { error in
            if error.domain == "NSURLErrorDomain" && error.code == -1009 { // Если ошибка при подключении к интернету
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
    
}

private typealias VKJSONParser = VKAPIManager
extension VKJSONParser {
    
    // Парсит ответ на получение аудиозаписей
    private class func parseAudio(audio: JSON) -> [Track] {
        var trackList = [Track]()
        
        let itemsList = audio["items"].array
        
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