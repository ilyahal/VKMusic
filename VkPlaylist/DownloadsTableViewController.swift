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
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.activeDownloadCell, bundle: nil) // Ячейка с активной загрузкой
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.activeDownloadCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        pauseOrResumeTapped = false
        reloadTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataManager.sharedInstance.dataManagerDownloadsDelegate = self
        DownloadManager.sharedInstance.addDelegate(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.sharedInstance.dataManagerDownloadsDelegate = nil
        DownloadManager.sharedInstance.deleteDelegate(self)
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
    
    var pauseOrResumeTapped = false // Была нажата кнопка "Пауза" или "Продолжить" (необходимо для плавного обновления)
    
    
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
    
    // Ячейка для строки с загружаемым треком
    func getCellForActiveDownloadTrackInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.activeDownloadCell, forIndexPath: indexPath) as! ActiveDownloadCell
        cell.delegate = self
        cell.configureForTrack(track)
        
        var showPauseButton = false
        if let download = activeDownloads[track.url!] {
            showPauseButton = !download.inQueue
            
            cell.progressBar.progress = download.progress
            cell.progressLabel.text = download.isDownloading ? "Загружается..." : download.inQueue ? "В очереди" : "Пауза"
            
            let title = (download.isDownloading) ? "Пауза" : "Продолжить"
            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
        }
        
        cell.pauseButton.hidden = !showPauseButton
        
        return cell
    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! TrackInPlaylist
        let track = trackInPlaylist.track
        
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


extension DownloadsTableViewController: ActiveDownloadCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            pauseOrResumeTapped = true
            DownloadManager.sharedInstance.pauseDownloadTrack(track)
        }
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            pauseOrResumeTapped = true
            DownloadManager.sharedInstance.resumeDownloadTrack(track)
        }
    }
    
    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            DownloadManager.sharedInstance.cancelDownloadTrack(track)
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias DownloadsTableViewControllerDataSource = DownloadsTableViewController
extension DownloadsTableViewControllerDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if activeDownloads.isEmpty {
            return 1 // Секция с загруженными треками
        }
        
        return 2 // Секции с загружаемыми и загруженными треками
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if activeDownloads.isEmpty {
            return nil
        }
        
        switch section {
        case 0:
            return "Активные загрузки"
        case 1:
            return "Загруженные"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let downloadedCount = downloadsFetchedResultsController.sections!.first!.numberOfObjects == 0 ? 1 : downloadsFetchedResultsController.sections!.first!.numberOfObjects
        
        if activeDownloads.isEmpty {
            return downloadedCount == 0 ? 1 : downloadedCount
        }
        
        switch section {
        case 0:
            return activeDownloads.count
        case 1:
            return downloadedCount == 0 ? 1 : downloadedCount
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let downloadedCount = downloadsFetchedResultsController.sections!.first!.numberOfObjects
        
        if activeDownloads.isEmpty {
            if downloadedCount == 0 {
                return getCellForNothingFoundInTableView(tableView, forIndexPath: indexPath)
            }
            
            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
        }
        
        switch indexPath.section {
        case 0:
            return getCellForActiveDownloadTrackInTableView(tableView, forIndexPath: indexPath)
        case 1:
            if downloadedCount == 0 {
                return getCellForNothingFoundInTableView(tableView, forIndexPath: indexPath)
            }
            
            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
        default:
            return UITableViewCell()
        }
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
//        dispatch_async(dispatch_get_main_queue()) {
//            self.tableView.beginUpdates()
//        }
    }
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        if activeDownloads.isEmpty {
//            reloadTableView()
//            return
//        }
        
//        switch type {
//        case .Insert:
//            dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
//            }
//        case .Delete:
//            dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
//            }
//        case .Update:
//            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath!.row, inSection: activeDownloads.isEmpty ? 0 : 1)) as! OfflineAudioCell
//            let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(indexPath!) as! TrackInPlaylist
//            let track = trackInPlaylist.track!
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                cell.configureForTrack(track)
//            }
//        case .Move:
//            dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
//                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: self.activeDownloads.isEmpty ? 0 : 1)], withRowAnimation: .Fade)
//            }
//        }
    }
    
    // Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.tableView.endUpdates()
//        }
        
        reloadTableView()
    }
    
}


// MARK: DownloadManagerDelegate

extension DownloadsTableViewController: DownloadManagerDelegate {
    
    // Вызывается когда была начата новая загрузка
    func downloadManagerStartTrackDownload(download: Download) {
        if let trackIndex = trackIndexForDownload(download) {
            if tableView.numberOfSections == 1 {
                reloadTableView()
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .Fade)
                })
            }
        }
    }
    
    // Вызывается когда состояние загрузки было изменено
    func downloadManagerUpdateStateTrackDownload(download: Download) {
        if let trackIndex = trackIndexForDownload(download) {
            if pauseOrResumeTapped {
                pauseOrResumeTapped = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
                })
            } else {
                reloadTableView()
            }
        }
    }
    
    // Вызывается когда загрузка была отменена
    func downloadManagerCancelTrackDownload(download: Download) {
        reloadTableView()
    }
    
    // Вызывается когда загрузка была завершена
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {}
    
    // Вызывается когда часть данных была загружена
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let activeDownloadCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? ActiveDownloadCell {
                download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
                
                dispatch_async(dispatch_get_main_queue(), {
                    activeDownloadCell.progressBar.progress = download.progress
                    activeDownloadCell.progressLabel.text =  download.progress == 1 ? "Сохраняется..." : String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
}
