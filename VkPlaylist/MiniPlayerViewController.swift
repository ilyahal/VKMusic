//
//  MiniPlayerViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 04.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// ViewController с мини-плеером
class MiniPlayerViewController: UIViewController {
    
    /// Цвет элементов управления
    let tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
    

    /// Название аудиозаписи
    @IBOutlet weak var titleLabel: UILabel!
    /// Имя исполнителя
    @IBOutlet weak var artistLabel: UILabel!
    
    /// ImageView для иконки с Play/Пауза
    @IBOutlet weak var controlImageView: UIImageView!
    
    /// Бар отображающий прогесс воспроизведения
    @IBOutlet weak var progressBar: UIProgressView!
    /// Правило для высоты бара
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    
    /// Кнопка для перехода к полноэкранному плееру
    @IBOutlet weak var miniPlayerButton: UIButton!
    
    
    /// Иконка "Play"
    var playIcon: UIImage!
    /// Иконка "Пауза"
    var pauseIcon: UIImage!
    /// Иконка для кнопки "Play" или "Пауза"
    var controlIcon: UIImage {
        return isPlaying ? pauseIcon : playIcon
    }
    
    
    /// Состояние плеера
    var state: PlayerState {
        return PlayerManager.sharedInstance.state
    }
    
    /// Воспроизводится ли аудиозапись
    var isPlaying: Bool {
        get {
            return PlayerManager.sharedInstance.isPlaying
        }
    }
    /// Прогресс воспроизведения текущей аудиозаписи
    var progress: Float {
        return PlayerManager.sharedInstance.progress
    }
    /// Название исполняемой аудиозаписи
    var trackTitle: String? {
        return PlayerManager.sharedInstance.trackTitle
    }
    /// Имя исполнителя аудиозаписи
    var artist: String? {
        return PlayerManager.sharedInstance.artist
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализация переменных
        playIcon = UIImage(named: "icon-MiniPlayerPlay")!.tintPicto(tintColor)
        pauseIcon = UIImage(named: "icon-MiniPlayerPause")!.tintPicto(tintColor)
        
        // Настройка UI
        configureUI()
        
        // Настройка бара с прогрессом воспроизведения
        progressBar.setProgress(0, animated: false)
        
        // Настройка надписей со именем исполнителя и названием аудиозаписи
        titleLabel.text = nil
        artistLabel.text = nil
        
        // Настройка кнопки "Play" / "Пауза"
        updateControlButton()
        
        PlayerManager.sharedInstance.addDelegate(self)
    }
    
    deinit {
        PlayerManager.sharedInstance.deleteDelegate(self)
    }
    
    
    // MARK: UI
    
    /// Настройка интерфейса контроллера
    func configureUI() {
        
        // Настройка цвета основной кнопки
        let highlightedColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
        miniPlayerButton.setBackgroundImage(UIImage.generateImageWithColor(highlightedColor, size: CGSizeMake(1, 1)), forState: .Highlighted)
        
        // Настройка бара с прогрессом воспроизведения
        progressBar.progressTintColor = tintColor
        progressBar.trackTintColor = UIColor.clearColor()
        progressBarHeightConstraint.constant = 1 // Устанавливаем высоту бара
    }
    
    /// Обновление иконки кнопки "Play" / "Пауза"
    func updateControlButton() {
        controlImageView.image = controlIcon
    }
    
    /// Отобразить мини-плеер
    func showMiniPlayerAnimated(animated: Bool) {
        if view.hidden {
            view.hidden = false
            UIView.animateWithDuration(animated ? 0.3 : 0) {
                self.view.alpha = 1
            }
            
            PlayerManager.sharedInstance.miniPlayerDidShow()
        }
    }
    
    /// Скрыть мини-плеер
    func hideMiniPlayerAnimated(animated: Bool) {
        if !view.hidden {
            view.hidden = true
            UIView.animateWithDuration(animated ? 0.3 : 0) {
                self.view.alpha = 0
            }
            
            PlayerManager.sharedInstance.miniPlayerDidHide()
        }
    }

    
    // MARK: Взаимодействие с пользователем
    
    /// Была нажата кнопка "Play" / "Пауза"
    @IBAction func controlButton(sender: UIButton) {
        if isPlaying {
            PlayerManager.sharedInstance.pauseTapped()
        } else {
            PlayerManager.sharedInstance.playTapped()
        }
    }
    
}


// MARK: PlayerManagerDelegate

extension MiniPlayerViewController: PlayerManagerDelegate {
    
    // Менеджер плеера получил новое состояние плеера
    func playerManagerGetNewState() {
        switch state {
        case .Ready:
            hideMiniPlayerAnimated(true)
        case .Paused, .Playing:
            updateControlButton()
            showMiniPlayerAnimated(true)
        }
    }
    
    // Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem() {
        titleLabel.text = trackTitle
        artistLabel.text = artist
    }
    
    // Менеджер обновил слова аудиозаписи
    func playerManagerUpdateLyrics() {}
    
    // Менеджер получил обложку аудиозаписи
    func playerManagerGetArtwork() {}
    
    // Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewProgressValue() {
        progressBar.setProgress(progress, animated: false)
    }
    
    // Менеджер плеера получил новое значение прогресса буфферизации
    func playerManagerCurrentItemGetNewBufferingProgressValue() {}
    
    // Менеджер плеера получил новое значение текущего времени
    func playerManagerCurrentItemGetNewCurrentTime() {}
    
    // Менеджер плеера изменил настройку "Отправлять ли музыку в статус"
    func playerManagerShareToStatusSettingDidChange() {}
    
    // Менеджер плеера изменил настройку "Перемешивать ли плейлист"
    func playerManagerShuffleSettingDidChange() {}
    
    // Менеджер плеера изменил настройку "Повторять ли плейлист"
    func playerManagerRepeatTypeDidChange() {}
    
}