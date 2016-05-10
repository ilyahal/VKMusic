//
//  OwnerMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class OwnerMusicTableViewController: MusicFromInternetWithSearchTableViewController {

    private var toDelete = true
    
    var id: Int! // Идентификатор владельца, чьи аудиозаписи загружаются
    var name: String? // Имя владельца
    
    private var music: [Track]! // Массив для результатов запроса
    private var filteredMusic: [Track]! // Массив для результатов поиска по уже загруженным аудиозаписям владельца
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VKAPIManager.isAuthorized {
            getOwnerMusic()
        }
        
        // Настройка навигационной панели
        title = name
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toDelete = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if toDelete {
            DataManager.sharedInstance.ownerMusic.clear()
            if !RequestManager.sharedInstance.getOwnerAudio.cancel() {
                RequestManager.sharedInstance.getOwnerAudio.dropState()
            }
        }
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей владельца
    
    func getOwnerMusic() {
        RequestManager.sharedInstance.getOwnerAudio.performRequest([.OwnerID : id]) { success in
            self.music = DataManager.sharedInstance.ownerMusic.array
            
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
            }
            
            if !success {
                switch RequestManager.sharedInstance.getOwnerAudio.error {
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
        
        getOwnerMusic()
    }
    
}


// MARK: UITableViewDataSource

private typealias OwnerMusicTableViewControllerDataSource = OwnerMusicTableViewController
extension OwnerMusicTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getOwnerAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getOwnerAudio.error == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .NotSearchedYet where RequestManager.sharedInstance.getOwnerAudio.error == .AccessError:
                return 1 // Ячейка с сообщением об отсутствии доступа
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    return music.count + 1
                }
                
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии аудиозаписей владельца
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredMusic.count == 0 ? 1 : filteredMusic.count + 1 // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных аудиозаписей
                }
                
                return music.count + 1
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getOwnerAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.getOwnerAudio.error == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                
                return cell
            case .NotSearchedYet where RequestManager.sharedInstance.getOwnerAudio.error == .AccessError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.accessErrorCell, forIndexPath: indexPath) as! AccessErrorCell
                
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
                
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        cell.messageLabel.text = "Необходимо авторизоваться"
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias OwnerMusicTableViewControllerDelegate = OwnerMusicTableViewController
extension OwnerMusicTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.getOwnerAudio.state == .Results {
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

private typealias OwnerMusicTableViewControllerUISearchBarDelegate = OwnerMusicTableViewController
extension OwnerMusicTableViewControllerUISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.getOwnerAudio.state {
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

private typealias OwnerMusicTableViewControllerUISearchResultsUpdating = OwnerMusicTableViewController
extension OwnerMusicTableViewControllerUISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        super.updateSearchResultsForSearchController(searchController)
        
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}
