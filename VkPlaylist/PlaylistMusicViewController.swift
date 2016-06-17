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
    
    /// Правило для нижней границы контейнера с таблицей
    @IBOutlet weak var containerBottomLayoutConstraint: NSLayoutConstraint!
    
    /// Значение для правила для нижней границы контейнера с таблицей
    var containerBottomLayoutConstraintConstantValue: CGFloat {
        return PlayerManager.sharedInstance.isPlaying ? -9 : -49
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Настройка навигационной панели
        title = DataManager.sharedInstance.getPlaylistTitle(playlist)
        
        
        updateContainerBottomLayoutConstraintAnimated(false)
        
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidShowMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidHideMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidShowMiniPlayerNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidHideMiniPlayerNotification, object: nil)
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
    
    
    /// Обновить отступ для нижней границы контейнера с аудиозаписями
    func updateContainerBottomLayoutConstraintAnimated(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.containerBottomLayoutConstraint.constant = self.containerBottomLayoutConstraintConstantValue
        }
    }
    
}
