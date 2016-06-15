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
    func playerManagerGetNewState()
    /// Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem()
    /// Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewProgressValue()
    /// Менеджер плеера получил новое значение прогресса буфферизации
    func playerManagerCurrentItemGetNewBufferingProgressValue()
    /// Менеджер плеера получил новое значение текущего времени
    func playerManagerCurrentItemGetNewCurrentTime()
    /// Менеджер плеера изменил настройку "Отправлять ли музыку в статус"
    func playerManagerShareToStatusSettingDidChange()
    /// Менеджер плеера изменил настройку "Перемешивать ли плейлист"
    func playerManagerShuffleSettingDidChange()
    /// Менеджер плеера изменил настройку "Повторять ли плейлист"
    func playerManagerRepeatTypeDidChange()
    
}