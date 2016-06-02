//
//  AuthorizationViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 02.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер отображающий приветствие и приглашение авторизоваться
class AuthorizationViewController: UIViewController {

    /// Вызывается при нажатии по кнопке "Авторизоваться"
    @IBAction func authorizationTapped(sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            VKAPIManager.autorize()
        } else {
            showNetworkError()
        }
    }
    
    /// Отобразить уведомление с сообщением о проблеме при подключении к интернету
    private func showNetworkError() {
        let alertController = UIAlertController(title: "Ошибка", message: "Проверьте соединение с интернетом!", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

}
