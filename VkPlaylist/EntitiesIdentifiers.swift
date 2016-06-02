//
//  EntitiesIdentifiers.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Название дефолтного плейлиста для загрузок
let downloadsPlaylistTitle = "Downloads"

/// Идентификаторы сущностей CoreData
struct EntitiesIdentifiers {
    
    /// Сущность содержащая информацию об оффлайн треке
    static let offlineTrack = "OfflineTrack"
    /// Сущность содержащая информацию о плейлисте
    static let playlist = "Playlist"
    /// Сущность содержащая информацию о треке в плейлисте
    static let trackInPlaylist = "TrackInPlaylist"
    
}