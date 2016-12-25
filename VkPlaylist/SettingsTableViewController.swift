//
//  SettingsTableViewController.swift
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

/// Контроллер со списком допустимых настроек
class SettingsTableViewController: UITableViewController {

    /// Кнопка "Авторизоваться"
    @IBOutlet weak var loginButton: UIButton!
    /// Кнопка "Деавторизоваться"
    @IBOutlet weak var logoutButton: UIButton!
    
    /// Переключатель настройки "Предупреждать о наличии"
    @IBOutlet weak var warningWhenDeletingOfExistenceInPlaylistsSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.hidden = true

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        warningWhenDeletingOfExistenceInPlaylistsSwitch.on = DataManager.sharedInstance.isWarningWhenDeletingOfExistenceInPlaylists
        
        updateAuthorizationButtonsStatus(VKAPIManager.isAuthorized)
        
        // Наблюдатели за авторизацией пользователя
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidAutorize), name: VKAPIManagerDidAutorizeNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidUnautorize), name: VKAPIManagerDidUnautorizeNotification, object: nil) // Добавляем слушателя для события деавторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userAutorizationFailed), name: VKAPIManagerAutorizationFailedNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Скрываем мини-плеер при открытии настроек
        PlayerManager.sharedInstance.hideMiniPlayerAnimated(false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Отображаем мини-плеер при закрытии настроек
        PlayerManager.sharedInstance.showMiniPlayerAnimated(true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /// Обновление состояния кнопок авторизации
    func updateAuthorizationButtonsStatus(state: Bool) {
        if state {
            dispatch_async(dispatch_get_main_queue()) {
                self.loginButton.enabled = false
                self.logoutButton.enabled = true
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.loginButton.enabled = true
                self.logoutButton.enabled = false
            }
        }
    }
    
    
    // MARK: Кнопки
    
    /// Вызывается при тапе по кнопке "Войти в аккаунт"
    @IBAction func loginTapped(sender: UIButton) {
        loginButton.enabled = false
        VKAPIManager.autorize()
    }
    
    /// Вызывается при тапе по кнопке "Выход из аккаунта"
    @IBAction func logoutTapped(sender: UIButton) {
        logoutButton.enabled = false
        VKAPIManager.logout()
    }
    
    /// Вызывается при изменении переключателя предупреждения о наличии в других плейлистах при удалении
    @IBAction func warningWhenDeletingOfExistenceInPlaylistsSwitchChanged(sender: UISwitch) {
        if sender.on {
            DataManager.sharedInstance.warningWhenDeletingOfExistenceInPlaylistsEnabled()
        } else {
            DataManager.sharedInstance.warningWhenDeletingOfExistenceInPlaylistsDisabled()
        }
    }
    
    
    // MARK: Авторизация пользователя
    
    /// Пользователь авторизовался
    func userDidAutorize() {
        updateAuthorizationButtonsStatus(true)
    }
    
    /// Пользователь деавторизовался
    func userDidUnautorize() {
        updateAuthorizationButtonsStatus(false)
    }
    
    /// При авторизации пользователя произошла ошибка
    func userAutorizationFailed() {
        updateAuthorizationButtonsStatus(false)
    }
    
}
