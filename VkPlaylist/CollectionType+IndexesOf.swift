//
//  CollectionType+IndexesOf.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

extension CollectionType {
    
    /// Возвращает индексы элементов, удовлетворяющих условию
    func indexesOf(@noescape predicate: (Self.Generator.Element) -> Bool) -> [Int] {
        var indexes = [Int]()
        
        for (index, item) in self.enumerate() {
            if predicate(item){
                indexes.append(index)
            }
        }
        
        return indexes
    }
    
}