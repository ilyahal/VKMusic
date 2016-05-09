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
    @IBAction func authorizationTapped(sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            VKAPIManager.autorize()
        } else {
            showNetworkError()
        }
    }
    
    // Отображает уведомление с сообщением о проблемах с подключением к интернету
    func showNetworkError() {
        let alertController = UIAlertController(title: "Ошибка", message: "Проверьте соединение с интернетом!", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

}
