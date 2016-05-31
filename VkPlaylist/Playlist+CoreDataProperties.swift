//
//  Playlist+CoreDataProperties.swift
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

extension Playlist {

    @NSManaged var id: Int32 // Идентификатор плейлиста
    @NSManaged var isVisible: Bool // Отображается ли плейлист
    @NSManaged var position: Int32 // Позиция плейлиста в списке
    @NSManaged var title: String // Название плейлиста
    @NSManaged var tracks: NSSet // Треки содержащиеся в плейлисте (TrackInPlaylist)

}
