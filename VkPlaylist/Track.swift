//
//  Track.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class Track {
    let artist: String?
    let lyrics_id: Int?
    let id: Int32?
    let title: String?
    let duration: Int32?
    let owner_id: Int32?
    let url: String?
    
    init(artist: String?, lyrics_id: Int?, id: Int32?, title: String?, duration: Int32?, owner_id: Int32?, url: String?) {
        self.artist = artist
        self.lyrics_id = lyrics_id
        self.id = id
        self.title = title
        self.duration = duration
        self.owner_id = owner_id
        self.url = url
    }
}