//
//  AudioCell.swift
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
