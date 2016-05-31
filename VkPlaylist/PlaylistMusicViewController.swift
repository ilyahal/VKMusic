//
//  PlaylistMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class PlaylistMusicViewController: UIViewController {

    var playlist: Playlist!
    
    weak var playlistMusicTableViewController: PlaylistMusicTableViewController!
    
    var isEditingNow: Bool {
        get {
            return playlistMusicTableViewController.editing
        }
        set {
            playlistMusicTableViewController.editing = newValue
        }
    }
    
    var doneButtonItem: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped)) // Создаем кнопку используя системную иконку

        // Настройка навигационной панели
        title = playlist.title
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController!.tabBar.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPlaylistMusicTableViewControllerInContainerSegue" {
            let playlistMusicTableViewController = segue.destinationViewController as! PlaylistMusicTableViewController
            playlistMusicTableViewController.playlistMusicViewController = self
            playlistMusicTableViewController.playlist = playlist
            
            self.playlistMusicTableViewController = playlistMusicTableViewController
        }
    }
    
    func swapEditing() {
        isEditingNow = !isEditingNow
        navigationItem.setRightBarButtonItems([isEditingNow ? doneButtonItem : editButton], animated: true)
        
        playlistMusicTableViewController.searchController.searchBar.alpha = isEditingNow ? 0.5 : 1
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        swapEditing()
    }
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        if playlistMusicTableViewController.tracks.count != 0 {
            swapEditing()
        }
    }
    
}
