//
//  AlbumCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
    
}
