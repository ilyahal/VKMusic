//
//  ActiveDownloadCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Делегат ячейки с активной загрузкой
protocol ActiveDownloadCellDelegate {
    
    /// Кнопка "Пауза" была нажата
    func pauseTapped(cell: ActiveDownloadCell)
    
    /// Кнопка "Продолжить" была нажата
    func resumeTapped(cell: ActiveDownloadCell)
    
    /// Кнопка "Отмена" была нажата
    func cancelTapped(cell: ActiveDownloadCell)
    
}