//
//  AddPlaylistMusicDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Делегат ViewController "Добавление аудиозаписей в плейлист"
protocol AddPlaylistMusicDelegate: class {
    
    /// Добавить аудиозапись в плейлист
    func addPlaylistMusicDelegateAddTrack(track: OfflineTrack)
    
}