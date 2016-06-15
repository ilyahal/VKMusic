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
    
    class var sharedInstance: DataManager {
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
    
    
    /// Стэк CoreData
    var coreDataStack: CoreDataStack!
    
    
    /// Личные аудиозаписи
    let myMusic: DataManagerObject<Track>
    
    /// Искомые аудиозаписи
    let searchMusic: DataManagerObject<Track>
    
    /// Список альбомов
    let albums: DataManagerObject<Album>
    
    /// Аудиозаписи альбома
    let albumMusic: DataManagerObject<Track>
    
    /// Список друзей
    let friends: DataManagerObject<Friend>
    
    /// Список групп
    let groups: DataManagerObject<Group>
    
    /// Аудиозаписи владельца
    let ownerMusic: DataManagerObject<Track>
    
    /// Рекомендуемые аудиозаписи
    let recommendationsMusic: DataManagerObject<Track>
    
    /// Популярные аудиозаписи
    let popularMusic: DataManagerObject<Track>
    
    
    /// Удаление данные при деавторизации
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
    
    
    // MARK: NSUserDefaults
    
    /// Программируемый интерфейс для взаимодействия с системой значений по умолчанию
    var userDefaults: NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    /// Регестрируем дефолтные значения для ключей в NSUserDefaults
    func registerDefaults() {
        var dictionary = [
            DataManagerNSUserDefaultsKeys.firstTime : true, // Флаг на первый запуск программы
            DataManagerNSUserDefaultsKeys.playlistID : 0 // Идентификатор плейлиста
        ]
        
        // Настройки приложения
        dictionary[DataManagerNSUserDefaultsKeys.warningWhenDeletingOfExistenceInPlaylists] = true // При удалении загруженного трека предупреждать о наличии в плейлистах
        
        // Настройки плеера
        dictionary[DataManagerNSUserDefaultsKeys.repeatType] = -1
        dictionary[DataManagerNSUserDefaultsKeys.isShuffle] = false
        
        userDefaults.registerDefaults(dictionary) // Записываем дефолтные значения для указанных ключей
    }
    
    /// Получение идентификатора для нового плейлиста
    func nextPlaylistID() -> Int32 {
        let playlistID = userDefaults.integerForKey(DataManagerNSUserDefaultsKeys.playlistID) // Получение идентификатора для нового плейлиста
        userDefaults.setInteger(playlistID + 1, forKey: DataManagerNSUserDefaultsKeys.playlistID) // Установка нового идентификатора для следующего плейлиста
        userDefaults.synchronize() // Принудительно синхронизируем данные
        
        return Int32(playlistID)
    }
    
    /// Предупреждать ли о наличии в плейлистах при удалении аудиозаписи
    var isWarningWhenDeletingOfExistenceInPlaylists: Bool {
        return userDefaults.boolForKey(DataManagerNSUserDefaultsKeys.warningWhenDeletingOfExistenceInPlaylists)
    }
    
    /// Не предупреждать о наличии в плейлистах при удалении аудиозаписи
    func warningWhenDeletingOfExistenceInPlaylistsDisabled() {
        userDefaults.setBool(false, forKey: DataManagerNSUserDefaultsKeys.warningWhenDeletingOfExistenceInPlaylists)
        userDefaults.synchronize()
    }
    
    /// Предупреждать о наличии в плейлистах при удалении аудиозаписи
    func warningWhenDeletingOfExistenceInPlaylistsEnabled() {
        userDefaults.setBool(true, forKey: DataManagerNSUserDefaultsKeys.warningWhenDeletingOfExistenceInPlaylists)
        userDefaults.synchronize()
    }
    
    /// Тип повторения плейлиста
    var repeatType: PlayerRepeatType {
        switch userDefaults.integerForKey(DataManagerNSUserDefaultsKeys.repeatType) {
        case -1:
            return .No
        case 0:
            return .All
        case 1:
            return .One
        default:
            return .No
        }
    }
    
    /// Установить новый тип повторения плейлиста
    func setNewRepeatType(repeatType: PlayerRepeatType) {
        userDefaults.setInteger(repeatType.rawValue, forKey: DataManagerNSUserDefaultsKeys.repeatType)
        userDefaults.synchronize()
    }
    
    /// Перемешивать ли плейлист
    var isShuffle: Bool {
        return userDefaults.boolForKey(DataManagerNSUserDefaultsKeys.isShuffle)
    }
    
    /// Переключить настройку перемешивания плейлиста
    func switchShuffle() {
        userDefaults.setBool(!isShuffle, forKey: DataManagerNSUserDefaultsKeys.isShuffle)
        userDefaults.synchronize()
    }
    
    
    // MARK: Core Data helpers
    
    /// Проверка базы данных на пустоту
    var isDatabaseEmpty: Bool {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        let count = coreDataStack.context.countForFetchRequest(fetchRequest, error: nil)
        
        if count == 0 {
            return true
        } else {
            return false
        }
    }
    
    /// Создание плейлиста "Загрузки"
    func defaultFillDataBase() {
        let entity = NSEntityDescription.entityForName(EntitiesIdentifiers.playlist, inManagedObjectContext: coreDataStack.context)
            
        let playlist = Playlist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        playlist.id = nextPlaylistID()
        playlist.isVisible = false
        playlist.position = -1
        playlist.title = downloadsPlaylistTitle
        
        coreDataStack.saveContext()
    }
    
    /// Получение плейлиста загрузки
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
    
    /// Плейлист "Загрузки"
    var downloadsPlaylistObject: Playlist!
    
    
    // MARK: Загруженные аудиозаписи
    
    /// Контроллер массива загруженных аудиозаписей
    var downloadsFetchedResultsController: NSFetchedResultsController!
    /// Делегаты контроллера массива загруженных аудиозаписей
    private var dataManagerDownloadsDelegates = [DataManagerDownloadsDelegate]()
    
    /// Добавление нового делегата контроллера массива загруженных аудиозаписей
    func addDataManagerDownloadsDelegate(delegate: DataManagerDownloadsDelegate) {
        if let _ = dataManagerDownloadsDelegates.indexOf({ $0 === delegate}) {
            return
        }
        
        dataManagerDownloadsDelegates.append(delegate)
    }
    
    /// Удаление делегата контроллера массива загруженных аудиозаписей
    func deleteDataManagerDownloadsDelegate(delegate: DataManagerDownloadsDelegate) {
        if let index = dataManagerDownloadsDelegates.indexOf({ $0 === delegate}) {
            dataManagerDownloadsDelegates.removeAtIndex(index)
        }
    }
    
    /// Запрос на получение загруженных аудиозаписей
    var downloadsFetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", downloadsPlaylistObject)
        let positionSort = NSSortDescriptor(key: "position", ascending: true) // Сортировка треков в плейлисте по позиции
        fetchRequest.sortDescriptors = [positionSort]
        
        return fetchRequest
    }
    
    
    /// Загружена ли указанная аудиозапись
    func isDownloadedTrack(track: Track) -> Bool {
        if let _ = getDownloadedCopyOfATrackIfExists(track) {
            return true
        }
        
        return false
    }
    
    /// Получить загруженненный экземпляр аудиозаписи, если существует
    func getDownloadedCopyOfATrackIfExists(track: Track) -> OfflineTrack? {
        return getDownloadedCopyOfATrackIfExistsWithID(track.id, andOwnerID: track.owner_id)
    }
    
    /// Получить загруженненный экземпляр аудиозаписи с указанным ID и указанным ID владельца, если существует
    func getDownloadedCopyOfATrackIfExistsWithID(id: Int32, andOwnerID ownerID: Int32) -> OfflineTrack? {
        for section in downloadsFetchedResultsController.sections! {
            for trackInPlaylist in section.objects as! [TrackInPlaylist] {
                if trackInPlaylist.track.id == id && trackInPlaylist.track.ownerID == ownerID {
                    return trackInPlaylist.track
                }
            }
        }
        
        return nil
    }
    
    /// Список плейлистов, в которых содержится аудиозапись
    func playlistsForTrack(track: OfflineTrack) -> [Playlist] {
        var playlists = [Int32 : Playlist]()
        
        for trackInPlaylist in track.playlists.allObjects as! [TrackInPlaylist] {
            let playlist = trackInPlaylist.playlist
            
            if playlist.isVisible && playlists[playlist.id] == nil {
                playlists[playlist.id] = playlist
            }
        }
        
        return Array(playlists.values)
    }
    
    /// Очередь на запись скаченных аудиозаписей
    var toSaveDownloadedTrackQueue = [(track: Track, artwork: NSData?, lyrics: String, fileLocation: NSURL)]() {
        didSet {
            tryStartWriteFromDownloadedTrackQueue()
        }
    }
    /// Записывается ли загруженный аудиозапись в базу данных сейчас
    var isWriteNow = false
    
    /// Попытка записать аудиозапись в базу данных
    func tryStartWriteFromDownloadedTrackQueue() {
        if !toSaveDownloadedTrackQueue.isEmpty && !isWriteNow {
            isWriteNow = true
            
            let toWrite = toSaveDownloadedTrackQueue.first!
            toSaveDownloadedTrackQueue.removeFirst()
            
            
            // Записываем скаченный файл в папку "Документы"
            let fileManager = NSFileManager.defaultManager()
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString // Получаем путь к папке Documents
            let fileName = NSUUID().UUIDString + ".mp3"
            let fullPath = documentsPath.stringByAppendingPathComponent(fileName)
            let fileURL = NSURL(fileURLWithPath: fullPath) // Возвращаем путь к файлу
            
            do {
                try fileManager.copyItemAtURL(toWrite.fileLocation, toURL: fileURL) // Копируем файл по указанному URL в указанное место
            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
            
            
            // Смещаем все треки в плейлисте "Загрузки" на один вперед
            for trackInPlaylist in downloadsPlaylistObject.tracks.allObjects as! [TrackInPlaylist] {
                // FIXME: Периодически вылетает
                trackInPlaylist.position += 1
            }
            
            // Записываем трек в базу данных
            var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.offlineTrack, inManagedObjectContext: coreDataStack.context) // Сущность оффлайн трека
            
            let offlineTrack = OfflineTrack(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context) // Загруженный трек
            offlineTrack.artist = toWrite.track.artist
            offlineTrack.artwork = toWrite.artwork
            offlineTrack.duration = toWrite.track.duration
            offlineTrack.id = toWrite.track.id
            offlineTrack.ownerID = toWrite.track.owner_id
            offlineTrack.lyrics = toWrite.lyrics
            offlineTrack.title = toWrite.track.title
            offlineTrack.fileName = fileName
            
            // Добавляем загруженный трек в плейлист "Загрузки"
            entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Сущность трека в плейлисте
            
            let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
            trackInPlaylist.playlist = downloadsPlaylistObject
            trackInPlaylist.track = offlineTrack
            
            // Сохраняем изменения
            coreDataStack.saveContext()
            
            
            isWriteNow = false
            tryStartWriteFromDownloadedTrackQueue()
        }
    }
    
    /// Удаление аудиозаписи
    func deleteTrack(track: OfflineTrack) -> Bool {
        
        // Удаляем все вхождения аудиозаписи в плейлисты
        for trackInPlaylist in track.playlists.allObjects as! [TrackInPlaylist] {
            guard deleteTrackFromPlaylist(trackInPlaylist) else {
                return false
            }
        }
        
        // Оповещаем делегатов у удалении
        deletedTrackWithID(track.id, andOwnerID: track.ownerID)
        
        // Удаляем файл аудиозаписи
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(NSURL(fileURLWithPath: track.url)) // Удаляем файл по указанному URL (т.к. появился новый файл с таким же именем)
        } catch let error as NSError {
            print("DataManager can't delete file \(error.localizedDescription)")
        }
        
        // Удаляем аудиозапись из базы данных
        coreDataStack.context.deleteObject(track)
        
        
        coreDataStack.saveContext()
        
        return true
    }
    
    /// Трек с указанным id и id владельца был удален
    func deletedTrackWithID(id: Int32, andOwnerID ownerID: Int32) {
        dataManagerDownloadsDelegates.forEach { delegate in
            delegate.downloadManagerDeleteTrackWithID(id, andOwnerID: ownerID)
        }
    }
    
    /// Перемещение загруженной аудиозаписи
    func moveDownloadedTrack(track: TrackInPlaylist, fromPosition sourcePosition: Int32, toNewPosition newPosition: Int32) {
        
        // Получаем перемещаемую загрузку и помещаем на позицию -1
        track.position = -1
        
        // Перемещаем все плейлисты стоящие после позиции перемещаемого на один назад
        for _track in downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist] {
            if _track.position > sourcePosition {
                _track.position -= 1
            }
        }
        
        // Перемещаем все плейлисты стоящие начиная с новой позиции на один вперед
        for _track in downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist] {
            if _track.position >= newPosition {
                _track.position += 1
            }
        }
        
        // Перемещаем плейлист на новую позицию
        track.position = newPosition
        
        coreDataStack.saveContext()
        
    }
    
    
    /// MARK: Плейлисты
    
    /// Контроллер массива плейлистов
    var playlistsFetchedResultsController: NSFetchedResultsController!
    private var dataManagerPlaylistsDelegates = [DataManagerPlaylistsDelegate]()
    
    /// Добавление нового делегата контроллер массива плейлистов
    func addDataManagerPlaylistsDelegate(delegate: DataManagerPlaylistsDelegate) {
        if let _ = dataManagerPlaylistsDelegates.indexOf({ $0 === delegate}) {
            return
        }
        
        dataManagerPlaylistsDelegates.append(delegate)
    }
    
    /// Удаление делегата контроллер массива плейлистов
    func deleteDataManagerPlaylistsDelegate(delegate: DataManagerPlaylistsDelegate) {
        if let index = dataManagerPlaylistsDelegates.indexOf({ $0 === delegate}) {
            dataManagerPlaylistsDelegates.removeAtIndex(index)
        }
    }
    
    /// Запрос на получение плейлистов
    var playlistsFetchRequest: NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.playlist)
        fetchRequest.predicate = NSPredicate(format: "isVisible == \(true)")
        let positionSort = NSSortDescriptor(key: "position", ascending: true)  // Сортировка плейлистов по позиции
        fetchRequest.sortDescriptors = [positionSort]
        
        return fetchRequest
    }
    
    
    /// Получить название плейлиста
    func getPlaylistTitle(playlist: Playlist) -> String {
        for _playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            if _playlist.id == playlist.id {
                return _playlist.title
            }
        }
        
        return ""
    }
    
    /// Создание нового плейлиста с указанным именем и списком треков
    func createPlaylistWithTitle(title: String, andTracks tracks: [OfflineTrack]) {
        
        // Смещаем все плейлисты на один вперед
        for playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            playlist.position += 1
        }
        
        // Сохраняем новый плейлист
        let entity = NSEntityDescription.entityForName(EntitiesIdentifiers.playlist, inManagedObjectContext: coreDataStack.context) // Объект плейлист
        
        let playlist = Playlist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        playlist.id = nextPlaylistID()
        playlist.isVisible = true
        
        updatePlaylist(playlist, withTitle: title, andTracks: tracks)
        
        coreDataStack.saveContext()
    }
    
    /// Удаление всех треков в плейлисте
    func clearPlaylist(playlist: Playlist) {
        
        // Удаляем все вхождения треков в плейлист
        for trackInPlaylist in playlist.tracks.allObjects as! [TrackInPlaylist] {
            coreDataStack.context.deleteObject(trackInPlaylist)
        }
        
        coreDataStack.saveContext()
    }
    
    /// Обновить название плейлиста на указанное и список аудиозаписей на укзанный
    func updatePlaylist(playlist: Playlist, withTitle title: String, andTracks tracks: [OfflineTrack]) {
        
        playlist.title = title
        
        clearPlaylist(playlist)
        
        // Добавляем аудиозаписи в плейлист
        let entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Объект трек в плейлисте
        for (index, track) in tracks.enumerate() {
            let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
            trackInPlaylist.playlist = playlist
            trackInPlaylist.track = track
            trackInPlaylist.position = Int32(index)
        }
        
        coreDataStack.saveContext()
    }
    
    /// Перемещение плейлиста
    func movePlaylist(playlist: Playlist, fromPosition sourcePosition: Int32, toNewPosition newPosition: Int32) {
        
        // Получаем перемещаемый плейлист и помещаем на позицию -1
        playlist.position = -1
        
        // Перемещаем все плейлисты стоящие после позиции перемещаемого на один назад
        for _playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            if _playlist.position > sourcePosition {
                _playlist.position -= 1
            }
        }
        
        // Перемещаем все плейлисты стоящие начиная с новой позиции на один вперед
        for _playlist in playlistsFetchedResultsController.sections!.first!.objects as! [Playlist] {
            if _playlist.position >= newPosition {
                _playlist.position += 1
            }
        }
        
        // Перемещаем плейлист на новую позицию
        playlist.position = newPosition
        
        coreDataStack.saveContext()
    }
    
    /// Удаление плейлиста
    func deletePlaylist(playlist: Playlist) -> Bool {
        
        clearPlaylist(playlist)
        
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
    
    
    // MARK: Аудиозаписи в плейлисте
    
    /// Получение аудиозаписей из указанного плейлиста
    func getTracksForPlaylist(playlist: Playlist) -> [TrackInPlaylist] {
        let tracksInPlaylist = playlist.tracks.allObjects as! [TrackInPlaylist]
        return tracksInPlaylist.sort({ $0.position < $1.position })
    }
    
    /// Удаление аудиозаписи из плейлиста
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
    
}


extension DataManager: NSFetchedResultsControllerDelegate {
    
    /// Контроллер начал изменять контент
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
    
    /// Контроллер изменил объект
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
    
    /// Контроллер завершил изменение контента
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
