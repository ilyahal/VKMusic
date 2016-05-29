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
    
    
    var downloadsPlaylistObject: Playlist? {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "title == \"\(downloadsPlaylistTitle)\"")
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Playlist]
            
            if results.count != NSNotFound {
                return results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    
    var downloadsFetchedResultsController: NSFetchedResultsController!
    weak var dataManagerDownloadsDelegate: DataManagerDownloadsDelegate?
    
    // Запрос на получение загруженных треков
    var downloadsFetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", downloadsPlaylistObject!)
        let positionSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [positionSort]
        
        return fetchRequest
    }
    
    
    // Загружен ли указанный трек
    func isDownloadedTrack(track: Track) -> Bool {
        for section in downloadsFetchedResultsController.sections! {
            for trackInPlaylist in section.objects as! [TrackInPlaylist] {
                if trackInPlaylist.track.id == track.id && trackInPlaylist.track.ownerID == track.owner_id {
                    return true
                }
            }
        }
        
        return false
    }
    
    var toSaveDownloadedTrackQueue = [(track: Track, file: NSData)]() { // Очередь на запись скаченных треков
        didSet {
            tryStartWriteFromDownloadedTrackQueue()
        }
    }
    var isWriteNow = false // Записывается ли загруженный трек в базу данных сейчас
    
    // Попытка записать трек в базу данных
    func tryStartWriteFromDownloadedTrackQueue() {
        if !toSaveDownloadedTrackQueue.isEmpty && !isWriteNow {
            isWriteNow = true
            
            let toWrite = toSaveDownloadedTrackQueue.first!
            toSaveDownloadedTrackQueue.removeFirst()
            
            
            // Смещаем все треки в плейлисте "Загрузки" на один вперед
            let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
            fetchRequest.predicate = NSPredicate(format: "playlist == %@", downloadsPlaylistObject!)
            
            do {
                let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [TrackInPlaylist]
                
                if results.count != NSNotFound {
                    for trackInPlaylist in results {
                        trackInPlaylist.position += 1
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            
            // Записываем трек в базу данных
            var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.offlineTrack, inManagedObjectContext: coreDataStack.context) // Сущность оффлайн трека
            
            let offlineTrack = OfflineTrack(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context) // Загруженный трек
            offlineTrack.artist = toWrite.track.artist!
            offlineTrack.duration = toWrite.track.duration!
            offlineTrack.file = toWrite.file
            offlineTrack.id = toWrite.track.id!
            offlineTrack.ownerID = toWrite.track.owner_id!
            offlineTrack.lyrics = "" // TODO: Текст песни загружать с вк
            offlineTrack.title = toWrite.track.title!
            
            
            // Добавляем загруженный трек в плейлист "Загрузки"
            entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Сущность трека в плейлисте
            
            let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
            trackInPlaylist.playlist = downloadsPlaylistObject!
            trackInPlaylist.track = offlineTrack
            trackInPlaylist.position = 0
            
            
            // Сохраняем изменения
            coreDataStack.saveContext()
            
            
            isWriteNow = false
            tryStartWriteFromDownloadedTrackQueue()
        }
    }
    
}


extension DataManager: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsControllerWillChangeContent()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsControllerDidChangeObject(anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dataManagerDownloadsDelegate?.dataManagerDownloadsControllerDidChangeContent()
    }
    
}
