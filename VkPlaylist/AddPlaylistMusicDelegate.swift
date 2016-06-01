//
//  AddPlaylistMusicDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

protocol AddPlaylistMusicDelegate: class {
    
    // Вызывается при добавлении трека в плейлист
    func addPlaylistMusicDelegateAddTrack(track: OfflineTrack)
    
}