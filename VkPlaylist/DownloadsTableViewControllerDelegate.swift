//
//  DownloadsTableViewControllerDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Делегат ViewController "Список загруженных аудиозаписей"
protocol DownloadsTableViewControllerDelegate: class {
    
    /// Список аудиозаписей был изменен
    func downloadsTableViewControllerUpdateContent()
    
    /// Поиск был начат
    func downloadsTableViewControllerSearchStarted()
    
    /// Поиск был закончен
    func downloadsTableViewControllerSearchEnded()
    
}