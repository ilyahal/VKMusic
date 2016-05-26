//
//  MusicFromInternetTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

class MusicFromInternetTableViewController: UITableViewController {
    
    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    var coreDataStack: CoreDataStack!
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var activeDownloads = [String: Download]()
    var downloadsTracks = [Track]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
        
        
        // Настройка Pull-To-Refresh
        if VKAPIManager.isAuthorized {
            pullToRefreshEnable(true)
        }
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.accessErrorCell, bundle: nil) // Ячейка "Ошибка доступа"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.accessErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.audioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.audioCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            if VKAPIManager.isAuthorized {
                pullToRefreshEnable(true)
            } else {
                pullToRefreshEnable(false)
            }
        }
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
    
    
    // MARK: Pull-to-Refresh
    
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            refreshControl = UIRefreshControl()
            //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
            refreshControl!.addTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
        } else {
            refreshControl?.removeTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged)
            refreshControl = nil
        }
    }
    
    func refreshMusic() {}
    
    
    // MARK: Загрузка helpers
    
    func isDownloadedTrack(track: Track) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.offlineTrack)
        fetchRequest.predicate = NSPredicate(format: "id == \(track.id!)")
        
        let count = coreDataStack.context.countForFetchRequest(fetchRequest, error: nil)
        
        if count == 0 {
            return false
        } else {
            return true
        }
    }
    
    func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        return nil
    }
    
    func popTrackForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Track? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, track) in downloadsTracks.enumerate() {
                if url == track.url! {
                    downloadsTracks.removeAtIndex(index)
                    
                    return track
                }
            }
        }
        
        return nil
    }
    
    // MARK: Загрузка
    
    func startDownload(track: Track) {
        if let urlString = track.url, url =  NSURL(string: urlString) {
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            download.isDownloading = true
            
            activeDownloads[download.url] = download
            downloadsTracks.append(track)
        }
    }
    
    func cancelDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
        }
    }
    
    func pauseDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            if(download.isDownloading) {
                download.downloadTask?.cancelByProducingResumeData { data in
                    if data != nil {
                        download.resumeData = data
                    }
                }
                download.isDownloading = false
            }
        }
    }
    
    func resumeDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
                download.downloadTask!.resume()
                download.isDownloading = true
            } else if let url = NSURL(string: download.url) {
                download.downloadTask = downloadsSession.downloadTaskWithURL(url)
                download.downloadTask!.resume()
                download.isDownloading = true
            }
        }
    }

}


// MARK: AudioCellDelegate

extension MusicFromInternetTableViewController: AudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: AudioCell) {
        print("pause" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: AudioCell) {
        print("resume" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: AudioCell) {
        print("cancel" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Скачать
    func downloadTapped(cell: AudioCell) {
        print("download" + cell.nameLabel.text!)
    }
    
}


// MARK: UITableViewDelegate

private typealias MusicFromInternetTableViewControllerDelegate = MusicFromInternetTableViewController
extension MusicFromInternetTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
}


// MARK: NSURLSessionDownloadDelegate

extension MusicFromInternetTableViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        // Загруженный трек
        let track = popTrackForDownloadTask(downloadTask)!
        let file = NSData(contentsOfURL: location) // Загруженный файл
        
        var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.offlineTrack, inManagedObjectContext: coreDataStack.context) // Сущность оффлайн трека
        
        let offlineTrack = OfflineTrack(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context) // Загруженный трек
        offlineTrack.artist = track.artist
        offlineTrack.duration = track.duration
        offlineTrack.file = file
        offlineTrack.id = track.id
        offlineTrack.lyrics = "" // TODO: Текст песни загружать с вк
        offlineTrack.title = track.title
        
        
        // Плейлист "Загрузки"
        var playlist: Playlist! = nil
        
        var fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "title == \"\(downloadsPlaylistTitle)\"")
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Playlist]
            
            if results.count != NSNotFound {
                playlist = results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        // Смещаем все треки на один вперед
        fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", playlist)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [TrackInPlaylist]
            
            if results.count != NSNotFound {
                for trackInPlaylist in results {
                    trackInPlaylist.position = NSNumber(integer: trackInPlaylist.position!.integerValue + 1)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        // Добавляем загруженный трек в плейлист "Загрузки"
        entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Сущность трека в плейлисте
        
        let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        trackInPlaylist.playlist = playlist
        trackInPlaylist.track = offlineTrack
        trackInPlaylist.position = 0
        
        
        // Сохраняем изменения
        coreDataStack.saveContext()
        
        
        // Обновляем ячейку
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            activeDownloads[url] = nil
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
                })
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let audioCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? AudioCell {
                dispatch_async(dispatch_get_main_queue(), {
                    audioCell.progressBar.progress = download.progress
                    audioCell.progressLabel.text =  String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
}