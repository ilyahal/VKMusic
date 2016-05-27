//
//  MusicFromInternetTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

class MusicFromInternetTableViewController: UITableViewController {
    
    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    var coreDataStack: CoreDataStack!
    
    var music: [Track]! = [] // Массив для результатов запроса
    var activeArray: [Track] { // Массив аудиозаписей отображаемый на экране
        return music
    }
    
    var getRequest: (() -> Void)! { // Запрос на получение данных с сервера
        return nil
    }
    var requestManagerStatus: RequestManagerObject.State { // Статус выполнения запроса
        return RequestManagerObject.State.NotSearchedYet
    }
    var requestManagerError: RequestManagerObject.ErrorRequest { // Ошибки при выполнении запроса
        return RequestManagerObject.ErrorRequest.None
    }
    
    lazy var downloadsSession: NSURLSession = { // Загрузочная сессия
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var activeDownloads = [String: Download]() // Активные загрузки
    var downloadsTracks = [Track]() // Загружаемые треки
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
        
        
        // Настройка Pull-To-Refresh
        if VKAPIManager.isAuthorized {
            pullToRefreshEnable(true)
        }
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.accessErrorCell, bundle: nil) // Ячейка "Ошибка доступа"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.accessErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.audioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.audioCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            if VKAPIManager.isAuthorized {
                pullToRefreshEnable(true)
            } else {
                pullToRefreshEnable(false)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Получение количества строк таблицы
    
    // Получение количества строк в таблице при статусе "NotSearchedYet" и ошибкой при подключении к интернету
    func numberOfRowsForNotSearchedYetStatusWithInternetErrorInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением об отсутствии интернет соединения
    }
    
    // Получение количества строк в таблице при статусе "NotSearchedYet" и ошибкой при подключении к интернету
    func numberOfRowsForNotSearchedYetStatusWithAccessErrorInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением об отсутствии доступа
    }
    
    // Получение количества строк в таблице при статусе "NotSearchedYet"
    func numberOfRowsForNotSearchedYetStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 0
    }
    
    // Получение количества строк в таблице при статусе "Loading"
    func numberOfRowsForLoadingStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        if let refreshControl = refreshControl where refreshControl.refreshing {
            return activeArray.count + 1
        }
        
        return 1 // Ячейка с индикатором загрузки
    }
    
    // Получение количества строк в таблице при статусе "NoResults"
    func numberOfRowsForNoResultsStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейки с сообщением об отсутствии личных аудиозаписей
    }
    
    // Получение количества строк в таблице при статусе "Results"
    func numberOfRowsForResultsStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return activeArray.count + 1 // +1 - ячейка для вывода количества строк
    }
    
    // Получение количества строк в таблице при статусе "Не авторизован"
    func numberOfRowsForNoAuthorizedStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var textForNoResultsRow: String {
        return "Список пуст"
    }
    
    // Получение количества треков в списке для ячейки с количеством аудиозаписей
    func getCountForCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        let count: Int?
        
        if activeArray.count == indexPath.row {
            count = activeArray.count
        } else {
            count = nil
        }
        
        return count
    }
    
    // Получение трека для ячейки с треком
    func getTrackForCellForRowWithAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Track {
        return activeArray[indexPath.row]
    }
    
    // Текст для ячейки с сообщением о необходимости авторизоваться
    var textForNoAuthorizedRow: String {
        return "Необходимо авторизоваться"
    }

    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки когда поиск еще не выполнялся и была получена ошибка при подключении к интернету
    func getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
        
        return cell
    }
    
    // Ячейка для строки когда поиск еще не выполнялся и была получена ошибка доступа
    func getCellForNotSearchedYetRowWithAccessErrorInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.accessErrorCell, forIndexPath: indexPath) as! AccessErrorCell
        
        return cell
    }
    
    // Ячейка для строки когда поиск еще не выполнялся
    func getCellForNotSearchedYetRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // Ячейка для строки с сообщением что сервер вернул пустой массив
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoResultsRow
        
        return cell
    }
    
    // Ячейка для строки с сообщением о загрузке
    func getCellForLoadingRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством аудиозаписей
    func getCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = getCountForCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Audio, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с аудиозаписью
    func getCellForRowWithAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = getTrackForCellForRowWithAudioInTableView(tableView, forIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
        cell.delegate = self
        cell.configureForTrack(track)
        
        let downloaded = isDownloadedTrack(track)
        
        var showDownloadControls = false
        if let download = activeDownloads[track.url!] {
            showDownloadControls = true
            
            cell.progressBar.progress = download.progress
            cell.progressLabel.text = (download.isDownloading) ? "Загружается..." : "Пауза"
            
            let title = (download.isDownloading) ? "Пауза" : "Продолжить"
            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
        }
        cell.progressBar.hidden = !showDownloadControls
        cell.progressLabel.hidden = !showDownloadControls
        
        cell.downloadButton.hidden = downloaded || showDownloadControls
        
        cell.pauseButton.hidden = !showDownloadControls
        cell.cancelButton.hidden = !showDownloadControls
        
        return cell
    }
    
    // Ячейка для строки с сообщением о необходимости авторизоваться
    func getCellForNoAuthorizedRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = textForNoAuthorizedRow
        
        return cell
    }
    
    
    // MARK: Pull-to-Refresh
    
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            refreshControl = UIRefreshControl()
            //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
            refreshControl!.addTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
        } else {
            refreshControl?.removeTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged)
            refreshControl = nil
        }
    }
    
    func refreshMusic() {
        getRequest()
    }
    
    
    // MARK: Загрузка helpers
    
    func isDownloadedTrack(track: Track) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.offlineTrack)
        fetchRequest.predicate = NSPredicate(format: "id == \(track.id!)")
        
        let count = coreDataStack.context.countForFetchRequest(fetchRequest, error: nil)
        
        if count == 0 {
            return false
        } else {
            return true
        }
    }
    
    // Получение индекса трека для загружаемого файла
    func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, track) in activeArray.enumerate() {
                if url == track.url! {
                    return index
                }
            }
        }
        return nil
    }
    
    func popTrackForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Track? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            for (index, track) in downloadsTracks.enumerate() {
                if url == track.url! {
                    downloadsTracks.removeAtIndex(index)
                    
                    return track
                }
            }
        }
        
        return nil
    }
    
    // MARK: Загрузка
    
    func startDownload(track: Track) {
        if let urlString = track.url, url =  NSURL(string: urlString) {
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            download.isDownloading = true
            
            activeDownloads[download.url] = download
            downloadsTracks.append(track)
        }
    }
    
    func cancelDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
        }
    }
    
    func pauseDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            if(download.isDownloading) {
                download.downloadTask?.cancelByProducingResumeData { data in
                    if data != nil {
                        download.resumeData = data
                    }
                }
                download.isDownloading = false
            }
        }
    }
    
    func resumeDownload(track: Track) {
        if let urlString = track.url, download = activeDownloads[urlString] {
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
                download.downloadTask!.resume()
                download.isDownloading = true
            } else if let url = NSURL(string: download.url) {
                download.downloadTask = downloadsSession.downloadTaskWithURL(url)
                download.downloadTask!.resume()
                download.isDownloading = true
            }
        }
    }

}


// MARK: AudioCellDelegate

extension MusicFromInternetTableViewController: AudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            pauseDownload(track)
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            resumeDownload(track)
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            cancelDownload(track)
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Скачать
    func downloadTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            startDownload(track)
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias MusicFromInternetTableViewControllerDataSource = MusicFromInternetTableViewController
extension MusicFromInternetTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .NotSearchedYet where requestManagerError == .NetworkError:
                return numberOfRowsForNotSearchedYetStatusWithInternetErrorInTableView(tableView, inSection: section)
            case .NotSearchedYet where requestManagerError == .AccessError:
                return numberOfRowsForNotSearchedYetStatusWithAccessErrorInTableView(tableView, inSection: section)
            case .NotSearchedYet:
                return numberOfRowsForNotSearchedYetStatusInTableView(tableView, inSection: section)
            case .Loading:
                return numberOfRowsForLoadingStatusInTableView(tableView, inSection: section)
            case .NoResults:
                return numberOfRowsForNoResultsStatusInTableView(tableView, inSection: section)
            case .Results:
                return numberOfRowsForResultsStatusInTableView(tableView, inSection: section)
            }
        }
        
        return numberOfRowsForNoAuthorizedStatusInTableView(tableView, inSection: section)
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch requestManagerStatus {
            case .NotSearchedYet where requestManagerError == .NetworkError:
                return getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView, forIndexPath: indexPath)
            case .NotSearchedYet where requestManagerError == .AccessError:
                return getCellForNotSearchedYetRowWithAccessErrorInTableView(tableView, forIndexPath: indexPath)
            case .NotSearchedYet:
                return getCellForNotSearchedYetRowInTableView(tableView, forIndexPath: indexPath)
            case .NoResults:
                return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    if music.count != 0 {
                        if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                            return numberOfRowsCell
                        }
                        
                        return getCellForRowWithAudioInTableView(tableView, forIndexPath: indexPath)
                    }
                }
                
                return getCellForLoadingRowInTableView(tableView, forIndexPath: indexPath)
            case .Results:
                if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                    return numberOfRowsCell
                }
                
                return getCellForRowWithAudioInTableView(tableView, forIndexPath: indexPath)
            }
        }
        
        return getCellForNoAuthorizedRowInTableView(tableView, forIndexPath: indexPath)
    }

}


// MARK: UITableViewDelegate

private typealias MusicFromInternetTableViewControllerDelegate = MusicFromInternetTableViewController
extension MusicFromInternetTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if requestManagerStatus == .Results {
                let count: Int?
                
                if activeArray.count == indexPath.row {
                    count = activeArray.count
                } else {
                    count = nil
                }
                
                if let _ = count {
                    return 44
                }
            }
        }
        
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is AudioCell {
            let track = activeArray[indexPath.row]
            let trackURL = NSURL(string: track.url!)
            
            PlayerManager.sharedInstance.playFile(trackURL!)
        }
    }
    
}


// MARK: NSURLSessionDownloadDelegate

extension MusicFromInternetTableViewController: NSURLSessionDownloadDelegate {
    
    // Вызывается когда загрузка была завершена
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        // Загруженный трек
        let track = popTrackForDownloadTask(downloadTask)!
        let file = NSData(contentsOfURL: location) // Загруженный файл
        
        var entity = NSEntityDescription.entityForName(EntitiesIdentifiers.offlineTrack, inManagedObjectContext: coreDataStack.context) // Сущность оффлайн трека
        
        let offlineTrack = OfflineTrack(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context) // Загруженный трек
        offlineTrack.artist = track.artist
        offlineTrack.duration = track.duration
        offlineTrack.file = file
        offlineTrack.id = track.id
        offlineTrack.lyrics = "" // TODO: Текст песни загружать с вк
        offlineTrack.title = track.title
        
        
        // Плейлист "Загрузки"
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
        
        
        // Смещаем все треки на один вперед
        fetchRequest = NSFetchRequest(entityName: EntitiesIdentifiers.trackInPlaylist)
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", playlist)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [TrackInPlaylist]
            
            if results.count != NSNotFound {
                for trackInPlaylist in results {
                    trackInPlaylist.position = NSNumber(integer: trackInPlaylist.position!.integerValue + 1)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        // Добавляем загруженный трек в плейлист "Загрузки"
        entity = NSEntityDescription.entityForName(EntitiesIdentifiers.trackInPlaylist, inManagedObjectContext: coreDataStack.context) // Сущность трека в плейлисте
        
        let trackInPlaylist = TrackInPlaylist(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        trackInPlaylist.playlist = playlist
        trackInPlaylist.track = offlineTrack
        trackInPlaylist.position = 0
        
        
        // Сохраняем изменения
        coreDataStack.saveContext()
        
        
        // Обновляем ячейку
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            activeDownloads[url] = nil
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
                })
            }
        }
    }
    
    // Вызывается когда часть данных была загружена
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let audioCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? AudioCell {
                dispatch_async(dispatch_get_main_queue(), {
                    audioCell.progressBar.progress = download.progress
                    audioCell.progressLabel.text =  String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
}