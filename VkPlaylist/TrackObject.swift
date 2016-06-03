//
//  TrackObject.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Объект аудиозапись онлайн/офлайн
protocol TrackObject: class {
    
    var title: String { get }
    var artist: String { get }
    
}