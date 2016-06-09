//
//  PlayerState.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Состояние плеера
public enum PlayerState: Int, CustomStringConvertible {
    
    /// Готов к воспоизведению
    case Ready = 0
    /// Воспроизводит сейчас
    case Playing
    /// Стоит на паузе
    case Paused
    /// Загружает
    case Loading
    /// Произошла ошибка
    case Failed
    
    public var description: String {
        get {
            switch self {
            case Ready:
                return "Ready"
            case Playing:
                return "Playing"
            case Failed:
                return "Failed"
            case Paused:
                return "Paused"
            case Loading:
                return "Loading"
            }
        }
    }
    
}