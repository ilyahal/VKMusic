//
//  PlayerItemDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

protocol PlayerItemDelegate: class {
    
    /// Элемент плеера загрузил элемент системного плеера
    func playerItemDidLoadAVPlayerItem(item: PlayerItem)
    
}