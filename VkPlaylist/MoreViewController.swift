//
//  MoreViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 04.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком дополнительных экранов
class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка кнопки назад на дочерних экранах
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
    }

}
