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

    /// Выбранный плейлист
    var playlist: Playlist!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Настройка навигационной панели
        title = DataManager.sharedInstance.getPlaylistTitle(playlist)
        
        tabBarController!.tabBar.hidden = true
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
