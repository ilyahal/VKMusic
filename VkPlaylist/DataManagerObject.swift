//
//  DataManagerObject.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class DataManagerObject<T> {
    
    private(set) var array: [T]
    
    init() {
        array = []
    }
    
    
    // Запоминает новый массив
    func update(array: [T]) {
        self.array = array
    }
    
    // Чистит массив
    func clear() {
        array.removeAll()
    }
    
}