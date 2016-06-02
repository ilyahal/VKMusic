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

    /// Идентификатор плейлиста
    @NSManaged var id: Int32
    /// Отображается ли плейлист
    @NSManaged var isVisible: Bool
    /// Позиция плейлиста в списке
    @NSManaged var position: Int32
    /// Название плейлиста
    @NSManaged var title: String
    /// Треки содержащиеся в плейлисте (TrackInPlaylist)
    @NSManaged var tracks: NSSet

}
