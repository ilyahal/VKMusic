//
//  DownloadManagerDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 27.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Методы отвечающие за оповещения о процессе загрузки файлов
protocol DownloadManagerDelegate: class {
    
    /// Вызывается когда была начата новая загрузка
    func downloadManagerStartTrackDownload(download: Download)
    
    /// Вызывается когда состояние загрузки было изменено
    func downloadManagerUpdateStateTrackDownload(download: Download)
    
    /// Вызывается когда загрузка была отменена
    func downloadManagerCancelTrackDownload(download: Download)
    
    /// Вызывается когда загрузка была завершена
    func downloadManagerdidFinishDownloadingDownload(download: Download)
    
    /// Вызывается когда часть данных была загружена
    func downloadManagerURLSessionDidWriteDataForDownload(download: Download)
    
}