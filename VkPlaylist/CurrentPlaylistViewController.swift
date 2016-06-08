//
//  CurrentPlaylistViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий список аудиозаписей в текущем плейлисте
class CurrentPlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка кнопки "Назад"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: self, action: #selector(closeViewController))
        navigationItem.setLeftBarButtonItems([navigationItem.backBarButtonItem!], animated: false)
    }

    
    /// Закрыть контроллер
    func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
