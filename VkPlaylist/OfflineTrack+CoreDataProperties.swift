//
//  OfflineTrack+CoreDataProperties.swift
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

import Foundation
import CoreData

extension OfflineTrack {

    /// Исполнитель
    @NSManaged var artist: String
    /// Обложка
    @NSManaged var artwork: NSData?
    /// Продолжительность
    @NSManaged var duration: Int32
    /// Идентификатор
    @NSManaged var id: Int32
    /// Идентификатор владельца
    @NSManaged var ownerID: Int32
    /// Слова
    @NSManaged var lyrics: String?
    /// Название
    @NSManaged var title: String
    /// Название файла
    @NSManaged var fileName: String
    /// Плейлисты в которых содержится трек (TrackInPlaylist)
    @NSManaged var playlists: NSSet

}
