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
    
    var resultSearchController: UISearchController!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [Track]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchBar.delegate = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.placeholder = "Поиск в Моей музыке"
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.contentOffset = CGPointMake(0, CGRectGetHeight(resultSearchController.searchBar.frame)) // Прячем строку поиска
        
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
        
        // Авторизация пользователя
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidAutorize), name: VKAPIManagerDidAutorizeNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidUnautorize), name: VKAPIManagerDidUnautorizeNotification, object: nil) // Добавляем слушателя для события деавторизации
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !VKAPIManager.isAuthorized {
            showAuthorizationViewController()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Авторизация пользователя
    
    func showAuthorizationViewController() {
        if authorizationNavigationController == nil {
            authorizationNavigationController = storyboard?.instantiateViewControllerWithIdentifier("AuthorizationNavigationController") as? UINavigationController
            presentViewController(authorizationNavigationController!, animated: true, completion: nil)
        }
    }
    
    func hideAuthorizationViewController() {
        if let _ = authorizationNavigationController {
            dismissViewControllerAnimated(true, completion: nil)
            authorizationNavigationController = nil
        }
    }
    
    func userDidAutorize() {
        hideAuthorizationViewController()
    }
    
    func userDidUnautorize() {
        //showAuthorizationViewController()
    }
    
    // MARK: Работа с клавиатурой
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
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
        return searchResults.count
    }
    
    // Получение ячейки для строки таблицы
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AudioCell", forIndexPath: indexPath) as! AudioCell
        let track = searchResults[indexPath.row]
        
        cell.delegate = self
        
        cell.nameLabel.text = track.name
        cell.artistLabel.text = track.artist
        
        return cell
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