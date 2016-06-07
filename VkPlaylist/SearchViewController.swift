//
//  SearchViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком искомых аудиозаписей
class SearchViewController: UIViewController {

    weak var searchTableViewController: SearchTableViewController!
    
    /// Контроллер поиска
    let searchController = UISearchController(searchResultsController: nil)
    /// Выполняется ли сейчас поиск
    var isSearched: Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        definesPresentationContext = true
        
        navigationItem.titleView = searchController.searchBar
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showSearchTableViewControllerInContainerSegue {
            let searchTableViewController = segue.destinationViewController as! SearchTableViewController
            self.searchTableViewController = searchTableViewController
        }
    }
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
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
    
}


// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    // Пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return VKAPIManager.isAuthorized
    }
    
    // Пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // На клавиатуре была нажата кнопка "Искать"
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTableViewController.searchRequest = searchController.searchBar.text!
    }
    
    // В поисковой панели была нажата кнопка "Отмена"
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchTableViewController.music.removeAll()
        
        DataManager.sharedInstance.searchMusic.clear()
        if !RequestManager.sharedInstance.searchAudio.cancel() {
            RequestManager.sharedInstance.searchAudio.dropState()
        }
        
        searchTableViewController.reloadTableView()
    }
    
}


// MARK: UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    // Поле поиска получило фокус или значение поискового запроса изменено
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
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