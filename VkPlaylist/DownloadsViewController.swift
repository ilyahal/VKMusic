//
//  DownloadsViewController.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
    
    /// Правило для нижней границы контейнера с таблицей
    @IBOutlet weak var containerBottomLayoutConstraint: NSLayoutConstraint!
    
    /// Значение для правила для нижней границы контейнера с таблицей
    var containerBottomLayoutConstraintConstantValue: CGFloat {
        return PlayerManager.sharedInstance.isPlaying ? -9 : -49
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создание кнопок для навигационной панели
        editButton = UIBarButtonItem(image: UIImage(named: "icon-Edit"), style: .Plain, target: self, action: #selector(editButtonTapped)) // Создаем кнопку редактировать
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped)) // Создаем кнопку готово
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setRightBarButtonItems(downloadsTableViewController.downloaded.count != 0 ? editTapped ? [doneButton] : [editButton] : nil, animated: false)
        
        
        updateContainerBottomLayoutConstraintAnimated(false)
        
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidShowMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidHideMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidShowMiniPlayerNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidHideMiniPlayerNotification, object: nil)
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
    
    /// Обновить отступ для нижней границы контейнера с аудиозаписями
    func updateContainerBottomLayoutConstraintAnimated(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.containerBottomLayoutConstraint.constant = self.containerBottomLayoutConstraintConstantValue
        }
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
