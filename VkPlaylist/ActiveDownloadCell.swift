//
//  ActiveDownloadCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с активной загрузкой
class ActiveDownloadCell: UITableViewCell {

    var delegate: ActiveDownloadCellDelegate?
    
    /// Название аудиозаписи
    @IBOutlet weak var nameLabel: UILabel!
    /// Исполнитель
    @IBOutlet weak var artistLabel: UILabel!
    /// Кнопка "Отмена" загрузки
    @IBOutlet weak var cancelButton: UIButton!
    /// Кнопка "Пауза" загрузки
    @IBOutlet weak var pauseButton: UIButton!
    /// Метка для отображения прогресса загрузки
    @IBOutlet weak var progressLabel: UILabel!
    /// Индикатор выполнения загрузки
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        artistLabel.text = nil
        pauseButton.hidden = false
        pauseButton.setTitle("Пауза", forState: .Normal)
        cancelButton.hidden = false
        progressLabel.text = nil
        progressBar.progress = 0.0
    }
    
    /// Настройка ячейки для указанной аудиозаписи
    func configureForTrack(track: Track) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
    /// Вызывается при нажатии по кнопкам "Пауза" или "Продолжить"
    @IBAction func pauseOrResumeTapped(sender: UIButton) {
        if pauseButton.titleLabel!.text == "Пауза" {
            delegate?.pauseTapped(self)
        } else {
            delegate?.resumeTapped(self)
        }
    }
    
    /// Вызывается при нажатии по кнопке "Отмена"
    @IBAction func cancelTapped(sender: UIButton) {
        delegate?.cancelTapped(self)
    }
    
}
