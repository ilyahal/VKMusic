//
//  UIImageView+TintImageColor.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /// Заливка изображения указанным цветом
    func tintImageColor(color : UIColor) {
        self.image = self.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = color
    }
    
}