//
//  UIImage+Resize.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImageWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width // Соотношение горизонтальных сторон
        let verticalRatio = bounds.height / size.height // Соотношение вертикальных сторон
        let ratio = min(horizontalRatio, verticalRatio) // Минимальное соотношение
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio) // Новый размер для изображения
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0) // Изменяем размер изображения
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize)) // Рисуем изображение во временную память
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() // Создаем изображение из временной памяти
        UIGraphicsEndImageContext() // Чистим временную память
        
        return newImage
    }
}