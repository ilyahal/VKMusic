//
//  DownloadsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

/// Контроллер содержащий таблицу со списком активных загрузок и уже загруженных аудиозаписей
class DownloadsTableViewController: UITableViewController {

    weak var delegate: DownloadsTableViewControllerDelegate?
    
    /// Идентификатор текущего списка аудиозаписей
    var playlistIdentifier = NSUUID().UUIDString
    
    /// Контроллер поиска
    let searchController = UISearchController(searchResultsController: nil)
    /// Выполняется ли сейчас поиск
    var isSearched: Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    /// Контроллер массива уже загруженных аудиозаписей
    var downloadsFetchedResultsController: NSFetchedResultsController {
        return DataManager.sharedInstance.downloadsFetchedResultsController
    }
    
    /// Массив уже загруженных аудиозаписей
    var downloaded: [TrackInPlaylist] {
        return downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist]
    }
    /// Массив уже загруженных аудиозаписей, полученный в результате выполения поискового запроса
    var filteredDownloaded = [TrackInPlaylist]()
    /// Массив загруженных аудиозаписей, отобажаемых на экране
    var activeArray: [TrackInPlaylist] {
        if isSearched {
            return filteredDownloaded
        } else {
            return downloaded
        }
    }
    
    /// Массив аудиозаписей, загружаемых сейчас
    var activeDownloads: [String: Download] {
        return DownloadManager.sharedInstance.activeDownloads
    }
    
    /// Была ли нажата кнопка "Пауза" или "Продолжить" (необходимо для плавного обновления)
    var pauseOrResumeTapped = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        definesPresentationContext = true
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.offlineAudioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.offlineAudioCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pauseOrResumeTapped = false
        
        searchEnable(downloaded.count != 0)
        
        reloadTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataManager.sharedInstance.addDataManagerDownloadsDelegate(self)
        DownloadManager.sharedInstance.addDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        DataManager.sharedInstance.deleteDataManagerDownloadsDelegate(self)
        DownloadManager.sharedInstance.deleteDelegate(self)
    }
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    /// Удаление аудиозаписи
    func deleteTrack(track: OfflineTrack) {
        if !PlayerManager.sharedInstance.deleteOfflineTrack(track) {
            let alertController = UIAlertController(title: "Ошибка", message: "Невозможно удалить, аудиозапись сейчас воспроизводится!", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else if !DataManager.sharedInstance.deleteTrack(track) {
            let alertController = UIAlertController(title: "Ошибка", message: "При удалении файла произошла ошибка, попробуйте еще раз..", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Работа с клавиатурой
    
    /// Распознаватель тапов по экрану
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    /// Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Поиск
    
    /// Управление доступностью поиска
    func searchEnable(enable: Bool) {
        if enable {
            if tableView.tableHeaderView == nil {
                searchController.searchBar.alpha = 1
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            if let _ = tableView.tableHeaderView {
                searchController.searchBar.alpha = 0
                searchController.active = false
                tableView.tableHeaderView = nil
            }
        }
    }
    
    /// Выполнение поискового запроса
    func filterContentForSearchText(searchText: String) {
        filteredDownloaded = downloaded.filter { trackInPlaylist in
            let track = trackInPlaylist.track
            return track.title.lowercaseString.containsString(searchText.lowercaseString) || track.artist.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Загрузка helpers
    
    /// Получение индекса трека в активном массиве для задания загрузки
    func trackIndexForDownload(download: Download) -> Int? {
        if let index = DownloadManager.sharedInstance.downloadsTracks.indexOf({ $0 === download.track}) {
            return index
        }
        
        return nil
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что нет загружаемых треков
    var noActiveDownloadsLabelText: String {
        return "Нет активных загрузок"
    }
    
    /// Текст для ячейки с сообщением о том, что нет загруженных треков
    var noDownloadedLabelText: String {
        return "Нет загруженных треков"
    }
    
    /// Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    /// Получение количества треков в списке для ячейки с количеством аудиозаписей
    func numberOfAudioForIndexPath(indexPath: NSIndexPath) -> Int? {
        if isSearched {
            if filteredDownloaded.count != 0 && filteredDownloaded.count == indexPath.row {
                return filteredDownloaded.count
            } else {
                return nil
            }
        } else {
            switch indexPath.section {
            case 1:
                if downloaded.count != 0 && downloaded.count == indexPath.row {
                    return downloaded.count
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    /// Ячейка для строки с сообщением об отсутствии загружаемых треков
    func getCellForNoActiveDownloadsInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noActiveDownloadsLabelText
        
        return cell
    }
    
    /// Ячейка для строки с загружаемым треком
    func getCellForActiveDownloadTrackInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.activeDownloadCell, forIndexPath: indexPath) as! ActiveDownloadCell
        cell.delegate = self
        
        cell.configureForTrack(track)
        
        if let download = activeDownloads[track.url] { // Если аудиозапись есть в списке активных загрузок
            cell.progressBar.progress = download.progress
            cell.progressLabel.text = download.isDownloading ?
                (download.totalSize == nil ? "Загружается..." : String(format: "%.1f%% из %@",  download.progress * 100, download.totalSize!))
                :
                (download.inQueue ? "В очереди" : "Пауза")
            
            let title = download.isDownloading ? "Пауза" : (download.inQueue ? "Пауза" : "Продолжить")
            cell.pauseButton.setTitle(title, forState: UIControlState.Normal)
        }
        
        return cell
    }
    
    /// Ячейка для строки с сообщением об отсутствии загруженных треков
    func getCellForNoDownloadedInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = noDownloadedLabelText
        
        return cell
    }
    
    /// Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
    }
    
    /// Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = activeArray[indexPath.row]
        let track = trackInPlaylist.track
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        cell.configureForTrack(track)
        
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
    
}


// MARK: UITableViewDataSource

private typealias _DownloadsTableViewControllerDataSource = DownloadsTableViewController
extension _DownloadsTableViewControllerDataSource {
    
    // Количество секций
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 + (!isSearched ? 1 : 0)
    }
    
    // Названия секций
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearched {
            return nil
        } else {
            switch section {
            case 0:
                return "Активные загрузки"
            case 1:
                return "Загруженные"
            default:
                return nil
            }
        }
    }
    
    // Количество строк в секциях
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearched {
            return filteredDownloaded.count + 1
        } else {
            switch section {
            case 0:
                return activeDownloads.count == 0 ? 1 : activeDownloads.count
            case 1:
                return downloaded.count + 1
            default:
                return 0
            }
        }
    }
    
    // Ячейки для строк
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isSearched {
            if filteredDownloaded.count == 0 {
                return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
            } else {
                if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                    return numberOfRowsCell
                }
                
                return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
            }
        } else {
            switch indexPath.section {
            case 0:
                if activeDownloads.count == 0 {
                    return getCellForNoActiveDownloadsInTableView(tableView, forIndexPath: indexPath)
                } else {
                    return getCellForActiveDownloadTrackInTableView(tableView, forIndexPath: indexPath)
                }
            case 1:
                if downloaded.count == 0 {
                    return getCellForNoDownloadedInTableView(tableView, forIndexPath: indexPath)
                } else {
                    if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                        return numberOfRowsCell
                    }
                    
                    return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
                }
            default:
                return UITableViewCell()
            }
        }
    }
    
    // Возможно ли редактировать ячейку
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isSearched {
            return filteredDownloaded.count != indexPath.row
        } else {
            if indexPath.section == 1 {
                return downloaded.count != indexPath.row
            }
            
            return false
        }
    }
    
    // Обработка удаления ячейки
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let trackInPlaylist = activeArray[indexPath.row]
            let track = trackInPlaylist.track
            
            if DataManager.sharedInstance.isWarningWhenDeletingOfExistenceInPlaylists {
                let playlists = DataManager.sharedInstance.playlistsForTrack(track)
                
                if playlists.count == 0 {
                    deleteTrack(track)
                } else {
                    var playlistsList = "" // Список плейлистов
                    for (index, playlist) in playlists.enumerate() {
                        playlistsList += "- " + playlist.title
                        
                        if index != playlists.count {
                            playlistsList += "\n"
                        }
                    }
                    
                    let alertController = UIAlertController(title: "Вы уверены?", message: "Аудиозапись также будет удалена из следующих плейлистов:\n" + playlistsList, preferredStyle: .ActionSheet)
                    
                    let dontWarningMoreAction = UIAlertAction(title: "Больше не предупреждать", style: .Default) { _ in
                        DataManager.sharedInstance.warningWhenDeletingOfExistenceInPlaylistsDisabled()
                        self.deleteTrack(track)
                    }
                    alertController.addAction(dontWarningMoreAction)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    let continueAction = UIAlertAction(title: "Продолжить", style: .Destructive) { _ in
                        self.deleteTrack(track)
                    }
                    alertController.addAction(continueAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
            } else {
                deleteTrack(track)
            }
        }
    }
    
    // Возможно ли перемещать ячейку
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isSearched {
            return filteredDownloaded.count != indexPath.row
        } else {
            if indexPath.section == 1 {
                return downloaded.count != indexPath.row
            }
            
            return false
        }
    }
    
    // Обработка после перемещения ячейки
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if fromIndexPath.row != toIndexPath.row {
            let trackToMove = downloaded[fromIndexPath.row]
            
            DataManager.sharedInstance.moveDownloadedTrack(trackToMove, fromPosition: Int32(fromIndexPath.row), toNewPosition: Int32(toIndexPath.row))
        }
    }
    
}


// MARK: UITableViewDelegate

private typealias _DownloadsTableViewControllerDelegate = DownloadsTableViewController
extension _DownloadsTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isSearched {
            if filteredDownloaded.count != 0 {
                if filteredDownloaded.count == indexPath.row {
                    return 44
                }
            }
        } else {
            switch indexPath.section {
            case 1:
                if downloaded.count != 0 {
                    if downloaded.count == indexPath.row {
                        return 44
                    }
                }
            default:
                break
            }
        }
        
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is OfflineAudioCell {
            let track = activeArray[indexPath.row]
            let index = downloaded.indexOf({ $0 === track })!
            
            PlayerManager.sharedInstance.playItemWithIndex(index, inPlaylist: downloaded, withPlaylistIdentifier: playlistIdentifier)
        }
    }
    
    // Определяется куда переместить ячейку с укзанного NSIndexPath при перемещении в указанный NSIndexPath
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        switch proposedDestinationIndexPath.section {
        case 0:
            return sourceIndexPath
        case 1:
            if proposedDestinationIndexPath.row == downloaded.count {
                return sourceIndexPath
            } else {
                return proposedDestinationIndexPath
            }
        default:
            return sourceIndexPath
        }
    }
    
}


// MARK: UISearchBarDelegate

extension DownloadsTableViewController: UISearchBarDelegate {
    
    // Пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if downloaded.count != 0 {
            delegate?.downloadsTableViewControllerSearchStarted()
        }
        
        return downloaded.count != 0
    }
    
    // Пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // В поисковой панели была нажата кнопка "Отмена"
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredDownloaded.removeAll()
        
        delegate?.downloadsTableViewControllerSearchEnded()
    }
    
}


// MARK: UISearchResultsUpdating

extension DownloadsTableViewController: UISearchResultsUpdating {
    
    // Поле поиска получило фокус или значение поискового запроса изменилось
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}


// MARK: DataManagerDownloadsDelegate

extension DownloadsTableViewController: DataManagerDownloadsDelegate {

    // Контроллер удалил трек с указанным id и id владельца
    func downloadManagerDeleteTrackWithID(id: Int32, andOwnerID ownerID: Int32) {}
    
    // Контроллер массива загруженных аудиозаписей начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер массива загруженных аудиозаписей совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер массива загруженных аудиозаписей закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        searchEnable(downloaded.count != 0)
        if isSearched {
            filterContentForSearchText(searchController.searchBar.text!)
        }
        
        reloadTableView()
        
        delegate?.downloadsTableViewControllerUpdateContent()
    }
    
}


// MARK: DownloadManagerDelegate

extension DownloadsTableViewController: DownloadManagerDelegate {
    
    // Менеджер загрузок начал новую загрузку
    func downloadManagerStartTrackDownload(download: Download) {
        if !isSearched {
            if let index = trackIndexForDownload(download) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                })
            }
        }
    }
    
    // Менеджер загрузок изменил состояние загрузки
    func downloadManagerUpdateStateTrackDownload(download: Download) {
        if !isSearched {
            if let index = trackIndexForDownload(download) {
                if pauseOrResumeTapped {
                    pauseOrResumeTapped = false
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
                    })
                } else {
                    reloadTableView()
                }
            }
        }
    }
    
    // Менеджер загрузок отменил выполнение загрузки
    func downloadManagerCancelTrackDownload(download: Download) {
        if !isSearched {
            reloadTableView()
        }
    }
    
    // Менеджер загрузок завершил загрузку
    func downloadManagerdidFinishDownloadingDownload(download: Download) {}
    
    // Вызывается когда часть данных была загружена
    func downloadManagerURLSessionDidWriteDataForDownload(download: Download) {
        if !isSearched {
            if let index = trackIndexForDownload(download), activeDownloadCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? ActiveDownloadCell {
                dispatch_async(dispatch_get_main_queue(), {
                    activeDownloadCell.cancelButton.hidden = download.progress == 1
                    activeDownloadCell.pauseButton.hidden = download.progress == 1
                    activeDownloadCell.progressBar.progress = download.progress
                    activeDownloadCell.progressLabel.text =  download.progress == 1 ? "Сохраняется..." : String(format: "%.1f%% из %@",  download.progress * 100, download.totalSize!)
                })
            }
        }
    }
    
}


// MARK: ActiveDownloadCellDelegate

extension DownloadsTableViewController: ActiveDownloadCellDelegate {
    
    // Кнопка "Пауза" была нажата
    func pauseTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            
            pauseOrResumeTapped = true
            
            DownloadManager.sharedInstance.pauseDownloadTrack(track)
        }
    }
    
    // Кнопка "Продолжить" была нажата
    func resumeTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            
            pauseOrResumeTapped = true
            
            DownloadManager.sharedInstance.resumeDownloadTrack(track)
        }
    }
    
    // Кнопка "Отмена" была нажата
    func cancelTapped(cell: ActiveDownloadCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let track = DownloadManager.sharedInstance.downloadsTracks[indexPath.row]
            DownloadManager.sharedInstance.cancelDownloadTrack(track)
        }
    }
    
}