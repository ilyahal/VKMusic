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

    /* Паттерн Singleton */
    
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
    
    /* */
    
    
    private init() {
        myMusic = [Track]()
    }
    
    
    // MARK: Личные аудиозаписи
    
    private(set) var myMusic: [Track]
    
    // Запоминает новый список личных аудиозаписей
    func updateMyMusic(music: [Track]) {
        myMusic = music
    }
    
    // Чистит массив личных аудиозаписей
    func clearMyMusic() {
        myMusic.removeAll()
    }
    
}