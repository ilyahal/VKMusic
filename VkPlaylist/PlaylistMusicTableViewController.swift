//
//  PlaylistMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class PlaylistMusicTableViewController: UITableViewController {
    
    weak var playlistMusicViewController: PlaylistMusicViewController!
    
    var playlist: Playlist!
    
    var tracks: [TrackInPlaylist]!
    var filteredMusic: [TrackInPlaylist]! // Массив для результатов поиска по аудиозаписям в плейлисте
    
    var activeArray: [TrackInPlaylist] { // Массив аудиозаписей отображаемый на экране
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMusic
        } else {
            return tracks
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tracks = DataManager.sharedInstance.getTracksForPlaylist(playlist)
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        
        searchEnable(tracks.count != 0)
        
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
        
        if tableView.contentOffset.y == 0 {
            tableView.hideSearchBar()
        }
    }

    deinit {
        if let superView = searchController.view.superview
        {
            superView.removeFromSuperview()
        }
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    

    // MARK: Работа с клавиатурой
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Поиск
    
    func searchEnable(enable: Bool) {
        if enable {
            if tableView.tableHeaderView == nil {
                searchController.searchBar.alpha = 1
                tableView.tableHeaderView = searchController.searchBar
                tableView.hideSearchBar()
            }
        } else {
            if let _ = tableView.tableHeaderView {
                searchController.searchBar.alpha = 0
                searchController.active = false
                tableView.tableHeaderView = nil
                tableView.contentOffset = CGPointZero
            }
        }
    }
    
    // Выполнение поиска
    func filterContentForSearchText(searchText: String) {
        filteredMusic = tracks.filter { trackInPlaylist in
            let track = trackInPlaylist.track
            return track.title.lowercaseString.containsString(searchText.lowercaseString) || track.artist.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var textForNoResultsRow: String {
        return "Плейлист пустой"
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    // Получение количества треков в списке для ячейки с количеством аудиозаписей
    func getCountForCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        if activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением что плейлист пустой
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoResultsRow
        
        return cell
    }
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
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
    
    // Ячейка для строки с треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = activeArray[indexPath.row].track
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.offlineAudioCell, forIndexPath: indexPath) as! OfflineAudioCell
        cell.configureForTrack(track)
        
        return cell
    }

}


// MARK: UITableViewDataSource

private typealias PlaylistMusicTableViewControllerDataSource = PlaylistMusicTableViewController
extension PlaylistMusicTableViewController {

    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tracks.count == 0 {
            return 1
        }
        
        return activeArray.count + 1
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tracks.count == 0 {
            return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
        } else if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == 0 {
            return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
        } else if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
            return numberOfRowsCell
        }
        
        return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
    }
    
    // Возможно ли редактировать ячейку
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.cellForRowAtIndexPath(indexPath) is OfflineAudioCell
    }
    
    // Обработка удаления ячейки
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let trackInPlaylist = activeArray[indexPath.row]
            
            if DataManager.sharedInstance.deleteTrackFromPlaylist(trackInPlaylist) {
                tracks.removeAtIndex(tracks.indexOf(trackInPlaylist)!)
                if let index = filteredMusic?.indexOf(trackInPlaylist) {
                    filteredMusic.removeAtIndex(index)
                }
                
                reloadTableView()
            } else {
                let alertController = UIAlertController(title: "Ошибка", message: "При удалении аудиозаписи из плейлиста произошла ошибка, попробуйте еще раз..", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // Возможно ли перемещать ячейку
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.cellForRowAtIndexPath(indexPath) is OfflineAudioCell
    }
    
    // Обработка после перемещения ячейки
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let trackToMove = tracks[fromIndexPath.row]
        
        if fromIndexPath.row != toIndexPath.row {
            DataManager.sharedInstance.moveTrackInPlaylist(trackToMove, fromPosition: Int32(fromIndexPath.row), toNewPosition: Int32(toIndexPath.row))
        }
    }
    
}


// MARK: UITableViewDelegate

private typealias PlaylistMusicTableViewControllerDelegate = PlaylistMusicTableViewController
extension PlaylistMusicTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activeArray.count != 0 {
            if activeArray.count == indexPath.row {
                return 44
            }
        }
        
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Определяется куда переместить ячейку с укзанного NSIndexPath при перемещении в указанный NSIndexPath
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row == activeArray.count {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
}


// MARK: UISearchBarDelegate

extension PlaylistMusicTableViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if tracks.count != 0 && !editing {
            playlistMusicViewController.editButton.enabled = false
            
            return true
        }
        
        return false
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // В поисковой панели была нажата отмена
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredMusic.removeAll()
        
        playlistMusicViewController.editButton.enabled = true
    }
    
}


// MARK: UISearchResultsUpdating

extension PlaylistMusicTableViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}