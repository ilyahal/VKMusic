//
//  AudioTableViewCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AudioTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func pauseOrResumeTapped(sender: UIButton) {
        print(sender.currentTitle)
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        print(sender.currentTitle)
    }

    @IBAction func downloadTapped(sender: UIButton) {
        print(sender.currentTitle)
    }
    
}
