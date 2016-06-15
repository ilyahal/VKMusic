//
//  PlayerItemDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

protocol PlayerItemDelegate: class {

    /// Элемент плеера предзагрузил текущую аудиозапись со следующей величиной
    func playerItemDidPreLoadCurrentItemWithProgress(preloadProgress: Float)
    
}