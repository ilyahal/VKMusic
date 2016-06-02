//
//  AudioCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Делегат ячейки с онлайн аудиозаписью
protocol AudioCellDelegate {
    
    /// Кнопка "Пауза" была нажата
    func pauseTapped(cell: AudioCell)
    
    /// Кнопка "Продолжить" была нажата
    func resumeTapped(cell: AudioCell)
    
    /// Кнопка "Отмена" была нажата
    func cancelTapped(cell: AudioCell)
    
    /// Кнопка "Скачать" была нажата
    func downloadTapped(cell: AudioCell)
    
}