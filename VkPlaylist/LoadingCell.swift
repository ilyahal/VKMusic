//
//  LoadingCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

// Ячейка для строки с сообщением о загрузке и индикатором загрузки
class LoadingCell: UITableViewCell {

    /// Индикатор загрузки
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicator.stopAnimating()
    }

}
