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
    
    class var sharedInstance: DownloadManager {
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
    
    
    // MARK: Работа с делегатами
    
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
    
    
    // MARK: Доступ к загрузкам
    
    /// Активные загрузки (в очереди и загружаемые сейчас)
    var activeDownloads = [String: Download]() {
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
    /// Загружаемые треки (в очереди и загружаемые сейчас) для списка активных загрузок
    var downloadsTracks = [Track]()
    
    
    // MARK: Очередь
    
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
            
            // Обновляем состояние
            
            download.isDownloading = true
            download.inQueue = false
            
            downloadUpdated(download)
            
            // Начинаем загрузку
            
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
            } else {
                download.downloadTask = downloadsSession.downloadTaskWithURL(download.url)
            }
            download.downloadTask!.resume()
            
            download.getArtwork()
            download.getLyrics()
        }
    }
    
    /// Удалить загрузку из очереди
    func deleteFromQueueDownload(download: Download) {
        if let index = queue.indexOf({ $0 === download}) {
            queue.removeAtIndex(index)
        }
    }
    
    
    // MARK: Загрузка треков
    
    /// Новая загрузка
    func downloadTrack(track: Track) {
        if let download = Download(track: track) {
            download.inQueue = true
            
            activeDownloads[download.url.absoluteString] = download // Добавляем загрузку трека в список активных загрузок
            downloadsTracks.append(track) // Добавляем трек в список загружаемых
            
            downloadStarted(download) // Для обновления состояния ячеек отображающих скачиваемую аудиозапись
            
            queue.append(download) // Добавляем загрузку в очередь
        }
    }
    
    /// Отмена выполенения загрузки
    func cancelDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            
            // Отмена загрузки компонентов аудиозаписи
            download.downloadTask?.cancel() // Отменяем выполнение загрузки
            if download.isArtworkDownloads { // Отменяем загрузку обложки
                download.cancelGetArtwork()
            }
            if download.isLyricsDownloads { // Отменяем загрузку слов аудиозаписи
                download.cancelGetLyrics()
            }
            
            // Обновление состояния
            if download.inQueue {
                download.inQueue = false
                
                deleteFromQueueDownload(download) // Удаляем загрузку из очереди
            } else if download.isDownloading {
                download.isDownloading = false
                downloadsNow -= 1
                
                tryStartDownloadFromQueue()
            }
            
            if let index = downloadsTracks.indexOf({ $0 === download.track}) {
                downloadsTracks.removeAtIndex(index) // Удаляем трек из списка загружаемых
            }
            activeDownloads[track.url] = nil // Удаляем загрузку трека из списка активных загрузок
            
            downloadCanceled(download) // Обновляем ячейки с аудиозаписью
        }
    }
    
    /// Пауза загрузки
    func pauseDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            if download.inQueue {
                download.inQueue = false
                
                downloadUpdated(download) // Обновляем ячейки с аудиозаписью
                
                deleteFromQueueDownload(download) // Удаляем загрузку из очереди
            } else if download.isDownloading {
                download.downloadTask?.cancelByProducingResumeData { data in // Отменяем загрузку, сохраняя загруженные данные
                    download.resumeData = data
                }
                
                download.isDownloading = false
                downloadsNow -= 1
                
                downloadUpdated(download) // Обновляем ячейки с аудиозаписью
                
                tryStartDownloadFromQueue()
            }
        }
    }
    
    /// Продолжение загрузки
    func resumeDownloadTrack(track: Track) {
        if let download = activeDownloads[track.url] {
            download.inQueue = true
            
            downloadUpdated(download) // Обновляем ячейки с аудиозаписью
            
            queue.append(download) // Добавляем загрузку в очередь
        }
    }
    
    
    // MARK: Помощники
    
    /// Загрузка начата
    func downloadStarted(download: Download) {
        delegates.forEach { delegate in
            delegate.downloadManagerStartTrackDownload(download)
        }
    }
    
    /// Состояние загрузки обновлено
    func downloadUpdated(download: Download) {
        delegates.forEach { delegate in
            delegate.downloadManagerUpdateStateTrackDownload(download)
        }
    }
    
    /// Загрузка отменена
    func downloadCanceled(download: Download) {
        delegates.forEach { delegate in
            delegate.downloadManagerCancelTrackDownload(download)
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
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            if let download = activeDownloads[url] {
                let track = download.track // Загруженный трек
                var artwork: NSData? // Обложка альбома песни
                var lyrics: String // Слова песни
                
                // Получение обложки аудиозаписи
                if download.isArtworkDownloads {
                    download.cancelGetArtwork()
                    artwork = nil
                } else {
                    artwork = download.artwork
                }
                
                // Получение слов аудиозаписи
                if download.isLyricsDownloads {
                    download.cancelGetLyrics()
                    lyrics = ""
                } else {
                    lyrics = download.lyrics
                }
                
                // Удаление аудиозаписи из списка активных загрузкок и старт новой загрузки
                if let index = downloadsTracks.indexOf({ $0 === download.track}) {
                    downloadsTracks.removeAtIndex(index) // Удаляем трек из списка загружаемых
                }
                activeDownloads[url] = nil // Удаляем загрузку трека из списка активных загрузок
                
                downloadsNow -= 1
                tryStartDownloadFromQueue()
                
                // Сохранение данных
                DataManager.sharedInstance.toSaveDownloadedTrackQueue.append((track: track, artwork: artwork, lyrics: lyrics, fileLocation: location))
                
                // Оповещение делегатов о изменениях
                delegates.forEach { delegate in
                    delegate.downloadManagerdidFinishDownloadingDownload(download)
                }
            }
        }
    }
    
    /// Часть данных была загружена
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            if let download = activeDownloads[url] {
                download.totalBytesWritten = totalBytesWritten
                download.totalBytesExpectedToWrite = totalBytesExpectedToWrite
                
                delegates.forEach { delegate in
                    delegate.downloadManagerURLSessionDidWriteDataForDownload(download)
                }
            }
        }
    }
    
}