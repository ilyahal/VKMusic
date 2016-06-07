//
//  DownloadsViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий контейнер со списком активных загрузок и уже загруженных аудиозаписей
class DownloadsViewController: UIViewController {
    
    weak var downloadsTableViewController: DownloadsTableViewController!
    
    /// Кнопка "Готово" в навигационной панели
    var doneButton: UIBarButtonItem!
    /// Кнопка "Изменить" в навигационной панели
    var editButton: UIBarButtonItem!
    /// Нажата ли кнопка "Изменить"
    var editTapped = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создание кнопок для навигационной панели
        editButton = UIBarButtonItem(image: UIImage(named: "icon-Edit"), style: .Plain, target: self, action: #selector(editButtonTapped)) // Создаем кнопку редактировать
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped)) // Создаем кнопку готово
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setRightBarButtonItems(downloadsTableViewController.downloaded.count != 0 ? editTapped ? [doneButton] : [editButton] : nil, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showDownloadsTableViewControllerInContainerSegue {
            let downloadsTableViewController = segue.destinationViewController as! DownloadsTableViewController
            downloadsTableViewController.delegate = self
            
            self.downloadsTableViewController = downloadsTableViewController
        }
    }
    
    /// Начало редактирования таблицы
    func startEditing() {
        downloadsTableViewController.tableView.editing = false // Если отображалась кнопка "Удалить", доступная по свайпу, скрываем ее
        
        navigationItem.setRightBarButtonItems([doneButton], animated: true)
        
        downloadsTableViewController.tableView.editing = true
        editTapped = true
        
        downloadsTableViewController.reloadTableView()
    }
    
    /// Окончание редактирования таблицы
    func endEditing() {
        navigationItem.setRightBarButtonItems([editButton], animated: true)
        
        downloadsTableViewController.tableView.editing = false
        editTapped = false
        
        downloadsTableViewController.reloadTableView()
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    /// Кнопка "Изменить" была нажата
    func editButtonTapped(sender: AnyObject?) {
        startEditing()
    }
    
    // Кнопка "Готово" была нажата
    func doneButtonTapped(sender: AnyObject?) {
        endEditing()
    }
    
}


// MARK: DownloadsTableViewControllerDelegate

extension DownloadsViewController: DownloadsTableViewControllerDelegate {
    
    // Список аудиозаписей был изменен
    func downloadsTableViewControllerUpdateContent() {
        if downloadsTableViewController.downloaded.count == 0 {
            if editTapped {
                endEditing()
            }
            
            navigationItem.setRightBarButtonItems(nil, animated: true)
        } else {
            if !editTapped && !downloadsTableViewController.isSearched {
                navigationItem.setRightBarButtonItems([editButton], animated: true)
            }
        }
    }
    
    // Поиск был начат
    func downloadsTableViewControllerSearchStarted() {
        if editTapped {
            endEditing()
        }
        
        navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    
    // Поиск был закончен
    func downloadsTableViewControllerSearchEnded() {
        navigationItem.setRightBarButtonItems(downloadsTableViewController.downloaded.count != 0 ? [editButton] : nil, animated: true)
    }
    
}
