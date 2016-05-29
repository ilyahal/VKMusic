//
//  NoAuthorizedCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class NoAuthorizedCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func prepareForReuse() {
        messageLabel.text = nil
    }

}
