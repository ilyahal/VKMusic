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
    let date: Int?
    let duration: Int?
    let genre_id: Int?
    let owner_id: Int?
    let url: String?
    
    init(artist: String?, lyrics_id: Int?, id: Int?, title: String?, date: Int?, duration: Int?, genre_id: Int?, owner_id: Int?, url: String?) {
        self.artist = artist
        self.lyrics_id = lyrics_id
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.genre_id = genre_id
        self.owner_id = owner_id
        self.url = url
    }
}