//
//  NothingFoundCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с сообщением об отсутствии результатов
class NothingFoundCell: UITableViewCell {

    /// Метка для сообщения
    @IBOutlet weak var messageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = nil
    }
    
}
