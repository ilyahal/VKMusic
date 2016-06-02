//
//  NoAuthorizedCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с сообщением о необходимости авторизоваться
class NoAuthorizedCell: UITableViewCell {
    
    /// Метка для сообщения
    @IBOutlet weak var messageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = nil
    }

}
