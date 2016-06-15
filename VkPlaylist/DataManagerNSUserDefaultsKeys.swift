//
//  DataManagerNSUserDefaultsKeys.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 15.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Ключи NSUserDefaults
struct DataManagerNSUserDefaultsKeys {
    
    /// Первый запуск программы (Bool)
    static let firstTime = "FirstTime"
    /// Идентификатор для нового плейлиста (Int)
    static let playlistID = "PlaylistID"
    
    
    // Настройки приложения
    
    /// Оповещать ли при удалении о наличии в плейлистах (Bool)
    static let warningWhenDeletingOfExistenceInPlaylists = "WarningWhenDeletingOfExistenceInPlaylists"
    
    
    // Настройки плеера
    
    /// Тип повторения плейлиста (Int)
    static let repeatType = "RepeatType"
    
}