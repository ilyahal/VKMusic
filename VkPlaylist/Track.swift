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
    let id: Int?
    let title: String?
    let duration: Int?
    let url: String?
    
    init(artist: String?, lyrics_id: Int?, id: Int?, title: String?, duration: Int?, url: String?) {
        self.artist = artist
        self.lyrics_id = lyrics_id
        self.id = id
        self.title = title
        self.duration = duration
        self.url = url
    }
}