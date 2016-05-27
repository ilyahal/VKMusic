//
//  DataManagerDownloadsDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 27.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import CoreData

// Делегат оповещающий об изменениях в котенте управляемом контроллером
protocol DataManagerDownloadsDelegate: class {
    
    // Контроллер начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent(controller: NSFetchedResultsController)
    
    // Контроллер совершил изменения определенного типа в определенной секции по указанному индексу
    func dataManagerDownloadsController(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsController(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    // Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent(controller: NSFetchedResultsController)
    
}