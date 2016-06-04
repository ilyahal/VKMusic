//
//  PlayerViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 05.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер с полноэкранным плеером
class PlayerViewController: UIViewController {

    /// Кнопка "Закрыть" была нажата 
    @IBAction func closeButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
