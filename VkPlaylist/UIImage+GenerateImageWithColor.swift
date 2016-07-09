//
//  UIImage+GenerateImageWithColor.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 06.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

extension UIImage {

    /// Генерация изображения с указанным цветом указанного размера
    class func generateImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}