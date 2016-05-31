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
        
         // Регестрируем дефолтные значения для ключей в NSUserDefaults
        registerDefaults()
        
        // Дефолтное наполнение базы данных
        if isDatabaseEmpty {
            defaultFillDataBase()
        }
        
        downloadsPlaylistObject = getDownloadsPlaylistObject
        
        // Контроллер следящий за загруженными треками
        downloadsFetchedResultsController = NSFetchedResultsController(fetchRequest: downloadsFetchRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        downloadsFetchedResultsController.delegate = self
        
        do {
            try downloadsFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        // Контроллер следящий за плейлистами
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
    
    
    // Удаление данные при деавторизации
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
    
    
    // NSUserDefaults
    
    // Регестрируем дефолтные значения для ключей в NSUserDefaults
    func registerDefaults() {
        let dictionary = [
            "FirstTime": true, // Флаг на первый запуск программы
            "PlaylistID": 0 // Идентификатор плейлиста
        ]
        
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary) // Записываем дефолтные значения для указанных ключей
    }
    
    // Получение идентификатора для нового плейлиста
    func nextPlaylistID() -> Int32 {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let playlistID = userDefaults.integerForKey("PlaylistID") // Получение идентификатора для нового плейлиста
        userDefaults.setInteger(playlistID + 1, forKey: "PlaylistID") // Установка нового идентификатора для следующего плейлиста
        userDefaults.synchronize() // Принудительно синхронизируем данные
        
        return Int32(playlistID)
    }
    
    
    // MARK: Core Data helpers
    
    // Проверка базы данных на пустоту
    var isDatabaseEmpty: Bool {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        let count = coreDataStack.context.countForFetchRequest(fetchRequest, error: nil)
        
        if count == 0 {
            return true
        } else {
            return false
        }
    }
    
    // Создание плейлиста "Загрузки"
    func defaultFillDataBase() {
        let entity = NSEntityDescription.entityForName(EntitiesIdentifiers.playlist, inManagedObjectContext: coreDataStack.context)
            
        let playlist = Playlist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        playlist.id = nextPlaylistID()
        playlist.isVisible = false
        playlist.position = -1
        playlist.title = downloadsPlaylistTitle
        
        coreDataStack.saveContext()
    }
    
    // Получение плейлиста загрузки
    var getDownloadsPlaylistObject: Playlist! {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "id == \(0)")
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Playlist]
            
            if results.count != NSNotFound {
                return results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        // TODO: Если плейлиста нет - создать заново
        abort()
    }
    
    var downloadsPlaylistObject: Playlist!
    
    
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
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", downloadsPlaylistObject)
        let positionSort = NSSortDescriptor(key: "position", ascending: true) // Сортировка треков в плейлисте по позиции
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
            for trackInPlaylist in downloadsPlaylistObject.tracks.allObjects as! [TrackInPlaylist] {
                // FIXME: Периодически вылетает
                trackInPlaylist.position += 1
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
            trackInPlaylist.playlist = downloadsPlaylistObject
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
        
        // Удаляем все вхождения трека в плейлисты
        for trackInPlaylist in track.playlists.allObjects as! [TrackInPlaylist] {
            guard deleteTrackFromPlaylist(trackInPlaylist) else {
                return false
            }
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
        let positionSort = NSSortDescriptor(key: "position", ascending: true)  // Сортировка плейлистов по позиции
        fetchRequest.sortDescriptors = [positionSort]
        
        return fetchRequest
    }
    
    
    // Создание нового плейлиста с указанным именем и списком треков
    func createPlaylistWithTitle(title: String, andTracks tracks: [OfflineTrack]) {
        
        // Смещаем все плейлисты на один вперед
        for playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            playlist.position += 1
        }
        
        // Сохраняем новый плейлист
        var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.playlist, inManagedObjectContext: coreDataStack.context) // Объект плейлист
        
        let playlist = Playlist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        playlist.id = nextPlaylistID()
        playlist.isVisible = true
        playlist.position = 0
        playlist.title = title
        
        
        // Добавляем аудиозаписи в плейлист
        entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Объект трек в плейлисте
        for (index, track) in tracks.enumerate() {
            let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
            trackInPlaylist.playlist = playlist
            trackInPlaylist.track = track
            trackInPlaylist.position = Int32(index)
        }
        
        coreDataStack.saveContext()
    }
    
    // Удаление плейлиста
    func deletePlaylist(playlist: Playlist) -> Bool {
        
        // Удаляем все вхождения треков в плейлист
        for trackInPlaylist in playlist.tracks.allObjects as! [TrackInPlaylist] {
            coreDataStack.context.deleteObject(trackInPlaylist)
        }
        
        // Сдвигаем все плейлисты находящиеся после этого на 1 назад
        for _playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            if _playlist.position > playlist.position {
                _playlist.position -= 1
            }
        }
        
        // Удаляем плейлист
        coreDataStack.context.deleteObject(playlist)
        
        coreDataStack.saveContext()
        
        return true
    }
    
    
    // MARK: Треки в плейлисте
    
    // Получение треков из указанного плейлиста
    func getTracksForPlaylist(playlist: Playlist) -> [TrackInPlaylist] {
        let tracksInPlaylist = playlist.tracks.allObjects as! [TrackInPlaylist]
        return tracksInPlaylist.sort({ $0.position < $1.position })
    }
    
    // Удаление трека из плейлиста
    func deleteTrackFromPlaylist(trackInPlaylist: TrackInPlaylist) -> Bool {
        
        // Сдвигаем все треки находящиеся в плейлисте после удаляемого
        for _trackInPlaylist in trackInPlaylist.playlist.tracks.allObjects as! [TrackInPlaylist] {
            if _trackInPlaylist.position > trackInPlaylist.position {
                _trackInPlaylist.position -= 1
            }
        }
        
        // Удаляем вхождение трека в плейлист
        coreDataStack.context.deleteObject(trackInPlaylist)
        
        coreDataStack.saveContext()
        
        return true
    }
    
    // Перемещение трека в плейлисте
    func moveTrackInPlaylist(trackInPlaylist: TrackInPlaylist, fromPosition sourcePosition: Int32, toNewPosition newPosition: Int32) {
        
        // Получаем перемещаемый трек и помещаем на позицию -1
        trackInPlaylist.position = -1
        
        // Перемещаем все треки стоящие после позиции перемещаемого на один назад
        for _trackInPlaylist in trackInPlaylist.playlist.tracks.allObjects as! [TrackInPlaylist] {
            if _trackInPlaylist.position > sourcePosition {
                _trackInPlaylist.position -= 1
            }
        }
        
        // Перемещаем все треки стоящие начиная с новой позиции на один вперед
        for _trackInPlaylist in trackInPlaylist.playlist.tracks.allObjects as! [TrackInPlaylist] {
            if _trackInPlaylist.position >= newPosition {
                _trackInPlaylist.position += 1
            }
        }
        
        // Перемещаем трек на новую позицию
        trackInPlaylist.position = newPosition
        
        coreDataStack.saveContext()
    }
    
}


extension DataManager: NSFetchedResultsControllerDelegate {
    
    // Контроллер начал изменять контент
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
    
    // Контроллер изменил объект
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
    
    // Контроллер завершил изменение контента
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
