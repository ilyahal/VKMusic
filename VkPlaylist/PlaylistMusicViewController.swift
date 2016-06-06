//
//  PlaylistMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком аудиозаписей выбранного плейлиста
class PlaylistMusicViewController: UIViewController {

    /// Контейнер в котором находится ViewController с мини-плеером
    @IBOutlet weak var miniPlayerViewControllerContainer: UIView!
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    /// Выбранный плейлист
    var playlist: Playlist!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Настройка навигационной панели
        title = DataManager.sharedInstance.getPlaylistTitle(playlist)
        
        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, 0, miniPlayerViewControllerContainer.frame.size.width, miniPlayerViewControllerContainer.frame.size.height)
        miniPlayerViewControllerContainer.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showPlaylistMusicTableViewControllerInContainerSegue {
            let playlistMusicTableViewController = segue.destinationViewController as! PlaylistMusicTableViewController
            playlistMusicTableViewController.playlistMusicViewController = self
            
            playlistMusicTableViewController.playlist = playlist
        } else if segue.identifier == SegueIdentifiers.showEditPlaylistMusicTableViewControllerForEditSegue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let editPlaylistViewController = navigationController.viewControllers.first as! EditPlaylistViewController
            
            editPlaylistViewController.playlistToEdit = playlist
        }
    }
    
}
