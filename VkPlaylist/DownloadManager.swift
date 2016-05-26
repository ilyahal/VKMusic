//
//  DownloadManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

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
    
    
    private override init() {}
    
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var activeDownloads = [String: Download]()
    
    func startDownload(track: Track) {
        if let urlString = track.url, url =  NSURL(string: urlString) {
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            download.isDownloading = true
            
            activeDownloads[download.url] = download
        }
    }
}



// MARK: NSURLSessionDownloadDelegate

extension DownloadManager: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
    }
    
}