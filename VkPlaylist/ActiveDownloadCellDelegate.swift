//
//  ActiveDownloadCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

protocol ActiveDownloadCellDelegate {
    
    // Вызывается когда была нажата кнопка "Пауза"
    func pauseTapped(cell: ActiveDownloadCell)
    
    // Вызывается когда была нажата кнопка "Продолжить"
    func resumeTapped(cell: ActiveDownloadCell)
    
    // Вызывается когда была нажата кнопка "Отмена"
    func cancelTapped(cell: ActiveDownloadCell)
    
}