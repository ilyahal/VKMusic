//
//  PlayerManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
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
    
    
    private init() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        miniPlayerViewController = storyboard.instantiateViewControllerWithIdentifier("MiniPlayerViewController") as! MiniPlayerViewController
    }
    
    
    /// Контроллер с мини-плеером
    let miniPlayerViewController: MiniPlayerViewController!
    
    
    /// Воспроизводится ли музыка
    var isPlaying = false {
        didSet {
            miniPlayerViewController.updateControlButton()
        }
    }
    
    /// Отображать ли музыку в статусе
    var isShareToStatus = false
    /// Перемешивать ли плейлист
    var isShuffle = false
    /// Тип перемешивания
    var repeatType = RepeatType.No
    
    
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


// MARK: Типы данных

extension PlayerManager {
    
    /// Возможные типы повторения плейлиста
    enum RepeatType {
        
        /// Не повторять
        case No
        /// Повторять весь плейлист
        case All
        /// Повторять текущую аудиозапись
        case One
        
    }
    
}