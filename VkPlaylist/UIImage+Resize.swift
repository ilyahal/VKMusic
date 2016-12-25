//
//  UIImage+Resize.swift
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

extension UIImage {
    
    /// Изменяет размеры изображения, чтобы оно помещалось в указанные границы
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