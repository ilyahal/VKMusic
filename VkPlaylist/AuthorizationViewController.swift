//
//  AuthorizationViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Вызывается при тапе по кнопке "Авторизоваться"
    @IBAction private func authorizationTapped(sender: UIButton) {
        VKAPIManager.autorize()
    }

}
