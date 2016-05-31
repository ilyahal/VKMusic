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
    
    var downloadedCount: Int { // Количество загруженных треков
        return downloadsFetchedResultsController.sections!.first!.numberOfObjects
    }
    
    var activeDownloads: [String: Download] { // Активные загрузки
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    var activeDownloadsCount: Int { // Количество активных загрузок
        return activeDownloads.count
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
        
        DataManager.sharedInstance.addDataManagerDownloadsDelegate(self)
        DownloadManager.sharedInstance.addDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        DataManager.sharedInstance.deleteDataManagerDownloadsDelegate(self)
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
    
    // Текст для ячейки с сообщением о том, что нет загружаемых треков
    var textForNoActiveDownloadsRow: String {
        return "Нет активных загрузок"
    }
    
    // Текст для ячейки с сообщением о том, что нет загруженных треков
    var textForNoDownloadedRow: String {
        return "Нет загруженных треков"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением об отсутствии загружаемых треков
    func getCellForNoActiveDownloadsInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoActiveDownloadsRow
        
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
    
    // Ячейка для строки с сообщением об отсутствии загруженных треков
    func getCellForNoDownloadedInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoDownloadedRow
        
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
        return 2 // Секции с загружаемыми и загруженными треками
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        switch section {
        case 0:
            return activeDownloadsCount == 0 ? 1 : activeDownloadsCount
        case 1:
            return downloadedCount == 0 ? 1 : downloadedCount
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if activeDownloadsCount == 0 {
                return getCellForNoActiveDownloadsInTableView(tableView, forIndexPath: indexPath)
            }
            
            return getCellForActiveDownloadTrackInTableView(tableView, forIndexPath: indexPath)
        case 1:
            if downloadedCount == 0 {
                return getCellForNoDownloadedInTableView(tableView, forIndexPath: indexPath)
            }
            
            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    // Возможно ли редактировать ячейку
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            if downloadedCount != 0 {
                return true
            }
        }
        
        return false
    }
    
    // Обработка удаления ячейки
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let trackInPlaylist = downloadsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! TrackInPlaylist
            let track = trackInPlaylist.track
            
            if !DataManager.sharedInstance.deleteTrack(track) {
                let alertController = UIAlertController(title: "Ошибка", message: "При удалении файла произошла ошибка, попробуйте еще раз..", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
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
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}


// MARK: DataManagerDownloadsDelegate

extension DownloadsTableViewController: DataManagerDownloadsDelegate {

    // Контроллер начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        reloadTableView()
    }
    
}


// MARK: DownloadManagerDelegate

extension DownloadsTableViewController: DownloadManagerDelegate {
    
    // Вызывается когда была начата новая загрузка
    func downloadManagerStartTrackDownload(download: Download) {
        if let trackIndex = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .Fade)
            })
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
                
                let isCompleted = download.progress == 1
                dispatch_async(dispatch_get_main_queue(), {
                    activeDownloadCell.cancelButton.hidden = isCompleted
                    activeDownloadCell.pauseButton.hidden = isCompleted
                    activeDownloadCell.progressBar.progress = download.progress
                    activeDownloadCell.progressLabel.text =  isCompleted ? "Сохраняется..." : String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
}
