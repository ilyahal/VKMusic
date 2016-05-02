//
//  SettingsTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var logoutButton: UIButton! // Кнопка "Выход из аккаунта"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        logoutButton.enabled = VKAPIManager.isAuthorized
    }
    
    // Вызывается при тапе по кнопке "Выход из аккаунта"
    @IBAction func logoutTapped(sender: UIButton) {
        VKAPIManager.logout()
        sender.enabled = false
    }
    
}
