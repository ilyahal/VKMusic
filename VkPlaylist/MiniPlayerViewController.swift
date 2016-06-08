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
    let controlColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
    

    /// Название аудиозаписи
    @IBOutlet weak var songTitleLabel: UILabel!
    /// Имя исполнителя
    @IBOutlet weak var artistNameLabel: UILabel!
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
        set {
            PlayerManager.sharedInstance.isPlaying = newValue
        }
        get {
            return PlayerManager.sharedInstance.isPlaying
        }
    }
    
    
    /// Иконка для кнопки "Play" или "Пауза"
    var controlIcon: UIImage {
        return UIImage(named: isPlaying ? "icon-MiniPlayerPause" : "icon-MiniPlayerPlay")!.tintPicto(controlColor)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка надписи с названием аудиозаписи
        songTitleLabel.textColor = UIColor(red: 0.28, green: 0.29, blue: 0.29, alpha: 1)
        
        // Настройка цвета основной кнопки
        let highlightedColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
        miniPlayerButton.setBackgroundImage(UIImage.generateImageWithColor(highlightedColor), forState: .Highlighted)
        
        // Настройка бара с прогрессом воспроизведения
        progressBar.progressTintColor = controlColor
        progressBar.trackTintColor = UIColor.clearColor()
        progressBarHeightConstraint.constant = 1 // Устанавливаем высоту бара
        
        // Настройка кнопки "Play" / "Пауза"
        updateControlButton()
    }
    
    
    // MARK: Помощники
    
    /// Обновление иконки кнопки "Play" / "Пауза"
    func updateControlButton() {
        controlImageView.image = controlIcon
    }

    
    // MARK: Кнопки контроллера
    
    /// Была нажата кнопка "Play" / "Пауза"
    @IBAction func controlButton(sender: UIButton) {
        isPlaying = !isPlaying
        updateControlButton()
    }
    
}
