//
//  MainTabBarController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 07.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, view.frame.size.height - tabBar.bounds.size.height - 40, view.frame.size.width, 40)
        view.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
        
        // По-умолчанию скрываем мини-плеер
        PlayerManager.sharedInstance.hideMiniPlayerAnimated(false)
    }

}
