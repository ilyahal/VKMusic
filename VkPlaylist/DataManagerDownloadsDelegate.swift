//
//  DataManagerDownloadsDelegate.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData

/// Делегат оповещающий об изменениях в котенте загруженных аудиозаписей, управляемом контроллером
protocol DataManagerDownloadsDelegate: class {
    
    /// Контроллер удалил трек с указанным id и id владельца
    func downloadManagerDeleteTrackWithID(id: Int32, andOwnerID ownerID: Int32)
    
    /// Контроллер начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent()
    
    /// Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    /// Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent()
    
}