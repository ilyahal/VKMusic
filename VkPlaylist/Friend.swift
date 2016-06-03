//
//  Friend.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Друг
class Friend {
    
    /// Идентификатор
    let id: Int
    /// Фамилия
    let last_name: String
    /// Фотография
    let photo_200_orig: String
    /// Имя
    let first_name: String
    
    
    init(id: Int, last_name: String, photo_200_orig: String, first_name: String) {
        self.id = id
        self.last_name = last_name
        self.photo_200_orig = photo_200_orig
        self.first_name = first_name
    }
    
    /// Получение полного имени пользователя
    func getFullName() -> String {
        return first_name + " " + last_name
    }
    
}