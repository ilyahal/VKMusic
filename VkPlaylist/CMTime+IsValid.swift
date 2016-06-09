//
//  CMTime+IsValid.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import MediaPlayer

extension CMTime {
    
    var isValid: Bool {
        return (flags.intersect(.Valid)) != []
    }
    
}