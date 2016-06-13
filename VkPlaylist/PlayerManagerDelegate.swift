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
    /// Менеджер плеера получил новое значение текущего времени
    func playerManagerCurrentItemGetNewCurrentTime(currentTime: Double)
    /// Менеджер плеера изменил настройку "Отправлять ли музыку в статус"
    func playerManagerShareToStatusSettingChangedTo(isShareToStatus: Bool)
    /// Менеджер плеера изменил настройку "Перемешивать ли плейлист"
    func playerManagerShuffleSettingChangedTo(isShuffle: Bool)
    /// Менеджер плеера изменил настройку "Повторять ли плейлист"
    func playerManagerRepeatTypeDidChange(type: PlayerRepeatType)
    
}