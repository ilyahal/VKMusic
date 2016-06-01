//
//  AlbumMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AlbumMusicViewController: UIViewController {

    var album: Album!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка навигационной панели
        title = album.title
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController!.tabBar.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showAlbumMusicTableViewControllerInContainerSegue {
            let albumMusicTableViewController = segue.destinationViewController as! AlbumMusicTableViewController
            albumMusicTableViewController.album = album
        }
    }

}
