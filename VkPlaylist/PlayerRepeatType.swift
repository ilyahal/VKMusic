//
//  PlayerRepeatType.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Возможные типы повторения плейлиста
enum PlayerRepeatType: Int {
    
    /// Не повторять
    case No = -1
    /// Повторять весь плейлист
    case All = 0
    /// Повторять текущую аудиозапись
    case One = 1
    
}