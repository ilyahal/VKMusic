//
//  PlayerManagerDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

protocol PlayerManagerDelegate: class {
    
    /// Менеджер плеера получил новое состояние плеера
    func playerManagerGetNewState(state: PlayerState)
    /// Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem(item: PlayerItem)
    /// Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewTimerProgress(progress: Float)
    
}