//
//  MiniPlayerView.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 05.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Элемент в котором содержится мини-плеер
class MiniPlayerView: UIView {

    override func drawRect(rect: CGRect) {
        
        // Отрисовка верхней линии
        let topLine = UIBezierPath(rect: CGRectMake(0, 0, frame.size.width, 0.5))
        UIColor.grayColor().setStroke()
        topLine.lineWidth = 0.2
        topLine.stroke()
        
        // Отрисовка нижней линии
        let bottomLine = UIBezierPath(rect: CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5))
        UIColor.lightGrayColor().setStroke()
        bottomLine.lineWidth = 0.2
        bottomLine.stroke()
    }
}
