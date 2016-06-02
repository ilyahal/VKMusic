//
//  AudioCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с онлайн аудиозаписью
class AudioCell: UITableViewCell {
    
    var delegate: AudioCellDelegate?

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
    /// Кнопка "Скачать" аудиозапись
    @IBOutlet weak var downloadButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        artistLabel.text = nil
        cancelButton.hidden = true
        pauseButton.setTitle("Пауза", forState: .Normal)
        pauseButton.hidden = true
        progressLabel.text = nil
        progressLabel.hidden = true
        progressBar.progress = 0.0
        progressBar.hidden = true
        downloadButton.hidden = true
    }
    
    /// Настройка ячейки для указанной аудиозаписи
    func configureForTrack(track: Track) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
    }
    
    /// Вызывается при нажатии по кнопкам "Пауза" или "Продолжить"
    @IBAction func pauseOrResumeTapped(sender: UIButton) {
        super.prepareForReuse()
        
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

    /// Вызывается при нажатии по кнопке "Скачать"
    @IBAction func downloadTapped(sender: UIButton) {
        delegate?.downloadTapped(self)
    }
    
}
