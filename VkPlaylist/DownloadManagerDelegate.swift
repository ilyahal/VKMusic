//
//  DownloadManagerDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 27.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

// Методы отвечающие за оповещения о процессе загрузки файлов
protocol DownloadManagerDelegate: class {
    
    // 
    func DownloadManagerUpdateStateTrackDownload(download: Download)
    
    // Вызывается когда загрузка была завершена
    func DownloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    
    // Вызывается когда часть данных была загружена
    func DownloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    
}