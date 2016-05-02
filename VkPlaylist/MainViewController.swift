//
//  MainViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var authorizationNavigationController: UINavigationController? // view controller для авторизации
    
    private var resultSearchController: UISearchController!
    @IBOutlet private weak var tableView: UITableView!
    
    private struct TableViewCellIdentifiers {
        static let nothingFoundCell = "NothingFoundCell" // Ячейка с сообщением "ничего не найдено"
        static let loadingCell = "LoadingCell" // Ячейка с сообщением о загрузке данных
        static let audioCell = "AudioCell" // Ячейка для вывода аудиозаписи
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка кнопки назад на дочерних экранах
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
        
        
        // Настройка поисковой панели
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchBar.delegate = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.placeholder = "Поиск в Моей музыке"
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.contentOffset = CGPointMake(0, CGRectGetHeight(resultSearchController.searchBar.frame)) // Прячем строку поиска
        
        
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка ничего не найдено
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка загрузка
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        // Наблюдатели за авторизацией пользователя
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidAutorize), name: VKAPIManagerDidAutorizeNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidUnautorize), name: VKAPIManagerDidUnautorizeNotification, object: nil) // Добавляем слушателя для события деавторизации
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !VKAPIManager.isAuthorized {
            showAuthorizationViewController()
        }
    }
    
    // Заново отрисовать таблицу
    private func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Авторизация пользователя
    
    // Показать экран с авторизацией пользователя
    private func showAuthorizationViewController() {
        if authorizationNavigationController == nil {
            authorizationNavigationController = storyboard?.instantiateViewControllerWithIdentifier("AuthorizationNavigationController") as? UINavigationController
            presentViewController(authorizationNavigationController!, animated: true, completion: nil)
        }
    }
    
    // Скрыть экран с авторизацией пользователя
    private func hideAuthorizationViewController() {
        if let _ = authorizationNavigationController {
            dismissViewControllerAnimated(true, completion: nil)
            authorizationNavigationController = nil
        }
    }
    
    // Пользователь авторизовался
    @objc private func userDidAutorize() {
        hideAuthorizationViewController()
        
        RequestManager.sharedInstance.getAudio { success in
            self.reloadTableView()
            
            if !success {
                switch RequestManager.sharedInstance.getAudioError {
                case .NetworkError:
                    let alertController = UIAlertController(title: "Ошибка", message: "Проверьте соединение с интернетом!", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: false, completion: nil)
                    }
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
        reloadTableView()
    }
    
    // Пользователь деавторизовался
    @objc private func userDidUnautorize() {
        DataManager.sharedInstance.clearMyMusic()
        RequestManager.sharedInstance.cancelRequestInCaseOfDeavtorization()
        reloadTableView()
    }
    
    
    // MARK: Работа с клавиатурой
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    @objc private func dismissKeyboard() {
        resultSearchController.searchBar.resignFirstResponder()
    }
    
}

// MARK: TrackCellDelegate

extension MainViewController: AudioCellDelegate {
    
    // Вызывается при тапе по кнопке Пауза
    func pauseTapped(cell: AudioCell) {
        print("pause" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Продолжить
    func resumeTapped(cell: AudioCell) {
        print("resume" + cell.nameLabel.text!)
    }

    // Вызывается при тапе по кнопке Отмена
    func cancelTapped(cell: AudioCell) {
        print("cancel" + cell.nameLabel.text!)
    }
    
    // Вызывается при тапе по кнопке Скачать
    func downloadTapped(cell: AudioCell) {
        print("download" + cell.nameLabel.text!)
    }
}

// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    // Получение количества строк таблицы
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch RequestManager.sharedInstance.getAudioState {
        case .NoResults, .Loading:
            return 1
        case .Results:
            return DataManager.sharedInstance.myMusic.count
        default:
            return 0
        }
    }
    
    // Получение ячейки для строки таблицы
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch RequestManager.sharedInstance.getAudioState {
        case .NoResults:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
            
            cell.messageLabel.text = "Список аудиозаписей пуст"
            
            return cell
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! LoadingCell
            
            cell.activityIndicator.startAnimating()
            
            return cell
        case .Results:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.audioCell, forIndexPath: indexPath) as! AudioCell
            let track = DataManager.sharedInstance.myMusic[indexPath.row]
            
            cell.delegate = self
            
            cell.nameLabel.text = track.title
            cell.artistLabel.text = track.artist
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    // Высота каждой строки
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    // Вызывается при тапе по строке таблицы
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
     // Говорит делегату что кнопка поиска была нажата
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
     // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
     // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}