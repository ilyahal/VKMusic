//
//  OfflineAudioCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с офлайн аудиозаписью
class OfflineAudioCell: UITableViewCell {

    /// Обложка аудиозаписи
    @IBOutlet weak var artworkUmageView: UIImageView!
    /// Название аудиозаписи
    @IBOutlet weak var nameLabel: UILabel!
    /// Исполнитель
    @IBOutlet weak var artistLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        artistLabel.text = nil
    }
    
    /// Настройка ячейки для указанной аудиозаписи
    func configureForTrack(track: OfflineTrack) {
        if let artwork = track.artwork {
            artworkUmageView.image = UIImage(data: artwork)?.resizedImageWithBounds(artworkUmageView.bounds.size)
        }
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
}
