//
//  Track.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class Track {
    var artist: String?
    var lyrics_id: Int?
    var id: Int?
    var title: String?
    var date: Int?
    var duration: Int?
    var genre_id: Int?
    var owner_id: Int?
    var url: String?
    
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