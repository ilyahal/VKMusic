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

    /// Имя исполнителя
    @IBOutlet weak var artistNameLabel: UILabel!
    /// Название аудиозаписи
    @IBOutlet weak var songTitleLabel: UILabel!
    /// Кнопка для перехода к полноэкранному плееру
    @IBOutlet weak var miniPlayerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artistNameLabel.textColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        songTitleLabel.textColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        
        let normalColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.05)
        miniPlayerButton.setBackgroundImage(generateImageWithColor(normalColor), forState: .Normal)
        let highlightedColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
        miniPlayerButton.setBackgroundImage(generateImageWithColor(highlightedColor), forState: .Highlighted)
    }

    
    /// Генерация изображения с указанным цветом
    private func generateImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
