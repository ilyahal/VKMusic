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
    
    override func prepareForReuse() {
        nameLabel.text = nil
        artistLabel.text = nil
    }
    
    func configureForTrack(track: OfflineTrack) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
}
