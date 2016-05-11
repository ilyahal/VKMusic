//
//  SearchTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class SearchTableViewController: MusicFromInternetWithSearchTableViewController {
    
    private var music: [Track]! // Массив для результатов запроса

    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let music = music where !music.isEmpty {
            return
        }
        
        tableView.contentOffset = CGPointMake(0, -64) // Отображаем строку поиска
    }
    
    
    // MARK: Выполнение запроса на получение личных аудиозаписей
    
    func searchMusic(search: String) {
        RequestManager.sharedInstance.searchAudio.performRequest([.RequestText : search]) { success in
            self.music = DataManager.sharedInstance.searchMusic.array
            
            self.reloadTableView()
            
            if !success {
                switch RequestManager.sharedInstance.searchAudio.error {
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
            switch RequestManager.sharedInstance.searchAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.searchAudio.error == .NetworkError:
                return 1 // Ячейка с сообщением об отсутствии интернет соединения
            case .Loading:
                return 1 // Ячейка с индикатором загрузки
            case .NoResults:
                return 1 // Ячейки с сообщением об отсутствии найденных аудиозаписей
            case .Results:
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
            switch RequestManager.sharedInstance.searchAudio.state {
            case .NotSearchedYet where RequestManager.sharedInstance.searchAudio.error == .NetworkError:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                
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
                let count: Int?
                
                if music.count == indexPath.row {
                    count = music.count
                } else {
                    count = nil
                }
                
                if let count = count {
                    let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                    numberOfRowsCell.configureForType(.Audio, withCount: count)
                    
                    return numberOfRowsCell
                }
                
                let track = music[indexPath.row]
                
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
                cell.delegate = self
                cell.configureForTrack(track)
                
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
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if VKAPIManager.isAuthorized {
            if RequestManager.sharedInstance.searchAudio.state == .Results {
                let count: Int?
                
                if music.count == indexPath.row {
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

private typealias SearchTableViewControllerUISearchBarDelegate = SearchTableViewController
extension SearchTableViewControllerUISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if VKAPIManager.isAuthorized {
            return true
        }
        
        return false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchController.searchBar.text!.isEmpty {
            searchMusic(searchController.searchBar.text!)
        }

        reloadTableView()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        music?.removeAll()
        DataManager.sharedInstance.searchMusic.clear()
        if !RequestManager.sharedInstance.searchAudio.cancel() {
            RequestManager.sharedInstance.searchAudio.dropState()
        }
        
        reloadTableView()
    }
    
}


// MARK: UISearchResultsUpdating

private typealias SearchTableViewControllerUISearchResultsUpdating = SearchTableViewController
extension SearchTableViewControllerUISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    override func updateSearchResultsForSearchController(searchController: UISearchController) {
        super.updateSearchResultsForSearchController(searchController)
        
        // FIXME: При отправлении запроса с каждым изменением текстового поля программа периодически крашится
        
//        DataManager.sharedInstance.searchMusic.clear()
//        
//        if !searchController.searchBar.text!.isEmpty {
//            searchMusic(searchController.searchBar.text!)
//        }
//        
//        reloadTableView()
    }
    
}