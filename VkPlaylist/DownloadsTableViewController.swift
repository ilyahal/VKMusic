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
    
    var activeDownloads: [String: Download] { // Активные загрузки
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DataManager.sharedInstance.dataManagerDownloadsDelegate = self
//        DownloadManager.sharedInstance.addDelegate(self)
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
//        cellNib = UINib(nibName: TableViewCellIdentifiers.activeDownloadCell, bundle: nil) // Ячейка с активной загрузкой
//        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.activeDownloadCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTableView()
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
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var textForNothingFoundRow: String {
        return "Нет загруженных треков"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с загруженным треком
    func getCellForNothingFoundInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNothingFoundRow
        
        return cell
    }
    
//    // Ячейка для строки с загружаемым треком
//    func getCellForActiveDownloadTrackInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.activeDownloadCell, forIndexPath: indexPath) as! ActiveDownloadCell
//        cell.delegate = self
//        cell.configureForTrack(track)
//        
//        var showPauseButton = false
//        if let download = activeDownloads[track.url!] {
//            showPauseButton = !download.inQueue
//            
//            cell.progressBar.progress = download.progress
//            cell.progressLabel.text = download.isDownloading ? "Загружается..." : download.inQueue ? "В очереди" : "Пауза"
//            
//            let title = (download.isDownloading || download.inQueue) ? "Пауза" : "Продолжить"
//            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
//        }
//        
//        cell.pauseButton.hidden = !showPauseButton
//        
//        return cell
//    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! TrackInPlaylist
        let track = trackInPlaylist.track!
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        cell.configureForTrack(track)
        
        return cell
    }
    
    
    // MARK: Загрузка helpers
    
    // Получение индекса трека для загружаемого файла
    func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, track) in DownloadManager.sharedInstance.downloadsTracks.enumerate() {
                if url == track.url! {
                    return index
                }
            }
        }
        
        return nil
    }
    
    // Получение индекса трека для загрузки
    func trackIndexForDownload(download: Download) -> Int? {
        for (index, track) in DownloadManager.sharedInstance.downloadsTracks.enumerate() {
            if download.url == track.url! {
                return index
            }
        }
        
        
        return nil
    }
    
}


//extension DownloadsTableViewController: ActiveDownloadCellDelegate {
//    
//    // Вызывается при тапе по кнопке Пауза
//    func pauseTapped(cell: ActiveDownloadCell) {
//        if let indexPath = tableView.indexPathForCell(cell) {
//            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
//            DownloadManager.sharedInstance.pauseDownloadTrack(track)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
//            }
//        }
//    }
//    
//    // Вызывается при тапе по кнопке Продолжить
//    func resumeTapped(cell: ActiveDownloadCell) {
//        if let indexPath = tableView.indexPathForCell(cell) {
//            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
//            DownloadManager.sharedInstance.resumeDownloadTrack(track)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
//            }
//        }
//    }
//    
//    // Вызывается при тапе по кнопке Отмена
//    func cancelTapped(cell: ActiveDownloadCell) {
//        if let indexPath = tableView.indexPathForCell(cell) {
//            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
//            DownloadManager.sharedInstance.cancelDownloadTrack(track)
//            
//            if activeDownloads.isEmpty {
//                reloadTableView()
//            } else {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
//                }
//            }
//        }
//    }
//    
//}


// MARK: UITableViewDataSource

private typealias DownloadsTableViewControllerDataSource = DownloadsTableViewController
extension DownloadsTableViewControllerDataSource {
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if activeDownloads.isEmpty {
//            return 1 // Секция с загруженными треками
//        }
//        
//        return 2 // Секции с загружаемыми и загруженными треками
//    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if activeDownloads.isEmpty {
//            return nil
//        }
//        
//        switch section {
//        case 0:
//            return "Активные загрузки"
//        case 1:
//            return "Загруженные"
//        default:
//            return nil
//        }
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if activeDownloads.isEmpty {
//            return downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 ? 1 : downloadsFetchedResultsController.sections!.first!.numberOfObjects
//        }
//        
//        switch section {
//        case 0:
//            return activeDownloads.count
//        case 1:
//            return downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 ? 1 : downloadsFetchedResultsController.sections!.first!.numberOfObjects
//        default:
//            return 0
//        }
        return downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 ? 1 : downloadsFetchedResultsController.sections!.first!.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if activeDownloads.isEmpty {
//            if downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 {
//                return getCellForNothingFoundInTableView(tableView, forIndexPath: indexPath)
//            }
//            
//            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
//        }
//        
//        switch indexPath.section {
//        case 0:
//            return getCellForActiveDownloadTrackInTableView(tableView, forIndexPath: indexPath)
//        case 1:
//            if downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 {
//                return getCellForNothingFoundInTableView(tableView, forIndexPath: indexPath)
//            }
//            
//            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
//        default:
//            return UITableViewCell()
//        }
        if downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 {
            return getCellForNothingFoundInTableView(tableView, forIndexPath: indexPath)
        }
        
        return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
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


// MARK: DataManagerDownloadsDelegate

extension DownloadsTableViewController: DataManagerDownloadsDelegate {

    // Контроллер начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
        }
    }
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        if activeDownloads.isEmpty {
//            reloadTableView()
//            return
//        }
        
        switch type {
        case .Insert:
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
            }
        case .Delete:
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
            }
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath!.row, inSection: activeDownloads.isEmpty ? 0 : 1)) as! OfflineAudioCell
            let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(indexPath!) as! TrackInPlaylist
            let track = trackInPlaylist.track!
            
            dispatch_async(dispatch_get_main_queue()) {
                cell.configureForTrack(track)
            }
        case .Move:
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
            }
        }
    }
    
    // Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.endUpdates()
        }
    }
    
}


// MARK: DownloadManagerDelegate

//extension DownloadsTableViewController: DownloadManagerDelegate {
//    
//    // Вызывается когда для загрузки было обновлено состояние
//    func DownloadManagerUpdateStateTrackDownload(download: Download) {
//        
//        // Обновляем ячейку
//        if let _ = trackIndexForDownload(download) {
//            reloadTableView()
//        }
//    }
//    
//    // Вызывается когда загрузка была завершена
//    func DownloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
//        
//        // Обновляем ячейку
//        if let _ = trackIndexForDownloadTask(downloadTask) {
//            reloadTableView()
//        }
//    }
//    
//    // Вызывается когда часть данных была загружена
//    func DownloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
//            if let trackIndex = trackIndexForDownloadTask(downloadTask), let activeDownloadCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? ActiveDownloadCell {
//                download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//                let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    activeDownloadCell.progressBar.progress = download.progress
//                    activeDownloadCell.progressLabel.text =  String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
//                })
//            }
//        }
//    }
//    
//}
