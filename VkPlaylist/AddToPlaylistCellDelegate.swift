//
//  AddToPlaylistCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Делегат ячейки с добавляемой в плейлист офлайн аудиозаписью
protocol AddToPlaylistCellDelegate: class {
    
    /// Кнопка "Добавить" была нажата
    func addTapped(cell: AddToPlaylistCell)
    
}