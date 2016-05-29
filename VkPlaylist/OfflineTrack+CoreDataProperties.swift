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

    @NSManaged var artist: String
    @NSManaged var duration: Int
    @NSManaged var id: Int
    @NSManaged var ownerID: Int
    @NSManaged var lyrics: String?
    @NSManaged var title: String
    @NSManaged var file: NSData
    @NSManaged var playlists: NSSet?

}
