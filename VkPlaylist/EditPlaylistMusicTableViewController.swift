//
//  EditPlaylistMusicTableViewController.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// Контроллер содержащий таблицу со списком аудиозаписей редактируемого плейлиста
class EditPlaylistMusicTableViewController: UITableViewController {
    
    /// Редактируемый плейлист
    var playlistToEdit: Playlist?
    
    /// Массив треков плейлиста
    var tracks = [OfflineTrack]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let playlistToEdit = playlistToEdit where playlistToEdit.tracks.count != 0 {
            for trackInPlaylist in DataManager.sharedInstance.getTracksForPlaylist(playlistToEdit) {
                tracks.append(trackInPlaylist.track)
            }
        }
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        tableView.allowsSelectionDuringEditing = true // Возможно выделение ячеек при редактировании
        tableView.editing = true
        
        // Регистрация ячеек
        let cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка со скаченным треком
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showAddPlaylistMusicViewControllerSegue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let addPlaylistMusicViewController = navigationController.viewControllers.first as! AddPlaylistMusicViewController
            
            addPlaylistMusicViewController.delegate = self
        }
    }
    
    /// Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    /// Ячейка для строки с загруженным треком
    func getCellForAddAudioForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.addAudioCell, forIndexPath: indexPath)
        
        return cell
    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let track = tracks[indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        cell.configureForTrack(track)
        cell.selectionStyle = .None
        
        return cell
    }

}


// MARK: UITableViewDataSource

private typealias _EditPlaylistMusicTableViewControllerDataSource = EditPlaylistMusicTableViewController
extension _EditPlaylistMusicTableViewControllerDataSource {

    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 1
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getCellForAddAudioForIndexPath(indexPath)
        }
        
        return getCellForOfflineAudioForIndexPath(indexPath)
    }
    
    // Возможно ли редактировать ячейку
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    // Обработка удаления ячейки
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tracks.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // Возможно ли перемещать ячейку
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    // Обработка после перемещения ячейки
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let trackToMove = tracks[fromIndexPath.row - 1]
        
        tracks.removeAtIndex(fromIndexPath.row - 1)
        tracks.insert(trackToMove, atIndex: toIndexPath.row - 1)
    }
    
    // Определяется куда переместить ячейку с укзанного NSIndexPath при перемещении в указанный NSIndexPath
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row == 0 {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }

}


// MARK: UITableViewDelegate

private typealias _EditPlaylistMusicTableViewControllerDelegate = EditPlaylistMusicTableViewController
extension _EditPlaylistMusicTableViewControllerDelegate {

    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 53
        }
        
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            performSegueWithIdentifier(SegueIdentifiers.showAddPlaylistMusicViewControllerSegue, sender: nil)
        }
    }
    
}


// MARK: AddPlaylistMusicDelegate

extension EditPlaylistMusicTableViewController: AddPlaylistMusicDelegate {
    
    // Аудиозапись была добавлена в плейлист
    func addPlaylistMusicDelegateAddTrack(track: OfflineTrack) {
        tracks.append(track)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.tracks.count, inSection: 0)], withRowAnimation: .None)
        })
    }
    
}