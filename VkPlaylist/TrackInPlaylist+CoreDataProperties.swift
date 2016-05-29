//
//  TrackInPlaylist+CoreDataProperties.swift
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

extension TrackInPlaylist {

    @NSManaged var position: Int
    @NSManaged var playlist: Playlist
    @NSManaged var track: OfflineTrack

}
