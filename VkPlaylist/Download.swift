//
//  Download.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import SwiftyVK

/// Загрузка аудиозаписи
class Download: NSObject {
    
    /// Загружаемая аудиозапись
    var track: Track
    /// Ссылка по которой производится загрузка
    var url: NSURL
    
    /// Скачивается ли сейчас
    var isDownloading = false
    /// Находится ли в очереди на загрузку
    var inQueue = false
    
    /// Всего байт записано
    var totalBytesWritten: Int64 = 0
    /// Всего байт надо записать
    var totalBytesExpectedToWrite: Int64?
    /// Прогресс выполнения загрузки
    var progress: Float {
        guard let totalBytesExpectedToWrite = totalBytesExpectedToWrite else {
            return 0
        }
        
        return Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }
    /// Размер загружаемого файла
    var totalSize: String? {
        guard let totalBytesExpectedToWrite = totalBytesExpectedToWrite else {
            return nil
        }
        
        return NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: .Binary)
    }
    
    /// Задание на загрузку
    var downloadTask: NSURLSessionDownloadTask?
    /// Данные для продолжения загрузки после паузы
    var resumeData: NSData?
    
    
    init?(track: Track) {
        self.track = track
        
        if let URLObject = NSURL(string: track.url) {
            self.url = URLObject
        } else {
            return nil
        }
    }
    
    
    /// Слова аудиозаписи
    var lyrics = ""
    /// Запрос на получение слов аудиозаписи
    var lyricsRequest: Request?
    /// Получаются ли слова аудиозаписи в данный момент
    var isLyricsDownloads = false
    
    
    /// Отправить запрос на получение слов аудиозаписи
    func getLyrics() {
        if let lyrics_id = track.lyrics_id {
            isLyricsDownloads = true
            
            VKAPIManager.sharedInstance.addLyricsDelegate(self)
            VKAPIManager.audioGetLyrics(lyrics_id)
        }
    }
    
    /// Отменить запрос на получение слов аудиозаписи
    func cancelGetLyrics() {
        isLyricsDownloads = false
        
        lyricsRequest?.cancel()
        lyricsRequest = nil
        VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
    }
    
}


// MARK: VKAPIManagerLyricsDelegate

extension Download: VKAPIManagerLyricsDelegate {
    
    // VKAPIManager получил слова с указанным id
    func VKAPIManagerLyricsDelegateGetLyrics(lyrics: String, forLyricsID lyricsID: Int) {
        if lyricsID == track.lyrics_id! {
            isLyricsDownloads = false
            
            lyricsRequest = nil
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            
            self.lyrics = lyrics
        }
    }
    
    // VKAPIManager получил ошибку при получении слов с указанным id
    func VKAPIManagerLyricsDelegateErrorLyricsWithID(lyricsID: Int) {
        if lyricsID == track.lyrics_id! {
            isLyricsDownloads = false
            
            lyricsRequest = nil
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            
            lyrics = ""
        }
    }
    
}