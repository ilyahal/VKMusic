//
//  Download.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Загрузка
class Download: NSObject {
    
    /// Ссылка по которой производится загрузка
    var url: String
    
    /// Скачивается ли сейчас
    var isDownloading = false
    /// Находится ли в очереди на загрузку
    var inQueue = false
    
    /// Прогресс выполнения загрузки
    var progress: Float = 0.0
    
    /// Задание на загрузку
    var downloadTask: NSURLSessionDownloadTask?
    /// Данные для продолжения загрузки после паузы
    var resumeData: NSData?
    
    
    init(url: String) {
        self.url = url
    }
    
}