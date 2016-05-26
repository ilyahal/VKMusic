//
//  OfflineAudioCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class OfflineAudioCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    func configureForTrack(track: OfflineTrack) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
}
