//
//  MyMusicTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MyMusicTableViewController: MusicFromInternetWithSearchTableViewController {
    
    private var filteredMusic = [Track]() // Массив для результатов поиска по уже загруженным личным аудиозаписям
    
    
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
        RequestManager.sharedInstance.getAudio.performRequest([:]) { success in
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
            }
            
            if !success {
                switch RequestManager.sharedInstance.getAudio.error {
                case .NetworkError:
                    break
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
        filteredMusic = DataManager.sharedInstance.myMusic.array.filter { track in
            return track.title!.lowercaseString.containsString(searchText.lowercaseString) || track.artist!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    override func refreshMyMusic() {
        super.refreshMyMusic()
        
        getMusic()
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
                    return 0
                }
                
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии личных аудиозаписей
            case .Results:
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredMusic.count == 0 ? 1 : filteredMusic.count // Если массив пустой - ячейка с сообщением об отсутствии результатов поиска, иначе - количество найденных аудиозаписей
                }
                
                return DataManager.sharedInstance.myMusic.array.count
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
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath)
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                
                cell.messageLabel.text = "Список аудиозаписей пуст"
                
                return cell
            case .Loading:
                if let refreshControl = refreshControl where refreshControl.refreshing {
                    if DataManager.sharedInstance.myMusic.array.count != 0 {
                        let trackCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                        let track = DataManager.sharedInstance.myMusic.array[indexPath.row]
                        
                        trackCell.delegate = self
                        
                        trackCell.nameLabel.text = track.title
                        trackCell.artistLabel.text = track.artist
                        
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
                
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                var track: Track
                
                if searchController.active && searchController.searchBar.text != "" {
                    track = filteredMusic[indexPath.row]
                } else {
                    track = DataManager.sharedInstance.myMusic.array[indexPath.row]
                }
                
                cell.delegate = self
                
                cell.nameLabel.text = track.title
                cell.artistLabel.text = track.artist
                
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
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is AudioCell {
            let track = DataManager.sharedInstance.myMusic.array[indexPath.row]
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