//
//  DownloadTrack.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import SwiftyVK

/// Загрузка аудиозаписи
class DownloadTrack: Download {
    
    /// Название аудиозаписи
    var title: String
    /// Имя исполнителя
    var artist: String
    
    /// Обложка альбома
    var artwork: NSData?
    /// Запрос на получение обложки альбома
    var artworkRequest: MusicBrainzAPIManager?
    /// Получается ли обложка альбома сейчас
    var isArtworkDownloading = false
    
    /// id слов аудиозаписи
    var lyrics_id: Int?
    /// Слова аудиозаписи
    var lyrics: String?
    /// Получаются ли слова аудиозаписи в данный момент
    var isLyricsDownloading = false
    /// Запрос на получение слов аудиозаписи
    var lyricsRequest: Request?
    
    init(url: String, title: String, artist: String, lyrics_id: Int?) {
        self.title = title
        self.artist = artist
        self.lyrics_id = lyrics_id
        
        super.init(url: url)
    }
    
    
    /// Отправить запрос на получение обложки
    func getArtwork() {
        isArtworkDownloading = true
        
        artworkRequest = MusicBrainzAPIManager(title: title, artist: artist)
        artworkRequest?.getArtwork() { artwork in
            self.isArtworkDownloading = false
            
            self.artwork = UIImageJPEGRepresentation(artwork, 1)
            self.artworkRequest = nil
        }
    }
    
    /// Отменить запрос на получение обложки альбома
    func cancelGetArtwork() {
        artworkRequest?.cancel()
        artworkRequest = nil
        isArtworkDownloading = false
    }
    
    
    /// Отправить запрос на получение слов аудиозаписи
    func getLyrics() {
        if let lyrics_id = lyrics_id {
            isLyricsDownloading = true
            
            VKAPIManager.sharedInstance.addLyricsDelegate(self)
            VKAPIManager.audioGetLyrics(lyrics_id)
        } else {
            lyrics = ""
        }
    }
    
    /// Отменить запрос на получение слов аудиозаписи
    func cancelGetLyrics() {
        lyricsRequest?.cancel()
        isLyricsDownloading = false
        VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
    }
}


// MARK: VKAPIManagerLyricsDelegate

extension DownloadTrack: VKAPIManagerLyricsDelegate {
    
    // VKAPIManager получил слова с указанным id
    func VKAPIManagerLyricsDelegateGetLyrics(lyrics: String, forLyricsID lyricsID: Int) {
        if lyricsID == lyrics_id! {
            isLyricsDownloading = false
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            
            self.lyrics = lyrics
        }
    }
    
    // VKAPIManager получил ошибку при получении слов с указанным id
    func VKAPIManagerLyricsDelegateErrorLyricsWithID(lyricsID: Int) {
        if lyricsID == lyrics_id! {
            isLyricsDownloading = false
            VKAPIManager.sharedInstance.deleteLyricsDelegate(self)
            
            lyrics = ""
        }
    }
    
}