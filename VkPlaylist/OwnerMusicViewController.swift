//
//  OwnerMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком аудиозаписей владельца
class OwnerMusicViewController: UIViewController {

    /// Контейнер в котором находится ViewController с мини-плеером
    @IBOutlet weak var miniPlayerViewControllerContainer: UIView!
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    /// Идентификатор владельца, чьи аудиозаписи загружаются
    var id: Int!
    /// Имя владельца
    var name: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка навигационной панели
        title = name
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, 0, miniPlayerViewControllerContainer.frame.size.width, miniPlayerViewControllerContainer.frame.size.height)
        miniPlayerViewControllerContainer.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showOwnerMusicTableViewControllerInContainerSegue {
            let ownerMusicTableViewController = segue.destinationViewController as! OwnerMusicTableViewController
            
            ownerMusicTableViewController.id = id
        }
    }

}
