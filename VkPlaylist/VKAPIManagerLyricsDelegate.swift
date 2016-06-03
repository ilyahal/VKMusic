//
//  VKAPIManagerLyricsDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Делегат VKAPIManager для запроса на получение слов
protocol VKAPIManagerLyricsDelegate: class {
    
    /// VKAPIManager получил слова с указанным id
    func VKAPIManagerLyricsDelegateGetLyrics(lyrics: String, forLyricsID lyricsID: Int)
    
    /// VKAPIManager получил ошибку при получении слов с указанным id
    func VKAPIManagerLyricsDelegateErrorLyricsWithID(lyricsID: Int)
    
}