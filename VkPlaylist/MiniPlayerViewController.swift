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
    /// Кнопка для перехода к полноэкранному плееру
    @IBOutlet weak var miniPlayerButton: UIButton!
    
    /// ImageView для иконки с Play/Пауза
    @IBOutlet weak var controlImageView: UIImageView!
    
    /// Бар отображающий прогесс воспроизведения
    @IBOutlet weak var progressBar: UIProgressView!
    /// Правило для высоты бара
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    
    
    /// Воспроизводится ли аудиозапись
    var isPlaying: Bool {
        get {
            return PlayerManager.sharedInstance.isPlaying
        }
    }
    
    
    /// Иконка для кнопки "Play" или "Пауза"
    var controlIcon: UIImage {
        return UIImage(named: isPlaying ? "icon-MiniPlayerPause" : "icon-MiniPlayerPlay")!.tintPicto(tintColor)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка цвета основной кнопки
        let highlightedColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
        miniPlayerButton.setBackgroundImage(UIImage.generateImageWithColor(highlightedColor), forState: .Highlighted)
        
        // Настройка бара с прогрессом воспроизведения
        progressBar.setProgress(0, animated: false)
        progressBar.progressTintColor = tintColor
        progressBar.trackTintColor = UIColor.clearColor()
        progressBarHeightConstraint.constant = 1 // Устанавливаем высоту бара
        
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
    
    
    // MARK: Помощники
    
    /// Обновление иконки кнопки "Play" / "Пауза"
    func updateControlButton() {
        controlImageView.image = controlIcon
    }

    
    // MARK: Кнопки контроллера
    
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
    func playerManagerGetNewState(state: PlayerState) {
        switch state {
        case .Ready:
            if !view.hidden {
                view.hidden = true
                UIView.animateWithDuration(true ? 0.5 : 0) {
                    self.view.alpha = 0
                }
            }
        case .Paused, .Playing:
            if view.hidden {
                view.hidden = false
                UIView.animateWithDuration(true ? 0.5 : 0) {
                    self.view.alpha = 1
                }
            }
            
            updateControlButton()
        }
    }
    
    // Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem(item: PlayerItem) {
        titleLabel.text = item.title
        artistLabel.text = item.artist
    }
    
    // Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewTimerProgress(progress: Float) {
        progressBar.setProgress(progress, animated: false)
    }
    
}