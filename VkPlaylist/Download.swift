//
//  Download.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

class Download: NSObject {
    
    var url: String // Ссылка по которой производится загрузка
    
    var isDownloading = false // Скачивается ли сейчас
    var inQueue = false // Находится ли в очереди на загрузку
    
    var progress: Float = 0.0 // Прогресс выполнения загрузки
    
    var downloadTask: NSURLSessionDownloadTask? // Задание на загрузку
    var resumeData: NSData? // Данные для продолжения загрузки после паузы
    
    
    init(url: String) {
        self.url = url
    }
    
}