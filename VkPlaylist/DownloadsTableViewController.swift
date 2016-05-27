//
//  DownloadsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

class DownloadsTableViewController: UITableViewController {

    var downloadsFetchedResultsController: NSFetchedResultsController {
        return DataManager.sharedInstance.downloadsFetchedResultsController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.sharedInstance.dataManagerDownloadsDelegate = self
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias DownloadsTableViewControllerDataSource = DownloadsTableViewController
extension DownloadsTableViewControllerDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return downloadsFetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = downloadsFetchedResultsController.sections![section]
        
        return sectionInfo.name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = downloadsFetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(indexPath) as! TrackInPlaylist
        let track = trackInPlaylist.track!
        
        cell.configureForTrack(track)
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias DownloadsTableViewControllerDelegate = DownloadsTableViewController
extension DownloadsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
}

extension DownloadsTableViewController: DataManagerDownloadsDelegate {

    func dataManagerDownloadsControllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func dataManagerDownloadsController(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
        default :
            break
        }
    }
    
    func dataManagerDownloadsController(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! OfflineAudioCell
            let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(indexPath!) as! TrackInPlaylist
            let track = trackInPlaylist.track!
            
            cell.configureForTrack(track)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func dataManagerDownloadsControllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
