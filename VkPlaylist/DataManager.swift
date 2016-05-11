//
//  DataManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Отвечает за взаимодействие с данными, загруженными на устройство

class DataManager {

    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: DataManager? = nil
    }
    
    class var sharedInstance : DataManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = DataManager()
        }
        
        return Static.instance!
    }
    
    
    private init() {
        myMusic = DataManagerObject<Track>()
        searchMusic = DataManagerObject<Track>()
        albums = DataManagerObject<Album>()
        friends = DataManagerObject<Friend>()
        groups = DataManagerObject<Group>()
        ownerMusic = DataManagerObject<Track>()
        recommendationsMusic = DataManagerObject<Track>()
        popularMusic = DataManagerObject<Track>()
    }
    
    // Удаляем данные при деавторизации
    func clearDataInCaseOfDeavtorization() {
        myMusic.clear()
        searchMusic.clear()
        albums.clear()
        friends.clear()
        groups.clear()
        ownerMusic.clear()
        recommendationsMusic.clear()
        popularMusic.clear()
    }
    
    
    // Личные аудиозаписи
    let myMusic: DataManagerObject<Track>
    
    // Искомые аудиозаписи
    let searchMusic: DataManagerObject<Track>
    
    // Список альбомов
    let albums: DataManagerObject<Album>
    
    // Список друзей
    let friends: DataManagerObject<Friend>
    
    // Список групп
    let groups: DataManagerObject<Group>
    
    // Аудиозаписи владельца
    let ownerMusic: DataManagerObject<Track>
    
    // Рекомендуемые аудиозаписи
    let recommendationsMusic: DataManagerObject<Track>
    
    // Популярные аудиозаписи
    let popularMusic: DataManagerObject<Track>
    
}
