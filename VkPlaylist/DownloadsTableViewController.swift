//
//  DownloadsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

/// Контроллер содержащий таблицу со списком активных загрузок и уже загруженных аудиозаписей
class DownloadsTableViewController: UITableViewController {

    /// Контроллер массива уже загруженных аудиозаписей
    var downloadsFetchedResultsController: NSFetchedResultsController {
        return DataManager.sharedInstance.downloadsFetchedResultsController
    }
    /// Массив уже загруженных аудиозаписей
    var downloaded: [TrackInPlaylist] {
        return downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist]
    }
    
    /// Массив аудиозаписей, загружаемых сейчас
    var activeDownloads: [String: Download] {
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    /// Была ли нажата кнопка "Пауза" или "Продолжить" (необходимо для плавного обновления)
    var pauseOrResumeTapped = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Загрузка helpers
    
    /// Получение индекса трека в активном массиве для задания загрузки
    func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask?) -> Int? {
        if let url = downloadTask?.originalRequest?.URL?.absoluteString {
            for (index, track) in DownloadManager.sharedInstance.downloadsTracks.enumerate() {
                if url == track.url! {
                    return index
                }
            }
        }
        
        return nil
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что нет загружаемых треков
    var noActiveDownloadsLabelText: String {
        return "Нет активных загрузок"
    }
    
    // Текст для ячейки с сообщением о том, что нет загруженных треков
    var noDownloadedLabelText: String {
        return "Нет загруженных треков"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением об отсутствии загружаемых треков
    func getCellForNoActiveDownloadsInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noActiveDownloadsLabelText
        
        return cell
    }
    
    // Ячейка для строки с загружаемым треком
    func getCellForActiveDownloadTrackInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.activeDownloadCell, forIndexPath: indexPath) as! ActiveDownloadCell
        cell.delegate = self
        
        cell.configureForTrack(track)
        
        var showPauseButton = false // Отображать ли кнопку "Пауза"
        if let download = activeDownloads[track.url!] { // Если аудиозапись есть в списке активных загрузок
            showPauseButton = !download.inQueue // Скрыть кнопку пауза, если загрузка в очереди
            
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
        cell.messageLabel.text = noDownloadedLabelText
        
        return cell
    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = downloaded[indexPath.row]
        let track = trackInPlaylist.track
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        cell.configureForTrack(track)
        
        return cell
    }
    
}


// MARK: UITableViewDataSource

private typealias DownloadsTableViewControllerDataSource = DownloadsTableViewController
extension DownloadsTableViewControllerDataSource {
    
    // Количество секций
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // Секции с загружаемыми и загруженными треками
    }
    
    // Названия секций
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
    
    // Количество строк в секциях
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return activeDownloads.count == 0 ? 1 : activeDownloads.count
        case 1:
            return downloaded.count == 0 ? 1 : downloaded.count
        default:
            return 0
        }
    }
    
    // Ячейки для строк
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if activeDownloads.count == 0 {
                return getCellForNoActiveDownloadsInTableView(tableView, forIndexPath: indexPath)
            }
            
            return getCellForActiveDownloadTrackInTableView(tableView, forIndexPath: indexPath)
        case 1:
            if downloaded.count == 0 {
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
            if downloaded.count != 0 {
                return true
            }
        }
        
        return false
    }
    
    // Обработка удаления ячейки
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let trackInPlaylist = downloaded[indexPath.row]
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

    // Контроллер массива загруженных аудиозаписей начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер массива загруженных аудиозаписей совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер массива загруженных аудиозаписей закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        reloadTableView()
    }
    
}


// MARK: DownloadManagerDelegate

extension DownloadsTableViewController: DownloadManagerDelegate {
    
    // Менеджер загрузок начал новую загрузку
    func downloadManagerStartTrackDownload(download: Download) {
        if let trackIndex = trackIndexForDownloadTask(download.downloadTask) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .Fade)
            })
        }
    }
    
    // Менеджер загрузок изменил состояние загрузки
    func downloadManagerUpdateStateTrackDownload(download: Download) {
        if let trackIndex = trackIndexForDownloadTask(download.downloadTask) {
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
    
    // Менеджер загрузок отменил выполнение загрузки
    func downloadManagerCancelTrackDownload(download: Download) {
        reloadTableView()
    }
    
    // Менеджер загрузок завершил загрузку
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {}
    
    // Вызывается когда часть данных была загружена
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let activeDownloadCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? ActiveDownloadCell {
                download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
                
                let isCompleted = download.progress == 1 // Завершена ли загрузка
                
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


// MARK: ActiveDownloadCellDelegate

extension DownloadsTableViewController: ActiveDownloadCellDelegate {
    
    // Кнопка "Пауза" была нажата
    func pauseTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            
            pauseOrResumeTapped = true
            
            DownloadManager.sharedInstance.pauseDownloadTrack(track)
        }
    }
    
    // Кнопка "Продолжить" была нажата
    func resumeTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            
            pauseOrResumeTapped = true
            
            DownloadManager.sharedInstance.resumeDownloadTrack(track)
        }
    }
    
    // Кнопка "Отмена" была нажата
    func cancelTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            DownloadManager.sharedInstance.cancelDownloadTrack(track)
        }
    }
    
}