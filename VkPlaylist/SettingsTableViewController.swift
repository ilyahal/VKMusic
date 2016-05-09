//
//  SettingsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var loginButton: UIButton! // Кнопка "Войти в аккаунт"
    @IBOutlet weak var logoutButton: UIButton! // Кнопка "Выход из аккаунта"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        updateAuthorizationButtonsStatus(VKAPIManager.isAuthorized)
        
        // Наблюдатели за авторизацией пользователя
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidAutorize), name: VKAPIManagerDidAutorizeNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userDidUnautorize), name: VKAPIManagerDidUnautorizeNotification, object: nil) // Добавляем слушателя для события деавторизации
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userAutorizationFailed), name: VKAPIManagerAutorizationFailedNotification, object: nil) // Добавляем слушаетля для события успешной авторизации
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Обновление состояния кнопок авторизации
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
    
    // Вызывается при тапе по кнопке "Войти в аккаунт"
    @IBAction func loginTapped(sender: UIButton) {
        loginButton.enabled = false
        VKAPIManager.autorize()
    }
    
    // Вызывается при тапе по кнопке "Выход из аккаунта"
    @IBAction func logoutTapped(sender: UIButton) {
        logoutButton.enabled = false
        VKAPIManager.logout()
    }
    
    
    // MARK: Авторизация пользователя
    
    // Пользователь авторизовался
    func userDidAutorize() {
        updateAuthorizationButtonsStatus(true)
    }
    
    // Пользователь деавторизовался
    func userDidUnautorize() {
        updateAuthorizationButtonsStatus(false)
    }
    
    // При авторизации пользователя произошла ошибка
    func userAutorizationFailed() {
        updateAuthorizationButtonsStatus(false)
    }
    
}
