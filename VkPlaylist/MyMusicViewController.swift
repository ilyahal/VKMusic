//
//  MyMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком личных аудиозаписей пользователя
class MyMusicViewController: UIViewController {
    
    /// Контейнер в котором находится ViewController с мини-плеером
    @IBOutlet weak var miniPlayerViewControllerContainer: UIView!
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, 0, miniPlayerViewControllerContainer.frame.size.width, miniPlayerViewControllerContainer.frame.size.height)
        miniPlayerViewControllerContainer.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        miniPlayerViewController.willMoveToParentViewController(nil)
//        miniPlayerViewController.view.removeFromSuperview()
//        miniPlayerViewController.removeFromParentViewController()
    }
    
}
