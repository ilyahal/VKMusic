//
//  MusicFromInternetTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

/// Контроллер отображающий музыку из интернета, с возможностью Pull-To-Refresh
class MusicFromInternetTableViewController: UITableViewController {
    
    /// Идентификатор текущего списка аудиозаписей
    var playlistIdentifier: String?
    
    /// Состояние авторизации пользователя при последнем отображении контроллера
    var currentAuthorizationStatus: Bool!
    
    /// Массив аудиозаписей, полученный в результате успешного выполнения запроса к серверу
    var music = [Track]()
    /// Массив аудиозаписей, отображаемых на экране
    var activeArray: [Track] {
        return music
    }
    
    /// Запрос на получение данных с сервера
    var getRequest: (() -> Void)! {
        return nil
    }
    /// Статус выполнения запроса к серверу
    var requestManagerStatus: RequestManagerObject.State {
        return RequestManagerObject.State.NotSearchedYet
    }
    /// Ошибки при выполнении запроса к серверу
    var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManagerObject.ErrorRequest.None
    }
    
    /// Массив аудиозаписей, загружаемых сейчас
    var activeDownloads: [String: Download] {
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        DownloadManager.sharedInstance.addDelegate(self)
        DataManager.sharedInstance.addDataManagerDownloadsDelegate(self)
        
        // Настройка Pull-To-Refresh
        pullToRefreshEnable(VKAPIManager.isAuthorized)
        
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
            pullToRefreshEnable(VKAPIManager.isAuthorized)
            
            if !VKAPIManager.isAuthorized {
                music.removeAll()
            }
        }
    }
    
    /// Перезагрузить таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    /// Управление доступностью Pull-to-Refresh
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            if refreshControl == nil {
                refreshControl = UIRefreshControl()
                //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
                refreshControl!.addTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
            }
        } else {
            if let refreshControl = refreshControl {
                if refreshControl.refreshing {
                    refreshControl.endRefreshing()
                }
                
                refreshControl.removeTarget(self, action: #selector(refreshMusic), forControlEvents: .ValueChanged) // Удаляем обработчик контроллера обновления
            }
            
            refreshControl = nil
        }
    }
    
    /// Запрос на обновление при Pull-to-Refresh
    func refreshMusic() {
        getRequest()
    }
    
    
    // MARK: Загрузка helpers
    
    /// Получение индекса трека в активном массиве для загрузки
    func trackIndexForDownload(download: Download) -> Int? {
        if let index = activeArray.indexOf({ $0 === download.track }) {
            return index
        }
        
        return nil
    }
    
    
    // MARK: Менеджер загруженных треков helpers
    
    /// Получение индекса трека в активном массиве с указанным id и id владельца
    func trackIndexWithID(id: Int32, andOwnerID ownerID: Int32) -> Int? {
        for (index, track) in activeArray.enumerate() {
            if id == track.id && ownerID == track.owner_id {
                return index
            }
        }
        
        return nil
    }
    
    
    // MARK: Получение количества строк таблицы
    
    /// Количества строк в таблице при статусе "NotSearchedYet" и ошибкой при подключении к интернету
    func numberOfRowsForNotSearchedYetStatusWithInternetErrorInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением об отсутствии интернет соединения
    }
    
    /// Количества строк в таблице при статусе "NotSearchedYet" и ошибкой при подключении к интернету
    func numberOfRowsForNotSearchedYetStatusWithAccessErrorInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением об отсутствии доступа
    }
    
    /// Количества строк в таблице при статусе "NotSearchedYet"
    func numberOfRowsForNotSearchedYetStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 0
    }
    
    /// Количества строк в таблице при статусе "Loading"
    func numberOfRowsForLoadingStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        if let refreshControl = refreshControl where refreshControl.refreshing {
            return activeArray.count + 1
        }
        
        return 1 // Ячейка с индикатором загрузки
    }
    
    /// Количества строк в таблице при статусе "NoResults"
    func numberOfRowsForNoResultsStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейки с сообщением об отсутствии личных аудиозаписей
    }
    
    /// Количества строк в таблице при статусе "Results"
    func numberOfRowsForResultsStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return activeArray.count + 1 // +1 - ячейка для вывода количества строк
    }
    
    /// Количества строк в таблице при статусе "Не авторизован"
    func numberOfRowsForNoAuthorizedStatusInTableView(tableView: UITableView, inSection section: Int) -> Int {
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var noResultsLabelText: String {
        return "Список пуст"
    }
    
    /// Получение количества треков в списке для ячейки с количеством аудиозаписей
    func numberOfAudioForIndexPath(indexPath: NSIndexPath) -> Int? {
        if activeArray.count != 0 && activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    /// Получение трека для ячейки с треком
    func trackForIndexPath(indexPath: NSIndexPath) -> Track {
        return activeArray[indexPath.row]
    }
    
    /// Текст для ячейки с сообщением о необходимости авторизоваться
    var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }

    
    // MARK: Получение ячеек для строк таблицы
    
    /// Ячейка для строки когда поиск еще не выполнялся и была получена ошибка при подключении к интернету
    func getCellForNotSearchedYetRowWithInternetErrorInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
        
        return cell
    }
    
    /// Ячейка для строки когда поиск еще не выполнялся и была получена ошибка доступа
    func getCellForNotSearchedYetRowWithAccessErrorInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.accessErrorCell, forIndexPath: indexPath) as! AccessErrorCell
        
        return cell
    }
    
    /// Ячейка для строки когда поиск еще не выполнялся
    func getCellForNotSearchedYetRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    /// Ячейка для строки с сообщением что сервер вернул пустой массив
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noResultsLabelText
        
        return cell
    }
    
    /// Ячейка для строки с сообщением о загрузке
    func getCellForLoadingRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    /// Попытка получить ячейку для строки с количеством аудиозаписей
    func getCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = numberOfAudioForIndexPath(indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Audio, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    /// Ячейка для строки с аудиозаписью
    func getCellForRowWithAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = trackForIndexPath(indexPath)
        let downloaded = DataManager.sharedInstance.isDownloadedTrack(track) // Загружен ли трек
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
        cell.delegate = self
        
        cell.configureForTrack(track)
        
        var showDownloadControls = false // Отображать ли кнопки "Пауза" и "Отмена" и индикатор выполнения загрузки с меткой для отображения прогресса загрузки
        if let download = activeDownloads[track.url] { // Если аудиозапись есть в списке активных загрузок
            showDownloadControls = true
            
            cell.progressBar.progress = download.progress
            cell.progressLabel.text = download.isDownloading ?
                    (download.totalSize == nil ? "Загружается..." : String(format: "%.1f%% из %@",  download.progress * 100, download.totalSize!))
                    :
                    (download.inQueue ? "В очереди" : "Пауза")
            
            let title = download.isDownloading ? "Пауза" : (download.inQueue ? "Пауза" : "Продолжить")
            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
        }
        
        cell.progressBar.hidden = !showDownloadControls
        cell.progressLabel.hidden = !showDownloadControls
        
        cell.downloadButton.hidden = downloaded || showDownloadControls
        
        cell.pauseButton.hidden = !showDownloadControls
        cell.cancelButton.hidden = !showDownloadControls
        
        return cell
    }
    
    /// Ячейка для строки с сообщением о необходимости авторизоваться
    func getCellForNoAuthorizedRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = noAuthorizedLabelText
        
        return cell
    }

}


// MARK: UITableViewDataSource

private typealias _MusicFromInternetTableViewControllerDataSource = MusicFromInternetTableViewController
extension _MusicFromInternetTableViewControllerDataSource {
    
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

private typealias _MusicFromInternetTableViewControllerDelegate = MusicFromInternetTableViewController
extension _MusicFromInternetTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if requestManagerStatus == .Results {
                if activeArray.count != 0 {
                    if activeArray.count == indexPath.row {
                        return 44
                    }
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
            let index = music.indexOf({ $0 === track })!
            
            PlayerManager.sharedInstance.playItemWithIndex(index, inPlaylist: music, withPlaylistIdentifier: playlistIdentifier!)
        }
    }
    
}


// MARK: DownloadManagerDelegate

extension MusicFromInternetTableViewController: DownloadManagerDelegate {
    
    // Менеджер загрузок начал новую загрузку
    func downloadManagerStartTrackDownload(download: Download) {
        
        // Обновляем ячейку
        if let index = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Менеджер загрузок изменил состояние загрузки
    func downloadManagerUpdateStateTrackDownload(download: Download) {
       
        // Обновляем ячейку
        if let index = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Менеджер загрузок отменил выполнение загрузки
    func downloadManagerCancelTrackDownload(download: Download) {
        
        // Обновляем ячейку
        if let index = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Менеджер загрузок завершил загрузку
    func downloadManagerdidFinishDownloadingDownload(download: Download) {
        
        // Обновляем ячейку
        if let index = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Менеджер загрузок получил часть данных
    func downloadManagerURLSessionDidWriteDataForDownload(download: Download) {
        
        // Обновляем ячейку
        if let index = trackIndexForDownload(download), audioCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? AudioCell {
            dispatch_async(dispatch_get_main_queue(), {
                audioCell.cancelButton.hidden = download.progress == 1
                audioCell.pauseButton.hidden = download.progress == 1
                audioCell.progressBar.progress = download.progress
                audioCell.progressLabel.text =  download.progress == 1 ? "Сохраняется..." : String(format: "%.1f%% из %@",  download.progress * 100, download.totalSize!)
            })
        }
    }
    
}


// MARK: DataManagerDownloadsDelegate

extension MusicFromInternetTableViewController: DataManagerDownloadsDelegate {
    
    // Контроллер удалил трек с указанным id и id владельца
    func downloadManagerDeleteTrackWithID(id: Int32, andOwnerID ownerID: Int32) {
        
        // Обновляем ячейку
        if let trackIndex = trackIndexWithID(id, andOwnerID: ownerID) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Контроллер массива загруженных аудиозаписей начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер массива загруженных аудиозаписей совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер массива загруженных аудиозаписей закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {}
    
}


// MARK: AudioCellDelegate

extension MusicFromInternetTableViewController: AudioCellDelegate {
    
    /// Кнопка "Пауза" была нажата
    func pauseTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.pauseDownloadTrack(track)
        }
    }
    
    // Кнопка "Продолжить" была нажата
    func resumeTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.resumeDownloadTrack(track)
        }
    }
    
    // Кнопка "Отмена" была нажата
    func cancelTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.cancelDownloadTrack(track)
        }
    }
    
    // Кнопка "Скачать" была нажата
    func downloadTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.downloadTrack(track)
        }
    }
    
}