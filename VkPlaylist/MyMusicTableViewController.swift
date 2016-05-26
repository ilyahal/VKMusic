//
//  MyMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MyMusicTableViewController: MusicFromInternetWithSearchTableViewController {
    
    private var music: [Track]! // Массив для результатов запроса
    private var filteredMusic: [Track]! // Массив для результатов поиска по уже загруженным личным аудиозаписям
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getMusic()
        }
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск в Моей музыке"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            if VKAPIManager.isAuthorized {
                getMusic()
            }
            
            reloadTableView()
        }
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
    func getMusic() {
        RequestManager.sharedInstance.getAudio.performRequest() { success in
            self.music = DataManager.sharedInstance.myMusic.array
            
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
            }
            
            if !success {
                switch RequestManager.sharedInstance.getAudio.error {
                case .UnknownError:
                    let alertController = UIAlertController(title: "Ошибка", message: "Произошла какая-то ошибка, попробуйте еще раз...", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: false, completion: nil)
                    }
                default:
                    break
                }
            }
        }
    }
    
    
    // MARK: Поиск
    
    func filterContentForSearchText(searchText: String) {
        filteredMusic = music.filter { track in
            return track.title!.lowercaseString.containsString(searchText.lowercaseString) || track.artist!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    override func refreshMusic() {
        super.refreshMusic()
        
        getMusic()
    }
    
    
    // MARK: Загрузка
    
    override func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
        if let url = downloadTask.originalRequest?.URL?.absoluteString {
            let array: [Track]!
            
            if searchController.active && searchController.searchBar.text != "" {
                array = filteredMusic
            } else {
                array = music
            }
            
            for (index, track) in array.enumerate() {
                if url == track.url! {
                    return index
                }
            }
        }
        return nil
    }
    
}



// MARK: AudioCellDelegate

private typealias MyMusicTableViewControllerAudioCellDelegate = MyMusicTableViewController
extension MyMusicTableViewControllerAudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    override func pauseTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let array: [Track]!
            
            if searchController.active && searchController.searchBar.text != "" {
                array = filteredMusic
            } else {
                array = music
            }
            
            let track = array[indexPath.row]
            pauseDownload(track)
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Продолжить
    override func resumeTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let array: [Track]!
            
            if searchController.active && searchController.searchBar.text != "" {
                array = filteredMusic
            } else {
                array = music
            }
            
            let track = array[indexPath.row]
            resumeDownload(track)
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Отмена
    override func cancelTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let array: [Track]!
            
            if searchController.active && searchController.searchBar.text != "" {
                array = filteredMusic
            } else {
                array = music
            }
            
            let track = array[indexPath.row]
            cancelDownload(track)
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    // Вызывается при тапе по кнопке Скачать
    override func downloadTapped(cell: AudioCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let array: [Track]!
            
            if searchController.active && searchController.searchBar.text != "" {
                array = filteredMusic
            } else {
                array = music
            }
            
            let track = array[indexPath.row]
            startDownload(track)
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias MyMusicTableViewControllerDataSource = MyMusicTableViewController
extension MyMusicTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getAudio.error == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    return music.count + 1
                }
                
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии личных аудиозаписей
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredMusic.count == 0 ? 1 : filteredMusic.count + 1 // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных аудиозаписей + ячейка для вывода количество строк
                }
                
                return music.count + 1 // +1 - ячейка для вывода количества строк
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getAudio.error == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                cell.messageLabel.text = "Список аудиозаписей пуст"
                
                return cell
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    if music.count != 0 {
                        if music.count == indexPath.row {
                            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                            numberOfRowsCell.configureForType(.Audio, withCount: music.count)
                            
                            return numberOfRowsCell
                        }
                        
                        let track = music[indexPath.row]
                        
                        let trackCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                        trackCell.delegate = self
                        trackCell.configureForTrack(track)
                        
                        let downloaded = isDownloadedTrack(track)
                        
                        var showDownloadControls = false
                        if let download = activeDownloads[track.url!] {
                            showDownloadControls = true
                            
                            trackCell.progressBar.progress = download.progress
                            trackCell.progressLabel.text = (download.isDownloading) ? "Загружается..." : "Пауза"
                            
                            let title = (download.isDownloading) ? "Пауза" : "Продолжить"
                            trackCell.pauseButton.setTitle(title, forState: UIControlState.Normal)
                        }
                        trackCell.progressBar.hidden = !showDownloadControls
                        trackCell.progressLabel.hidden = !showDownloadControls
                        
                        trackCell.downloadButton.hidden = downloaded || showDownloadControls
                        
                        trackCell.pauseButton.hidden = !showDownloadControls
                        trackCell.cancelButton.hidden = !showDownloadControls
                        
                        return trackCell
                    }
                }
                
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                cell.activityIndicator.startAnimating()
                
                return cell
            case .Results:
                if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == 0 {
                    let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                    nothingFoundCell.messageLabel.text = "Измените поисковый запрос"
                    
                    return nothingFoundCell
                }
                
                let count: Int?
                
                if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == indexPath.row {
                    count = filteredMusic.count
                } else if music.count == indexPath.row {
                    count = music.count
                } else {
                    count = nil
                }
                
                if let count = count {
                    let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                    numberOfRowsCell.configureForType(.Audio, withCount: count)
                    
                    return numberOfRowsCell
                }
                
                
                var track: Track
                
                if searchController.active && searchController.searchBar.text != "" {
                    track = filteredMusic[indexPath.row]
                } else {
                    track = music[indexPath.row]
                }
                
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
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = "Для отображения списка личных аудиозаписей необходимо авторизоваться"
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias MyMusicTableViewControllerDelegate = MyMusicTableViewController
extension MyMusicTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getAudio.state == .Results {
                let count: Int?
                
                if searchController.active && searchController.searchBar.text != "" && filteredMusic.count == indexPath.row {
                    count = filteredMusic.count
                } else if music.count == indexPath.row {
                    count = music.count
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
            let track = music[indexPath.row]
            let trackURL = NSURL(string: track.url!)
            
            PlayerManager.sharedInstance.playFile(trackURL!)
        }
    }
    
}


// MARK: UISearchBarDelegate

private typealias MyMusicTableViewControllerUISearchBarDelegate = MyMusicTableViewController
extension MyMusicTableViewControllerUISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getAudio.state {
            case .Results:
                if let refreshControl = refreshControl {
                    return !refreshControl.refreshing
                }
                
                return true
            default:
                return false
            }
        }
        
        return false
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    override func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        super.searchBarTextDidBeginEditing(searchBar)
        
        pullToRefreshEnable(false)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    override func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
        
        pullToRefreshEnable(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredMusic.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

private typealias MyMusicTableViewControllerUISearchResultsUpdating = MyMusicTableViewController
extension MyMusicTableViewControllerUISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        super.updateSearchResultsForSearchController(searchController)
        
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}