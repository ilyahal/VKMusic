//
//  OfflineTrack+CoreDataProperties.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
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
