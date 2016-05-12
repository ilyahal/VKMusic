//
//  PlaylistsViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 11.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    private var selected = SelectedType.Playlists
    
    private var playlists: [Album]! // Массив для оффлайн плейлистов
    private var albums: [Album]! // Массив для альбомов ВК

    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAlbums), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    var pullToRefreshEnable = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Загрузка локальных плейлистов из бд
        if VKAPIManager.isAuthorized {
            getAlbums()
        }
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        
        // Настройка навигационной панели, содержащей segmented control
        navigationBar.barTintColor = UIColor.whiteColor()
        navigationBar.tintColor = (UIApplication.sharedApplication().delegate! as! AppDelegate).tintColor
        
        
        // Настройка Pull-To-Refresh
        if VKAPIManager.isAuthorized {
            pullToRefreshEnable(true)
        }
        
        
        // Настройка table view
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: navigationBar.bounds.height, left: 0, bottom: 0, right: 0)
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.playlistCell, bundle: nil) // Ячейка с плейлистом
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.playlistCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pullToRefreshEnable {
            pullToRefreshEnable(false)
            pullToRefreshEnable(true)
        }
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            currentAuthorizationStatus = VKAPIManager.isAuthorized
            
            if VKAPIManager.isAuthorized {
                pullToRefreshEnable(true)
                
                getAlbums()
            } else {
                pullToRefreshEnable(false)
            }
            
            // Если открыта вкладка с альбомами ВК
            if selected == .Albums {
                reloadTableView()
            }
        }
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selected = .Playlists
        case 1:
            selected = .Albums
        default:
            return
        }
        
        reloadTableView()
    }
    
    
    // MARK: Выполнение запроса на получение альбомов ВК
    
    func getAlbums() {
        RequestManager.sharedInstance.getAlbums.performRequest() { success in
            self.albums = DataManager.sharedInstance.albums.array
            
            if self.selected == .Albums {
                self.reloadTableView()
            }
            
            if self.refreshControl.refreshing { // Если данные обновляются
                self.refreshControl.endRefreshing() // Говорим что обновление завершено
            }
            
            if !success {
                switch RequestManager.sharedInstance.getAlbums.error {
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
    
    
    // MARK: Pull-to-Refresh
    
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            if !pullToRefreshEnable {
                tableView.addSubview(self.refreshControl)
                pullToRefreshEnable = true
            }
        } else {
            if pullToRefreshEnable {
                refreshControl.removeFromSuperview()
                pullToRefreshEnable = false
            }
        }
    }
    
    func refreshAlbums() {
        getAlbums()
    }

}


// MARK: UITableViewDataSource

private typealias PlaylistsViewControllerDataTypes = PlaylistsViewController
extension PlaylistsViewControllerDataTypes {

    // Выбранное состояние
    enum SelectedType {
        case Playlists // Локальные плейлисты
        case Albums // Альбомы ВК
    }
    
}


extension PlaylistsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selected {
        case .Playlists:
            return 0
        case .Albums:
            if VKAPIManager.isAuthorized {
                switch RequestManager.sharedInstance.getAlbums.state {
                case .NotSearchedYet where RequestManager.sharedInstance.getAlbums.error == .NetworkError:
                    return 1 // Ячейка с сообщением об отсутствии интернет соединения
                case .Loading:
                    return 1 // Ячейка с индикатором загрузки
                case .NoResults:
                    return 1 // Ячейки с сообщением об отсутствии альбомов
                case .Results:
                    return albums.count + 1 // +1 - ячейка для вывода количества строк
                default:
                    return 0
                }
            }
            
            return 1 // Ячейка с сообщением о необходимости авторизоваться
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch selected {
        case .Playlists:
            return UITableViewCell()
        case .Albums:
            if VKAPIManager.isAuthorized {
                switch RequestManager.sharedInstance.getAlbums.state {
                case .NotSearchedYet where RequestManager.sharedInstance.getAlbums.error == .NetworkError:
                    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.networkErrorCell, forIndexPath: indexPath) as! NetworkErrorCell
                    
                    return cell
                case .NoResults:
                    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
                    cell.messageLabel.text = "Альбомы отсутствуют"
                    
                    return cell
                case .Loading:
                    if refreshControl.refreshing {
                        if albums.count != 0 {
                            if albums.count == indexPath.row {
                                let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                                numberOfRowsCell.configureForType(.Album, withCount: albums.count)
                                
                                return numberOfRowsCell
                            }
                            
                            let album = albums[indexPath.row]
                            
                            let albumCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.playlistCell, forIndexPath: indexPath) as! PlaylistCell
                            albumCell.titleLabel.text = album.title
                            
                            return albumCell
                        }
                    }
                    
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
                    cell.activityIndicator.startAnimating()
                    
                    return cell
                case .Results:
                    let count: Int?
                    
                    if albums.count == indexPath.row {
                        count = albums.count
                    } else {
                        count = nil
                    }
                    
                    if let count = count {
                        let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
                        numberOfRowsCell.configureForType(.Album, withCount: count)
                        
                        return numberOfRowsCell
                    }
                    
                    
                    let album = albums[indexPath.row]
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.playlistCell, forIndexPath: indexPath) as! PlaylistCell
                    cell.titleLabel.text = album.title
                    
                    return cell
                default:
                    return UITableViewCell()
                }
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.noAuthorizedCell, forIndexPath: indexPath) as! NoAuthorizedCell
            cell.messageLabel.text = "Для отображения списка альбомов необходимо авторизоваться"
            
            return cell
        }
    }
    
}

extension PlaylistsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch selected {
        case .Playlists:
            return
        case .Albums:
            if VKAPIManager.isAuthorized {
                if RequestManager.sharedInstance.getAlbums.state == .Results {
                    let album = albums[indexPath.row]
                    
                    performSegueWithIdentifier("ShowAlbumAudioSegue", sender: album)
                }
            }
        }
    }
    
}