//
//  PlayerManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import AVFoundation

/// Менеджер воспроизведения
class PlayerManager {
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: PlayerManager? = nil
    }
    
    class var sharedInstance : PlayerManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = PlayerManager()
        }
        
        return Static.instance!
    }
    
    
    private init() {}
    
    
    // MARK: Плеер
    
    /// Плеер
    var player: AVPlayer!
    
    /// Старт аудиозаписи
    func playFile(url: NSURL) {
        if let player = player {
            player.pause()
        }
        
        player = AVPlayer(URL: url)
        player.play()
    }
}