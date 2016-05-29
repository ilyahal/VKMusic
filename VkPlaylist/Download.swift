//
//  Download.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

class Download: NSObject {
    
    var url: String
    
    var isDownloading = false
    var inQueue = false
    
    var progress: Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    var resumeData: NSData?
    
    
    init(url: String) {
        self.url = url
    }
    
}