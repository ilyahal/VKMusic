//
//  Group.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class Group {
    let id: Int?
    let name: String?
    let photo_200: String?
    
    init(id: Int?, name: String?, photo_200: String?) {
        self.id = id
        self.name = name
        self.photo_200 = photo_200
    }
}