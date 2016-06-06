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

    /// Название аудиозаписи
    @IBOutlet weak var songTitleLabel: UILabel!
    /// Имя исполнителя
    @IBOutlet weak var artistNameLabel: UILabel!
    /// Кнопка для перехода к полноэкранному плееру
    @IBOutlet weak var miniPlayerButton: UIButton!
    
    /// ImageView для иконки с Play/Пауза
    @IBOutlet weak var controlImageView: UIImageView!
    /// Изображение для кнопки "Play"
    var playButtonImage: UIImage!
    /// Изображение для кнопки "Пауза"
    var pauseButtonImage: UIImage!
    
    /// Бар отображающий прогесс воспроизведения
    @IBOutlet weak var progressBar: UIProgressView!
    /// Правило для высоты бара
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Получение иконок для контроля воспроизведения
        playButtonImage = UIImage(named: "icon-MiniPlayerPlay")
        pauseButtonImage = UIImage(named: "icon-MiniPlayerPause")
        
        // Настройка изображения для контроля воспроизведения
        controlImageView.image = playButtonImage
        controlImageView.tintImageColor((UIApplication.sharedApplication().delegate as! AppDelegate).tintColor)
        
        // Настройка цвета основной кнопки
        let highlightedColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
        miniPlayerButton.setBackgroundImage(UIImage.generateImageWithColor(highlightedColor), forState: .Highlighted)
        
        // Настройка бара с прогрессом воспроизведения
        progressBar.progressTintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        progressBar.trackTintColor = UIColor.clearColor()
        progressBarHeightConstraint.constant = 1 // Устанавливаем высоту бара
    }

    
    @IBAction func controlButton(sender: UIButton) {
        print("Была нажата область управления воспроизведением")
    }
    
}
