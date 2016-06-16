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
    /// Элемент плеера получил слова для аудиозаписи
    func playerItem(playerItem: PlayerItem, didGetLyrics lyrics: String)
    /// Элемент плеера получил ошибку при загрузке слов аудиозаписи
    func playerItemGetErrorWhenGetLyrics(playerItem: PlayerItem)
    
}