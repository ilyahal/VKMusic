//
//  PlayerItem.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import AVFoundation
import SwiftyVK

final class PlayerItem: NSObject {
    
    /// Идентификатор аудиозаписи
    let identifier: String
    /// Делегат аудиозаписи
    weak var delegate: PlayerItemDelegate?
    /// URL элемента плеера в сети
    let URL: NSURL?
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
    
    /// Идентификатор слов
    var lyricsID: Int?
    /// Запрос на получение слов аудиозаписи
    var lyricsRequest: Request?
    
    /// Загружается ли обложка
    var isArtworkDidLoad = false
    
    /// Длина аудиозаписи
    var duration: Double?
    /// Название аудиозаписи
    var title: String?
    /// Имя исполнителя аудиозаписи
    var artist: String?
    /// Обложка аудиозаписи
    var artwork: UIImage?
    /// Слова аудиозаписи
    var lyrics: String?
    
    
    init(onlineTrack: Track) {
        identifier = NSUUID().UUIDString
        
        URL = NSURL(string: onlineTrack.url)!
        
        trackID = onlineTrack.id
        trackOwnerID = onlineTrack.owner_id
        
        duration = Double(onlineTrack.duration)
        title = onlineTrack.title
        artist = onlineTrack.artist
        
        lyricsID = onlineTrack.lyrics_id
    }
    
    init(offlineTrack: OfflineTrack) {
        identifier = NSUUID().UUIDString
        
        URL = nil
        isDownloaded = true
        
        trackID = offlineTrack.id
        trackOwnerID = offlineTrack.ownerID
        
        duration = Double(offlineTrack.duration)
        title = offlineTrack.title
        artist = offlineTrack.artist
    }
    
    deinit {
        lyricsRequest?.cancel()
        VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
        removeBufferProgressObserver()
    }
    
    
    /// Получить элемент системного плеера
    func getPlayerItem() -> AVPlayerItem {
        
        // Если для аудиозаписи текущего элемента плеера существует загруженная копия, получаем на нее ссылку
        if isDownloaded {
            if let offlineTrack = DataManager.sharedInstance.getDownloadedCopyOfATrackIfExistsWithID(trackID, andOwnerID: trackOwnerID) {
                fileURL = NSURL(fileURLWithPath: offlineTrack.url)
                if let artwork = offlineTrack.artwork {
                    self.artwork = UIImage(data: artwork)
                }
                lyrics = offlineTrack.lyrics
            } else {
                isDownloaded = false
                fileURL = nil
                artwork = nil
                lyrics = nil
            }
        } else {
            if let offlineTrack = DataManager.sharedInstance.getDownloadedCopyOfATrackIfExistsWithID(trackID, andOwnerID: trackOwnerID) {
                isDownloaded = true
                fileURL = NSURL(fileURLWithPath: offlineTrack.url)
                if let artwork = offlineTrack.artwork {
                    self.artwork = UIImage(data: artwork)
                }
                lyrics = offlineTrack.lyrics
            }
        }
        
        // Создаем экземпляр системного плеера
        playerItem = playerItem == nil ? AVPlayerItem(URL: isDownloaded ? fileURL : URL!) : AVPlayerItem(asset: playerItem!.asset)
        
        return playerItem!
    }
    
    
    // MARK: Отслеживаение прогресса буфферизации
    
    /// Добавить слушателя для уведомлений о прогрессе буфферизации
    func addBufferProgressObserver() {
        if let playerItem = playerItem where !isKVOActive {
            isKVOActive = true
            playerItem.addObserver(self, forKeyPath: PlayerItemKVOKeys.loadedTimeRanges, options: .New, context: nil)
        }
    }
    
    /// Удалить слушателя для уведомлений о прогрессе буфферизации
    func removeBufferProgressObserver() {
        if let playerItem = playerItem where isKVOActive {
            isKVOActive = false
            playerItem.removeObserver(self, forKeyPath: PlayerItemKVOKeys.loadedTimeRanges)
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
    
    
    // MARK: Получение слов аудиозаписи
    
    /// Отправить запрос на получение слов аудиозаписи
    func getLyrics() {
        guard lyrics == nil && lyricsRequest == nil, let lyricsID = lyricsID else {
            return
        }
        
        VKAPIManager.sharedInstance.addLyricsDelegate(self)
        lyricsRequest = VKAPIManager.audioGetLyrics(lyricsID)
    }
    
    
    // MARK: Получение обложки аудиозаписи
    
    /// Отправить запрос на получение обложки аудиозаписи
    func getArtwork() {
        guard !isArtworkDidLoad && artwork == nil, let playerItem = playerItem else {
            return
        }
        
        isArtworkDidLoad = true
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue) {
            let metadataArray = playerItem.asset.commonMetadata
            
            for metadataItem in metadataArray {
                metadataItem.loadValuesAsynchronouslyForKeys(["artwork"]) {
                    if let value = metadataItem.value {
                        let copiedValue: AnyObject = value.copyWithZone(nil)
                        
                        if let dictionary = copiedValue as? [NSObject : AnyObject] {
                            // AVMetadataKeySpaceID3
                            
                            if let imageData = dictionary["data"] as? NSData {
                                dispatch_async(dispatch_get_main_queue()) {
                                    let artwork = UIImage(data: imageData)
                                    
                                    if let artwork = artwork {
                                        self.artwork = artwork
                                        self.delegate?.playerItem(self, didGetArtwork: artwork)
                                    }
                                }
                            }
                        } else if let data = copiedValue as? NSData{
                            // AVMetadataKeySpaceiTunes
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let artwork = UIImage(data: data)
                                
                                if let artwork = artwork {
                                    self.artwork = artwork
                                    self.delegate?.playerItem(self, didGetArtwork: artwork)
                                }
                            }
                        }
                    }
                }
            }
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
                if keyPath == PlayerItemKVOKeys.loadedTimeRanges {
                    if let _ = change?[NSKeyValueChangeNewKey] as? NSArray {
                        delegate?.playerItemDidPreLoadCurrentItemWithProgress(preloadProgress)
                    }
                }
            }
        }
    }

}


// MARK: VKAPIManagerLyricsDelegate

extension PlayerItem: VKAPIManagerLyricsDelegate {
    
    // VKAPIManager получил слова с указанным id
    func VKAPIManagerLyricsDelegateGetLyrics(lyrics: String, forLyricsID lyricsID: Int) {
        if let _lyricsID = self.lyricsID where _lyricsID == lyricsID {
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            lyricsRequest = nil
            
            self.lyrics = lyrics == "" ? nil : lyrics
            
            delegate?.playerItem(self, didGetLyrics: lyrics)
        }
    }
    
    // VKAPIManager получил ошибку при получении слов с указанным id
    func VKAPIManagerLyricsDelegateErrorLyricsWithID(lyricsID: Int) {
        if let _lyricsID = self.lyricsID where _lyricsID == lyricsID {
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            lyricsRequest = nil
            
            lyrics = nil
            
            delegate?.playerItemGetErrorWhenGetLyrics(self)
        }
    }
    
}