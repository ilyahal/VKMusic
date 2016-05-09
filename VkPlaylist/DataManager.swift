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
        friends = DataManagerObject<Friend>()
    }
    
    // Удаляем данные при деавторизации
    func clearDataInCaseOfDeavtorization() {
        myMusic.clear()
        searchMusic.clear()
        friends.clear()
    }
    
    
    // Личные аудиозаписи
    let myMusic: DataManagerObject<Track>
    
    // Искомые аудиозаписи
    let searchMusic: DataManagerObject<Track>
    
    // Список друзей
    let friends: DataManagerObject<Friend>
    
}
