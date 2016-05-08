//
//  MusicFromInternetTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MusicFromInternetTableViewController: UITableViewController {
    
    var currentAuthorizationStatus: Bool! // Состояние авторизации пользователя при последнем отображении экрана
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAuthorizationStatus = VKAPIManager.isAuthorized
        
        
        // Настройка Pull-To-Refresh
        if VKAPIManager.isAuthorized {
            pullToRefreshEnable(true)
        }
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.noAuthorizedCell, bundle: nil) // Ячейка "Необходимо авторизоваться"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noAuthorizedCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.networkErrorCell, bundle: nil) // Ячейка "Ошибка при подключении к интернету"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.networkErrorCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) // Ячейка "Загрузка"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.audioCell, bundle: nil) // Ячейка с аудиозаписью
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.audioCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentAuthorizationStatus != VKAPIManager.isAuthorized {
            if VKAPIManager.isAuthorized {
                pullToRefreshEnable(true)
            } else {
                pullToRefreshEnable(false)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Pull-to-Refresh
    
    func pullToRefreshEnable(enable: Bool) {
        if enable {
            refreshControl = UIRefreshControl()
            //refreshControl!.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить...") // Все крашится :с
            refreshControl!.addTarget(self, action: #selector(refreshMyMusic), forControlEvents: .ValueChanged) // Добавляем обработчик контроллера обновления
        } else {
            refreshControl?.removeTarget(self, action: #selector(refreshMyMusic), forControlEvents: .ValueChanged)
            refreshControl = nil
        }
    }
    
    func refreshMyMusic() {}
    
}


// MARK: Типы данных

private typealias MusicFromInternetTableViewControllerDataTypes = MusicFromInternetTableViewController
extension MusicFromInternetTableViewControllerDataTypes {
    
    // Идентификаторы ячеек
    struct TableViewCellIdentifiers {
        static let noAuthorizedCell = "NoAuthorizedCell" // Ячейка с сообщением об отсутствии авторизации
        static let networkErrorCell = "NetworkErrorCell" // Ячейка с сообщением об ошибке при подключении к интернету
        static let nothingFoundCell = "NothingFoundCell" // Ячейка с сообщением "ничего не найдено"
        static let loadingCell = "LoadingCell" // Ячейка с сообщением о загрузке данных
        static let audioCell = "AudioCell" // Ячейка для вывода аудиозаписи
    }
    
}


// MARK: AudioCellDelegate

extension MusicFromInternetTableViewController: AudioCellDelegate {
    
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


// MARK: UITableViewDelegate

private typealias MusicFromInternetTableViewControllerDelegate = MusicFromInternetTableViewController
extension MusicFromInternetTableViewControllerDelegate {
    
    // Высота каждой строки
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
}
