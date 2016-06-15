//
//  PlayerItem.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import AVFoundation

final class PlayerItem: NSObject {
    
    /// Идентификатор аудиозаписи
    let identifier: String
    /// Делегат аудиозаписи
    weak var delegate: PlayerItemDelegate?
    /// URL элемента плеера в сети
    let URL: NSURL
    /// URL элемента плеера в файловой системе устройства
    var fileURL: NSURL!
    
    /// Активно ли KVO
    var isKVOActive = false
    
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
    
    deinit {
        removeBufferProgressObserver()
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
    
    
    // MARK: Отслеживаение прогресса буфферизации
    
    /// Добавить слушателя для уведомлений о прогрессе буфферизации
    func addBufferProgressObserver() {
        if let playerItem = playerItem where !isKVOActive {
            isKVOActive = true
            playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: nil)
        }
    }
    
    /// Удалить слушателя для уведомлений о прогрессе буфферизации
    func removeBufferProgressObserver() {
        if let playerItem = playerItem where isKVOActive {
            isKVOActive = false
            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
    }
    
    /// Доступная длина
    var availableDuration: Double {
        var availableDuration = 0.0
        
        if let playerItem = playerItem {
            let loadedTimeRanges = playerItem.loadedTimeRanges
            
            if loadedTimeRanges.count > 0 {
                let timeRange = loadedTimeRanges[0].CMTimeRangeValue
                
                let startSeconds = CMTimeGetSeconds(timeRange.start)
                let durationSeconds = CMTimeGetSeconds(timeRange.duration)
                
                availableDuration = startSeconds + durationSeconds
            }
        }
        
        return availableDuration
    }
    
    /// Прогресс буфферизации
    var preloadProgress: Float {
        if isDownloaded {
            return 1
        } else {
            var progress: Float = 0.0
            
            if let playerItem = playerItem {
                if playerItem.status == .ReadyToPlay {
                    let bufferTime = availableDuration
                    
                    if let duration = duration {
                        if duration > 0 {
                            progress = Float(bufferTime) / Float(duration)
                        }
                    }
                }
            }
            
            return progress
        }
    }
    
}


// MARK: NSObject + KVO (Key Value Observing)

private typealias _PlayerItemDelegateNSObjectKVO = PlayerItem
extension _PlayerItemDelegateNSObjectKVO {

    // Вызывается при получении изменений для указанных ключей
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let playerItem = playerItem {
            if playerItem === object {
                if keyPath == "loadedTimeRanges" {
                    if let _ = change?[NSKeyValueChangeNewKey] as? NSArray {
                        delegate?.playerItemDidPreLoadCurrentItemWithProgress(preloadProgress)
                    }
                }
            }
        }
    }

}