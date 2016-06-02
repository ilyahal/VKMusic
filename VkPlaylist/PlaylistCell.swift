//
//  PlaylistCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 12.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с плейлистом
class PlaylistCell: UITableViewCell {
    
    /// Название плейлиста
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
}
