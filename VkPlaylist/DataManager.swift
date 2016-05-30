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
        
        
        playlistsFetchedResultsController = NSFetchedResultsController(fetchRequest: playlistsFetchRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        playlistsFetchedResultsController.delegate = self
        
        do {
            try playlistsFetchedResultsController.performFetch()
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
    
    
    // MARK: Загруженные треки
    
    var downloadsFetchedResultsController: NSFetchedResultsController!
    private var dataManagerDownloadsDelegates = [DataManagerDownloadsDelegate]()
    
    // Добавление нового делегата
    func addDataManagerDownloadsDelegate(delegate: DataManagerDownloadsDelegate) {
        if let _ = dataManagerDownloadsDelegates.indexOf({ $0 === delegate}) {
            return
        }
        
        dataManagerDownloadsDelegates.append(delegate)
    }
    
    // Удаление делегата
    func deleteDataManagerDownloadsDelegate(delegate: DataManagerDownloadsDelegate) {
        if let index = dataManagerDownloadsDelegates.indexOf({ $0 === delegate}) {
            dataManagerDownloadsDelegates.removeAtIndex(index)
        }
    }
    
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
    
    // Удаление трека
    func deleteTrack(track: OfflineTrack) -> Bool {
        let id = track.id
        let ownerID = track.ownerID
        
        
        // Получаем ссылку на удаляемый трек
        let track: OfflineTrack!
        
        var fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.offlineTrack)
        let IDPredicate = NSPredicate(format: "id == \(id)")
        let ownerIDPredicate = NSPredicate(format: "ownerID == \(ownerID)")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [IDPredicate, ownerIDPredicate])
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [OfflineTrack]
            
            if results.count != NSNotFound {
                track = results.first
            } else {
                track = nil
            }
        } catch let error as NSError {
            track = nil
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        guard let _ = track else {
            print("Track not found!")
            return false
        }
        
        
        // Получаем массив вхождений трека в плейлисты
        fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "track == %@", track)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [TrackInPlaylist]
            
            if results.count != NSNotFound {
                for trackInPlaylist in results {
                    
                    // Все треки находящиеся в этом плейлисте после удаляемого трека сдвигаем на одну позицию вниз
                    let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
                    let playlistPredicate = NSPredicate(format: "playlist == %@", trackInPlaylist.playlist)
                    let positionPredicate = NSPredicate(format: "position > \(trackInPlaylist.position)")
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [playlistPredicate, positionPredicate])
                    
                    do {
                        let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [TrackInPlaylist]
                        
                        if results.count != NSNotFound {
                            for trackInPlaylist in results {
                                trackInPlaylist.position -= 1
                            }
                        }
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                        return false
                    }
                    
                    // Удаляем вхождение трека в плейлист
                    coreDataStack.context.deleteObject(trackInPlaylist)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
        
        // Удаляем трек
        coreDataStack.context.deleteObject(track)
        
        
        coreDataStack.saveContext()
        
        return true
    }
    
    
    // MARK: Плейлисты
    
    var playlistsFetchedResultsController: NSFetchedResultsController!
    private var dataManagerPlaylistsDelegates = [DataManagerPlaylistsDelegate]()
    
    // Добавление нового делегата
    func addDataManagerPlaylistsDelegate(delegate: DataManagerPlaylistsDelegate) {
        if let _ = dataManagerPlaylistsDelegates.indexOf({ $0 === delegate}) {
            return
        }
        
        dataManagerPlaylistsDelegates.append(delegate)
    }
    
    // Удаление делегата
    func deleteDataManagerPlaylistsDelegate(delegate: DataManagerPlaylistsDelegate) {
        if let index = dataManagerPlaylistsDelegates.indexOf({ $0 === delegate}) {
            dataManagerPlaylistsDelegates.removeAtIndex(index)
        }
    }
    
    // Запрос на получение плейлистов
    var playlistsFetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "isVisible == \(true)")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        return fetchRequest
    }
    
    
    // Существует ли плейлист с указанным именем
    func isExistsPlaylistWithTitle(title: String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let count = coreDataStack.context.countForFetchRequest(fetchRequest, error: nil)
        
        if count == 1 {
            return true
        }
        
        return false
    }
    
    // Создание нового плейлиста с указанным именем и списком треков
    func createPlaylistWithTitle(title: String, andTracks tracks: [OfflineTrack]) {
        var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.playlist, inManagedObjectContext: coreDataStack.context) // Объект плейлист
        
        let playlist = Playlist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        playlist.date = NSDate()
        playlist.isVisible = true
        playlist.title = title
        
        entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Объект трек в плейлисте
        for (index, track) in tracks.enumerate() {
            let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
            trackInPlaylist.playlist = playlist
            trackInPlaylist.track = track
            trackInPlaylist.position = Int32(index)
        }
        
        coreDataStack.saveContext()
    }
    
}


extension DataManager: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if controller == downloadsFetchedResultsController {
            dataManagerDownloadsDelegates.forEach { delegate in
                delegate.dataManagerDownloadsControllerWillChangeContent()
            }
        } else if controller == playlistsFetchedResultsController {
            dataManagerPlaylistsDelegates.forEach { delegate in
                delegate.dataManagerPlaylistsControllerWillChangeContent()
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if controller == downloadsFetchedResultsController {
            dataManagerDownloadsDelegates.forEach { delegate in
                delegate.dataManagerDownloadsControllerDidChangeObject(anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
            }
        } else if controller == playlistsFetchedResultsController {
            dataManagerPlaylistsDelegates.forEach { delegate in
                delegate.dataManagerPlaylistsControllerDidChangeObject(anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if controller == downloadsFetchedResultsController {
            dataManagerDownloadsDelegates.forEach { delegate in
                delegate.dataManagerDownloadsControllerDidChangeContent()
            }
        } else if controller == playlistsFetchedResultsController {
            dataManagerPlaylistsDelegates.forEach { delegate in
                delegate.dataManagerPlaylistsControllerDidChangeContent()
            }
        }
    }
    
}
