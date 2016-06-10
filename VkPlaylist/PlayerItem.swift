//
//  PlayerItem.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import AVFoundation

final class PlayerItem {
    
    /// Идентификатор аудиозаписи
    let identifier: String
    /// Делегат аудиозаписи
    weak var delegate: PlayerItemDelegate?
    /// URL аудиозаписи
    let URL: NSURL
    
    /// Элемент системного плеера
    var playerItem: AVPlayerItem?
    /// Текущее время аудиозаписи
    var currentTime: Double? {
        if let playerItem = playerItem {
            return CMTimeGetSeconds(playerItem.currentTime())
        } else {
            return nil
        }
    }
    
    /// Длина аудиозаписи
    var duration: Double?
    /// Название аудиозаписи
    var title: String?
    /// Имя исполнителя аудиозаписи
    var artist: String?
    /// Обложка аудиозаписи
    var artwork: UIImage?
    
    
    init(onlineTrack: Track) {
        identifier = NSUUID().UUIDString
        
        URL = NSURL(string: onlineTrack.url)!
        duration = Double(onlineTrack.duration)
        title = onlineTrack.title
        artist = onlineTrack.artist
    }
    
    
    /// Получить элемент системного плеера
    func getPlayerItem() -> AVPlayerItem {
        playerItem = playerItem == nil ? AVPlayerItem(URL: URL) : AVPlayerItem(asset: playerItem!.asset)
        return playerItem!
    }
    
}