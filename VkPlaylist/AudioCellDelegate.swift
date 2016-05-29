//
//  AudioCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 29.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

protocol AudioCellDelegate {
    
    // Вызывается когда была нажата кнопка "Пауза"
    func pauseTapped(cell: AudioCell)
    
    // Вызывается когда была нажата кнопка "Продолжить"
    func resumeTapped(cell: AudioCell)
    
    // Вызывается когда была нажата кнопка "Отмена"
    func cancelTapped(cell: AudioCell)
    
    // Вызывается когда была нажата кнопка "Скачать"
    func downloadTapped(cell: AudioCell)
    
}