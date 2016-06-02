//
//  AddPlaylistMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком аудиозаписей, доступных для добавления в плейлист
class AddPlaylistMusicViewController: UIViewController {

    weak var delegate: AddPlaylistMusicDelegate?

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showAddPlaylistMusicTableViewControllerInContainerSegue {
            let addPlaylistMusicTableViewController = segue.destinationViewController as! AddPlaylistMusicTableViewController
            addPlaylistMusicTableViewController.delegate = delegate
        }
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    /// Была нажата кнопка "Готово"
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
