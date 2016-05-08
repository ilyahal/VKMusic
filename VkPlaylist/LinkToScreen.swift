//
//  LinkToScreen.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class LinkToScreen {
    let title: String
    let icon: String
    let segueIdentifier: String
    
    init(title: String, icon: String, segueIdentifier: String) {
        self.title = title
        self.icon = icon
        self.segueIdentifier = segueIdentifier
    }
}