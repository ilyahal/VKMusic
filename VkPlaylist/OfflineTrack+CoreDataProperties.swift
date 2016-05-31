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

    @NSManaged var artist: String // Исполнитель
    @NSManaged var duration: Int32 // Продолжительность
    @NSManaged var id: Int32 // Идентификатор
    @NSManaged var ownerID: Int32 // Идентификатор владельца
    @NSManaged var lyrics: String? // Слова
    @NSManaged var title: String // Название
    @NSManaged var file: NSData // Файл
    @NSManaged var playlists: NSSet // Плейлисты в которых содержится трек (TrackInPlaylist)

}
