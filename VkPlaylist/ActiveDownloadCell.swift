//
//  ActiveDownloadCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class ActiveDownloadCell: UITableViewCell {

    var delegate: ActiveDownloadCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
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
    
    override func prepareForReuse() {
        nameLabel.text = nil
        artistLabel.text = nil
    }
    
}
