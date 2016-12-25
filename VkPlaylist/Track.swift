//
//  Track.swift
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

/// Онлайн аудиозапись
class Track {
    
    /// Исполнитель
    let artist: String
    /// Идентификатор слов
    let lyrics_id: Int?
    /// Идентификатор
    let id: Int32
    /// Название
    let title: String
    /// Продолжительность
    let duration: Int32
    /// Идентификатор владельца
    let owner_id: Int32
    /// Ссылка
    let url: String
    
    
    init(artist: String, lyrics_id: Int?, id: Int32, title: String, duration: Int32, owner_id: Int32, url: String) {
        self.artist = artist
        self.lyrics_id = lyrics_id
        self.id = id
        self.title = title
        self.duration = duration
        self.owner_id = owner_id
        self.url = url
    }
    
}