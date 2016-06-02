//
//  ButtonWithRoundedBorder.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Кнопка с настраиваемой границей и скругленными краями
@IBDesignable
class ButtonWithRoundedBorder: UIButton {
    
    /// Цвет границы
    @IBInspectable dynamic var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    /// Толщина границы
    @IBInspectable dynamic var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    /// Радиус скругления краев границы
    @IBInspectable dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
}