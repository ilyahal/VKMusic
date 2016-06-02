//
//  DataManagerObject.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Массив данных, полученных с сервера
class DataManagerObject<T> {
    
    /// Массив данных
    private(set) var array: [T]
    
    init() {
        array = []
    }
    
    
    /// Запоминает новый массив
    func saveNewArray(array: [T]) {
        self.array = array
    }
    
    /// Чистит массив
    func clear() {
        array.removeAll()
    }
    
}