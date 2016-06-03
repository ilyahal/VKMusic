//
//  DownloadManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Менеджер загрузок
class DownloadManager: NSObject {
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: DownloadManager? = nil
    }
    
    class var sharedInstance : DownloadManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = DownloadManager()
        }
        
        return Static.instance!
    }
    
    
    private override init() {
        super.init()
        
        _ = downloadsSession
    }
    
    
    /// Сессия для загрузки данных
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("bgSessionConfiguration")
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    /// Делегаты менеджера загрузок
    private var delegates = [DownloadManagerDelegate]()
    
    /// Добавление нового делегата
    func addDelegate(delegate: DownloadManagerDelegate) {
        if let _ = delegates.indexOf({ $0 === delegate}) {
            return
        }
        
        delegates.append(delegate)
    }
    
    /// Удаление делегата
    func deleteDelegate(delegate: DownloadManagerDelegate) {
        if let index = delegates.indexOf({ $0 === delegate}) {
            delegates.removeAtIndex(index)
        }
    }
    
    /// Активные загрузки (в очереди и загружаемые сейчас)
    var activeDownloads = [String: DownloadTrack]() {
        didSet {
            
            // Устанавливаем значение бейджа вкладки "Загрузки"
            dispatch_async(dispatch_get_main_queue(), {
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let tabBarController = delegate.window!.rootViewController as! UITabBarController
                let count = self.activeDownloads.count
                
                tabBarController.tabBar.items![1].badgeValue = count == 0 ? nil : "\(count)"
            })
        }
    }
    /// Загружаемые треки (в очереди и загружаемые сейчас)
    var downloadsTracks = [Track]()
    
    
    /// Количество одновременных загрузок
    let simultaneousDownloadsCount = 2
    
    /// Очередь на загрузку
    var queue = [Download]() {
        didSet {
            tryStartDownloadFromQueue()
        }
    }
    /// Количество треков загружаемых сейчас
    var downloadsNow = 0
    
    /// Попытка начать загрузку из очереди
    func tryStartDownloadFromQueue() {
        if !queue.isEmpty && downloadsNow < simultaneousDownloadsCount {
            downloadsNow += 1
            
            let download = queue.first!
            queue.removeFirst()
            
            download.downloadTask!.resume()
            download.isDownloading = true
            download.inQueue = false
            
            if download is DownloadTrack {
                (download as! DownloadTrack).getArtwork()
                (download as! DownloadTrack).getLyrics()
            }
            
            downloadUpdated(download)
        }
    }
    
    /// Удалить загрузку из очереди
    func deleteFromQueueDownload(download: Download) {
        if download.inQueue {
            download.inQueue = false
            
            downloadUpdated(download)
        }
        
        for (index, downloadInQueue) in queue.enumerate() {
            if downloadInQueue.url == download.url {
                queue.removeAtIndex(index)
                
                return
            }
        }
    }
    
    
    // MARK: Загрузка треков
    
    /// Новая загрузка
    func downloadTrack(track: Track) {
        if let url = NSURL(string: track.url) {
            let download = DownloadTrack(url: track.url, title: track.title, artist: track.artist, lyrics_id: track.lyrics_id)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.inQueue = true
            
            activeDownloads[download.url] = download // Добавляем загрузку трека в список активных загрузок
            downloadsTracks.append(track) // Добавляем трек в список загружаемых
            
            downloadStarted(download)
            
            queue.append(download) // Добавляем загрузку в очередь
        }
    }
    
    /// Отмена выполенения загрузки
    func cancelDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            download.downloadTask?.cancel() // Отменяем выполнение загрузки
            
            if download.isDownloading {
                downloadsNow -= 1
                tryStartDownloadFromQueue()
            }
            deleteFromQueueDownload(download) // Удаляем загрузку из очереди
            
            if download.isArtworkDownloading {
                download.cancelGetArtwork()
            }
            if download.isLyricsDownloading {
                download.cancelGetLyrics()
            }
            
            popTrackForDownloadTask(download.downloadTask!) // Удаляем трек из списка загружаемых
            activeDownloads[track.url] = nil // Удаляем загрузку трека из списка активных загрузок
            
            downloadCanceled(download)
        }
    }
    
    /// Пауза загрузки
    func pauseDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            if download.isDownloading {
                download.downloadTask?.cancelByProducingResumeData { data in
                    if data != nil {
                        download.resumeData = data
                    }
                }
                
                if download.isDownloading {
                    downloadsNow -= 1
                    tryStartDownloadFromQueue()
                }
                deleteFromQueueDownload(download) // Удаляем загрузку из очереди
                
                download.isDownloading = false
                
                downloadUpdated(download)
            }
        }
    }
    
    /// Продолжение загрузки
    func resumeDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
                download.inQueue = true
                
                downloadUpdated(download)
                
                queue.append(download) // Добавляем загрузку в очередь
            } else if let url = NSURL(string: download.url) {
                download.downloadTask = downloadsSession.downloadTaskWithURL(url)
                download.inQueue = true
                
                downloadUpdated(download)
                
                queue.append(download) // Добавляем загрузку в очередь
            }
        }
    }
    
    
    // MARK: Помощники
    
    /// Получение трека для указанной загрузки
    func trackForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Track? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for track in downloadsTracks {
                if url == track.url {
                    return track
                }
            }
        }
        
        return nil
    }
    
    /// Извлекает загружаемый трек из списка загружаемых треков
    func popTrackForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Track? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, track) in downloadsTracks.enumerate() {
                if url == track.url {
                    downloadsTracks.removeAtIndex(index)
                    
                    return track
                }
            }
        }
        
        return nil
    }
    
    /// Загрузка начата
    func downloadStarted(download: Download) {
        if download is DownloadTrack {
            delegates.forEach { delegate in
                delegate.downloadManagerStartTrackDownload(download)
            }
        }
    }
    
    /// Состояние загрузки обновлено
    func downloadUpdated(download: Download) {
        if download is DownloadTrack {
            delegates.forEach { delegate in
                delegate.downloadManagerUpdateStateTrackDownload(download)
            }
        }
    }
    
    /// Загрузка отменена
    func downloadCanceled(download: Download) {
        if download is DownloadTrack {
            delegates.forEach { delegate in
                delegate.downloadManagerCancelTrackDownload(download)
            }
        }
    }
    
}


// MARK: NSURLSessionDelegate

extension DownloadManager: NSURLSessionDelegate {
    
    /// Все загрузки выполняемые в фоне были завершены
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }
}


// MARK: NSURLSessionDownloadDelegate

extension DownloadManager: NSURLSessionDownloadDelegate {
    
    /// Загрузка была завершена
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var track: Track! = nil // Загруженный трек
        var artwork: NSData? // Обложка альбома песни
        var lyrics = "" // Слова песни
        let file = NSData(contentsOfURL: location)! // Загруженный файл
        
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            
            // Получение обложки аудиозаписи
            if activeDownloads[url]!.isArtworkDownloading {
                activeDownloads[url]?.cancelGetArtwork()
                artwork = nil
            } else {
                artwork = activeDownloads[url]!.artwork
            }
            
            // Получение слов аудиозаписи
            if activeDownloads[url]!.isLyricsDownloading {
                activeDownloads[url]?.cancelGetLyrics()
            } else {
                lyrics = activeDownloads[url]!.lyrics!
            }
            
            activeDownloads[url] = nil // Удаляем загрузку трека из списка активных загрузок
            track = popTrackForDownloadTask(downloadTask)! // Извлекаем трек из списка загружаемых треков
            
            downloadsNow -= 1
            tryStartDownloadFromQueue()
        }
        
        DataManager.sharedInstance.toSaveDownloadedTrackQueue.append((track: track, artwork: artwork, lyrics: lyrics, file: file))
        
        
        delegates.forEach { delegate in
            delegate.downloadManagerURLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
        }
    }
    
    /// Часть данных была загружена
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegates.forEach { delegate in
            delegate.downloadManagerURLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }
    
}