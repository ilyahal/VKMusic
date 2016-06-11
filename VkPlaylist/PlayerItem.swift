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
    /// URL элемента плеера в сети
    let URL: NSURL
    /// URL элемента плеера в файловой системе устройства
    var fileURL: NSURL!
    
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
    
    /// Является ли элемент загруженным
    var isDownloaded = false
    
    /// ID аудиозаписи, для текущего элемента плеера
    var trackID: Int32
    /// ID владельца аудиозаписи, для текущего элемента плеера
    var trackOwnerID: Int32
    
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
        
        trackID = onlineTrack.id
        trackOwnerID = onlineTrack.owner_id
        
        duration = Double(onlineTrack.duration)
        title = onlineTrack.title
        artist = onlineTrack.artist
    }
    
    
    /// Получить элемент системного плеера
    func getPlayerItem() -> AVPlayerItem {
        
        // Если для аудиозаписи текущего элемента плеера существует загруженная копия, получаем на нее ссылку
        if isDownloaded {
            if let offlineTrack = DataManager.sharedInstance.getDownloadedCopyOfATrackIfExistsWithID(trackID, andOwnerID: trackOwnerID) {
                fileURL = NSURL(fileURLWithPath: offlineTrack.url)
            } else {
                isDownloaded = false
                fileURL = nil
            }
        } else {
            if let offlineTrack = DataManager.sharedInstance.getDownloadedCopyOfATrackIfExistsWithID(trackID, andOwnerID: trackOwnerID) {
                isDownloaded = true
                fileURL = NSURL(fileURLWithPath: offlineTrack.url)
            }
        }
        
        // Создаем экземпляр системного плеера
        playerItem = playerItem == nil ? AVPlayerItem(URL: isDownloaded ? fileURL : URL) : AVPlayerItem(asset: playerItem!.asset)
        
        return playerItem!
    }
    
}