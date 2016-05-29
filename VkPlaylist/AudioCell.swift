//
//  AudioCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AudioCell: UITableViewCell {
    
    var delegate: AudioCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    
    override func prepareForReuse() {
        nameLabel.text = nil
        artistLabel.text = nil
        cancelButton.hidden = true
        pauseButton.setTitle("Пауза", forState: .Normal)
        pauseButton.hidden = true
        progressLabel.text = nil
        progressLabel.hidden = true
        progressBar.progress = 0.0
        progressBar.hidden = true
        downloadButton.hidden = true
    }
    
    func configureForTrack(track: Track) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
    @IBAction func pauseOrResumeTapped(sender: UIButton) {
        if pauseButton.titleLabel!.text == "Пауза" {
            delegate?.pauseTapped(self)
        } else {
            delegate?.resumeTapped(self)
        }
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        delegate?.cancelTapped(self)
    }

    @IBAction func downloadTapped(sender: UIButton) {
        delegate?.downloadTapped(self)
    }
    
}
