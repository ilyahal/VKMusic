//
//  DataManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

/// Отвечает за взаимодействие с данными, загруженными на устройство

class DataManager: NSObject {

    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: DataManager? = nil
    }
    
    class var sharedInstance : DataManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = DataManager()
        }
        
        return Static.instance!
    }
    
    
    private override init() {
        coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
        
        myMusic = DataManagerObject<Track>()
        searchMusic = DataManagerObject<Track>()
        albums = DataManagerObject<Album>()
        albumMusic = DataManagerObject<Track>()
        friends = DataManagerObject<Friend>()
        groups = DataManagerObject<Group>()
        ownerMusic = DataManagerObject<Track>()
        recommendationsMusic = DataManagerObject<Track>()
        popularMusic = DataManagerObject<Track>()
        
        
        super.init()
        
        
        downloadsFetchedResultsController = NSFetchedResultsController(fetchRequest: downloadsFetchRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        downloadsFetchedResultsController.delegate = self
        
        do {
            try downloadsFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        
        // Делегат обрабатывающий события изменения загруженного контента
        dataManagerDownloadsDelegate = nil
    }
    
    
    var coreDataStack: CoreDataStack!
    
    
    // Личные аудиозаписи
    let myMusic: DataManagerObject<Track>
    
    // Искомые аудиозаписи
    let searchMusic: DataManagerObject<Track>
    
    // Список альбомов
    let albums: DataManagerObject<Album>
    
    // Аудиозаписи альбома
    let albumMusic: DataManagerObject<Track>
    
    // Список друзей
    let friends: DataManagerObject<Friend>
    
    // Список групп
    let groups: DataManagerObject<Group>
    
    // Аудиозаписи владельца
    let ownerMusic: DataManagerObject<Track>
    
    // Рекомендуемые аудиозаписи
    let recommendationsMusic: DataManagerObject<Track>
    
    // Популярные аудиозаписи
    let popularMusic: DataManagerObject<Track>
    
    
    // Удаляем данные при деавторизации
    func clearDataInCaseOfDeavtorization() {
        myMusic.clear()
        searchMusic.clear()
        albums.clear()
        albumMusic.clear()
        friends.clear()
        groups.clear()
        ownerMusic.clear()
        recommendationsMusic.clear()
        popularMusic.clear()
    }
    
    
    var downloadsFetchedResultsController: NSFetchedResultsController!
    weak var dataManagerDownloadsDelegate: DataManagerDownloadsDelegate?
    
    var downloadsFetchRequest: NSFetchRequest {
        // Получение ссылка на плейлист "Загрузки"
        var playlist: Playlist! = nil
        
        var fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "title == \"\(downloadsPlaylistTitle)\"")
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Playlist]
            
            if results.count != NSNotFound {
                playlist = results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Получение списка загруженных аудиозаписей
        fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", playlist)
        let positionSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [positionSort]
        
        return fetchRequest
    }
    
}


extension DataManager: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsControllerWillChangeContent(controller)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsController(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsController(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsControllerDidChangeContent(controller)
    }
    
}
