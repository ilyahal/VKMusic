//
//  OfflineAudioCell.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
            artworkUmageView.image = UIImage(data: artwork)
        } else {
            artworkUmageView.image = UIImage(named: "icon-TrackArtworkDefault")
        }
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
}
