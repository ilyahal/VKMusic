//
//  MusicFromInternetTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MusicFromInternetTableViewController: UITableViewController {
    
    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
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
    
    var activeDownloads: [String: Download] { // Активные загрузки
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        DownloadManager.sharedInstance.addDelegate(self)
        
        
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
        
        let downloaded = DataManager.sharedInstance.isDownloadedTrack(track)
        
        var showDownloadControls = false
        var showPauseButton = false
        if let download = activeDownloads[track.url!] {
            showDownloadControls = true
            showPauseButton = !download.inQueue
            
            cell.progressBar.progress = download.progress
            cell.progressLabel.text = download.isDownloading ? "Загружается..." : download.inQueue ? "В очереди" : "Пауза"
            
            let title = (download.isDownloading) ? "Пауза" : "Продолжить"
            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
        }
        
        cell.progressBar.hidden = !showDownloadControls
        cell.progressLabel.hidden = !showDownloadControls
        
        cell.downloadButton.hidden = downloaded || showDownloadControls
        
        cell.pauseButton.hidden = !showDownloadControls || !showPauseButton
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
    
    // Управление доступностью Pull-to-Refresh
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
    
    // Запрос на обновление при Pull-to-Refresh
    func refreshMusic() {
        getRequest()
    }
    
    
    // MARK: Загрузка helpers
    
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
    
    // Получение индекса трека для загрузки
    func trackIndexForDownload(download: Download) -> Int? {
        for (index, track) in activeArray.enumerate() {
            if download.url == track.url! {
                return index
            }
        }
        
        
        return nil
    }

}


// MARK: AudioCellDelegate

extension MusicFromInternetTableViewController: AudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.pauseDownloadTrack(track)
        }
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.resumeDownloadTrack(track)
        }
    }
    
    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.cancelDownloadTrack(track)
        }
    }
    
    // Вызывается при тапе по кнопке Скачать
    func downloadTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = activeArray[indexPath.row]
            DownloadManager.sharedInstance.downloadTrack(track)
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
                    if activeArray.count != 0 {
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


// MARK: DownloadManagerDelegate

extension MusicFromInternetTableViewController: DownloadManagerDelegate {
    
    // Вызывается когда была начата новая загрузка
    func downloadManagerStartTrackDownload(download: Download) {
        
        // Обновляем ячейку
        if let trackIndex = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Вызывается когда состояние загрузки было изменено
    func downloadManagerUpdateStateTrackDownload(download: Download) {
       
        // Обновляем ячейку
        if let trackIndex = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Вызывается когда загрузка была отменена
    func downloadManagerCancelTrackDownload(download: Download) {
        
        // Обновляем ячейку
        if let trackIndex = trackIndexForDownload(download) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Вызывается когда загрузка была завершена
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        // Обновляем ячейку
        if let trackIndex = trackIndexForDownloadTask(downloadTask) {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: trackIndex, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    // Вызывается когда часть данных была загружена
    func downloadManagerURLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString, download = activeDownloads[downloadUrl] {
            if let trackIndex = trackIndexForDownloadTask(downloadTask), let audioCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: trackIndex, inSection: 0)) as? AudioCell {
                download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
                
                let isCompleted = download.progress == 1
                dispatch_async(dispatch_get_main_queue(), {
                    audioCell.cancelButton.hidden = isCompleted
                    audioCell.pauseButton.hidden = isCompleted
                    audioCell.progressBar.progress = download.progress
                    audioCell.progressLabel.text =  isCompleted ? "Сохраняется..." : String(format: "%.1f%% из %@",  download.progress * 100, totalSize)
                })
            }
        }
    }
    
}