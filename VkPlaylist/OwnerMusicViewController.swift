//
//  OwnerMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class OwnerMusicViewController: UIViewController {

    var id: Int! // Идентификатор владельца, чьи аудиозаписи загружаются
    var name: String? // Имя владельца
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка навигационной панели
        title = name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showOwnerMusicTableViewControllerInContainerSegue {
            let ownerMusicTableViewController = segue.destinationViewController as! OwnerMusicTableViewController
            ownerMusicTableViewController.id = id
        }
    }

}
