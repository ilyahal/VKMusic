//
//  AddToPlaylistCellDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

protocol AddToPlaylistCellDelegate: class {
    
    // Вызывается при тапе по кнопке "+"
    func addTapped(cell: AddToPlaylistCell)
    
}