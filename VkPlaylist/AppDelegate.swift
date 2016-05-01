//
//  AppDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let tintColor =  UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1)
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        
        // Инициализация SwiftyVK с id приложения и делегатом 
        VK.start(appID: VKAPIManager.applicationID, delegate: self)
        
        return true
    }
    
    // Вызается при переходе из URL при авторизации
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        // Получение токена
        VK.processURL(url, options: options)
        
        return true
    }

    // MARK: - Кастомизация приложения
    
    private func customizeAppearance() {
        window?.tintColor = tintColor
        UISearchBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    
}

// MARK: VKDelegate

extension AppDelegate: VKDelegate {
    
    // Запрашивает необходимые права доступа к аккаунту пользователя
    func vkWillAutorize() -> [VK.Scope] {
        return VKAPIManager.scope
    }
    
    // Вызывается при возникновении ошибки при авторизации
    func vkAutorizationFailed(error: VK.Error) {
        print("Autorization failed with error: \n\(error)")
    }
    
    // Вызывается при успешной авторизации
    func vkDidAutorize(parameters: Dictionary<String, String>) {
    }
    
    // Вызывается при деавторизации
    func vkDidUnautorize() {
    }
    
    // Вызывается для получения настроек места сохранения токена
    func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
        return (true, "")
    }
    
    // Запрашивает родительский view controller, который будет отображать view controller с окном авторизации
    func vkWillPresentView() -> UIViewController {
        return self.window!.rootViewController!
    }
    
}