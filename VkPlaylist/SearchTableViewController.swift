//
//  SearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class SearchTableViewController: MusicFromInternetWithSearchTableViewController {
    
    var currentTextSearchRequest: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            reloadTableView()
        }
        
        pullToRefreshEnable(false)
        tableView.setContentOffset(CGPointZero, animated: true) // Не прячем строку поиска
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
    func searchMusic(search: String) {
        RequestManager.sharedInstance.searchAudio(search) { success in
            self.reloadTableView()
            
            if !success {
                switch RequestManager.sharedInstance.searchAudioError {
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
    
}


// MARK: UITableViewDataSource

private typealias SearchTableViewControllerDataSource = SearchTableViewController
extension SearchTableViewControllerDataSource {
    
    // Получение количества строк таблицы
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.searchAudioState {
            case .NotSearchedYet where RequestManager.sharedInstance.searchAudioError == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .Loading:
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии найденных аудиозаписей
            case .Results:
                return DataManager.sharedInstance.searchMusic.count
            default:
                return 0
            }
        }
        
        return 1 // Ячейка с сообщением о необходимости авторизоваться
    }
    
    // Получение ячейки для строки таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if VKAPIManager.isAuthorized {
            switch RequestManager.sharedInstance.searchAudioState {
            case .NotSearchedYet where RequestManager.sharedInstance.searchAudioError == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath)
                return cell
            case .NoResults:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                
                cell.messageLabel.text = "Ничего не найдено"
                
                return cell
            case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                
                cell.activityIndicator.startAnimating()
                
                return cell
            case .Results:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                let track  = DataManager.sharedInstance.searchMusic[indexPath.row]
                
                cell.delegate = self
                
                cell.nameLabel.text = track.title
                cell.artistLabel.text = track.artist
                
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
        
        cell.messageLabel.text = "Для поиска аудиозаписей необходимо авторизоваться"
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias SearchTableViewControllerDelegate = SearchTableViewController
extension SearchTableViewControllerDelegate {
    
    // Вызывается при тапе по строке таблицы
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath) is AudioCell {
            let track = DataManager.sharedInstance.searchMusic[indexPath.row]
            let trackURL = NSURL(string: track.url!)
            
            PlayerManager.sharedInstance.playFile(trackURL!)
        }
    }
    
}


// MARK: UISearchBarDelegate

private typealias SearchTableViewControllerUISearchBarDelegate = SearchTableViewController
extension SearchTableViewControllerUISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            return true
        }
        
        return false
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    override func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        super.searchBarTextDidBeginEditing(searchBar)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    override func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        DataManager.sharedInstance.clearSearchMusic()
        
        reloadTableView()
    }
    
}


// MARK: UISearchResultsUpdating

private typealias SearchTableViewControllerUISearchResultsUpdating = SearchTableViewController
extension SearchTableViewControllerUISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        super.updateSearchResultsForSearchController(searchController)
        
        if searchController.searchBar.text!.isEmpty {
            DataManager.sharedInstance.clearSearchMusic()
        } else {
            searchMusic(searchController.searchBar.text!)
        }
        
        reloadTableView()
    }
    
}