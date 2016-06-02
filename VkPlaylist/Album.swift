//
//  Album.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Альбом
class Album {
    
    /// Идентификатор
    let id: Int?
    /// Название
    let title: String?
    
    
    init(id: Int?, title: String?) {
        self.id = id
        self.title = title
    }
    
}