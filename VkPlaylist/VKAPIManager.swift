//
//  VKAPIManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import SwiftyVK

let VKAPIManagerDidAutorizeNotification = "VKAPIManagerDidAutorizeNotification" // Уведомление о том, что авторизация успешно пройдена
let VKAPIManagerDidUnautorizeNotification = "VKAPIManagerDidUnautorizeNotification" // Уведомление о том, что была произведена деавторизация

let VKAPIManagerDidGetAudioNotification = "VKAPIManagerDidGetAudioNotification" // Уведомление о том, что список личных аудиозаписей был получен
let VKAPIManagerGetAudioNetworkErrorNotification = "VKAPIManagerGetAudioNetworkErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка при подключении к интернету
let VKAPIManagerGetAudioErrorNotification = "VKAPIManagerGetAudioErrorNotification" // Уведомление о том, что при получении личных аудиозаписей произошла ошибка

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
        print("SwiftyVK: LogOut")
        
        VK.autorize()
        print("SwiftyVK: Autorize")
    }
    
    // Деавторизация пользователя
    class func logout() {
        VK.logOut()
        print("SwiftyVK: LogOut")
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
    
//    class func audioGetWithUserID(id: Int) {
//        let request = VK.API.Audio.get([VK.Arg.userId: "\(id)"])
//        request.successBlock = { response in
//            let result = VKJSONParser.parseAudio(response)
//            
//            NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidGetAudioNotification, object: nil, userInfo: ["Audio": result])
//        }
//        request.errorBlock = { error in
//            print("SwiftyVK: audioGet fail \n \(error)")
//        }
//        request.send()
//    }
    
}

private typealias VKJSONParser = VKAPIManager
extension VKJSONParser {
    
    // Парсит ответ на получение аудиозаписей
    private class func parseAudio(audio: JSON) -> [Track] {
        var trackList = [Track]()
        
        let audioList = audio["items"].array
        
        if let audioList = audioList {
            for audio in audioList {
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
}