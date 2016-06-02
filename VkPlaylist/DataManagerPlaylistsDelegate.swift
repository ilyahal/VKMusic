//
//  DataManagerPlaylistsDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import CoreData

/// Делегат оповещающий об изменениях в котенте плейлистов, управляемом контроллером
protocol DataManagerPlaylistsDelegate: class {
    
    /// Контроллер начал изменять контент
    func dataManagerPlaylistsControllerWillChangeContent()
    
    /// Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerPlaylistsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    /// Контроллер закончил изменять контент
    func dataManagerPlaylistsControllerDidChangeContent()
    
}