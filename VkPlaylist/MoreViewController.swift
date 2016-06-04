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

    /// Контейнер в котором находится ViewController с мини-плеером
    @IBOutlet weak var miniPlayerViewControllerContainer: UIView!
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка кнопки назад на дочерних экранах
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, 0, miniPlayerViewControllerContainer.frame.size.width, miniPlayerViewControllerContainer.frame.size.height)
        miniPlayerViewControllerContainer.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
    }

}
