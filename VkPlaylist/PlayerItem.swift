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
    /// Загружен ли элемент системного плеера
    var isDidLoad = false
    /// Название аудиозаписи (опционально)
    var localTitle : String?
    /// URL аудиозаписи
    let URL: NSURL
    
    /// Элемент системного плеера
    var playerItem: AVPlayerItem?
    
    // MARK: Метаданные
    
    /// Длина аудиозаписи
    var duration: Double?
    /// Текущее время аудиозаписи
    var currentTime: Double?
    /// Название аудиозаписи
    var title: String?
    /// Имя исполнителя аудиозаписи
    var artist: String?
    /// Обложка аудиозаписи
    var artwork: UIImage?
    
    
    init(URL : NSURL, localTitle : String? = nil) {
        self.URL = URL
        self.identifier = NSUUID().UUIDString // Генерация универсального уникального идентификатора
        self.localTitle = localTitle
        
        // Если это локальный файл
        if let _ = URL.filePathURL {
            configureMetadata()
        }
    }
    
    
    // MARK: Публичные методы
    
    /// Загрузить элемент плеера
    func loadPlayerItem() {
        if let playerItem = playerItem {
            refreshPlayerItem(playerItem.asset)
            delegate?.playerItemDidLoadAVPlayerItem(self)
            
            return
        } else if isDidLoad { // ???
            return
        } else {
            isDidLoad = true
        }
        
        loadAsync { asset in
            self.validateAsset(asset)
            self.refreshPlayerItem(asset)
            self.delegate?.playerItemDidLoadAVPlayerItem(self)
        }
    }
    
    /// Создать новый элемент системного плеера с указанными ресурсами
    func refreshPlayerItem(asset : AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        updateTime()
    }
    
    /// Обновить значения текущего времени аудиозаписи и длины аудиозаписи для текущего элемента
    func updateTime() {
        if let playerItem = playerItem {
            duration = CMTimeGetSeconds(playerItem.asset.duration)
            currentTime = CMTimeGetSeconds(playerItem.currentTime())
        }
    }
    
    
    // MARK: Приватные методы
    
    /// Валидация загруженных ресурсов
    func validateAsset(asset: AVURLAsset) {
        var error: NSError?
        
        asset.statusOfValueForKey("duration", error: &error)
        if let error = error {
            var message = "\n\n***** Player fatal error*****\n\n"
            if error.code == -1022 {
                message += "It looks like you're using Xcode 7 and due to an App Transport Security issue (absence of SSL-based HTTP) the asset cannot be loaded from the specified URL: \"\(URL)\".\nTo fix this issue, append the following to your .plist file:\n\n<key>NSAppTransportSecurity</key>\n<dict>\n\t<key>NSAllowsArbitraryLoads</key>\n\t<true/>\n</dict>\n\n"
                fatalError(message)
            } else {
                fatalError("\(message)\(error.description)\n\n")
            }
        }
    }
    
    /// Загрузить асинхронно информацию о длительности аудиозаписи
    func loadAsync(completion: (asset: AVURLAsset) -> ()) {
        let asset = AVURLAsset(URL: self.URL, options: nil)
        
        asset.loadValuesAsynchronouslyForKeys(["duration"]) {
            dispatch_async(dispatch_get_main_queue()) {
                completion(asset: asset)
            }
        }
    }
    
    /// Получение метаданных для элемента
    func configureMetadata() {
        let metadataItemArray = AVPlayerItem(URL: URL).asset.commonMetadata // Массив доступных метаданных элемента
        
        for metadataItem in metadataItemArray {
            metadataItem.loadValuesAsynchronouslyForKeys([AVMetadataKeySpaceCommon]) {
                switch metadataItem.commonKey {
                case "title"? :
                    self.title = metadataItem.value as? String
                case "artist"? :
                    self.artist = metadataItem.value as? String
                case "artwork"? :
                    self.processArtwork(forMetadataItem: metadataItem)
                default:
                    break
                }
            }
        }
    }
    
    /// Обработка обложки из метаданных
    func processArtwork(forMetadataItem item: AVMetadataItem) {
        guard let value = item.value else {
            return
        }
        
        let copiedValue: AnyObject = value.copyWithZone(nil)
        
        if let dictionary = copiedValue as? [NSObject : AnyObject] {
            // Пространство ключей AVMetadataKeySpaceID3
            
            if let imageData = dictionary["data"] as? NSData {
                artwork = UIImage(data: imageData)
            }
        } else if let data = copiedValue as? NSData {
            // Пространство ключей AVMetadataKeySpaceiTunes
            
            artwork = UIImage(data: data)
        }
    }
}