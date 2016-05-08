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
    
    // Вызается при активации приложения из URL
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        // Получение токена
        VK.processURL(url, options: options)
        
        return true
    }

    // MARK: - Кастомизация приложения
    
    private func customizeAppearance() {
        window?.tintColor = tintColor
        UISearchBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    
    // MARK: Авторизация пользователя
    
    // Пользователь деавторизовался
    func userDidUnautorize() {
        RequestManager.sharedInstance.cancelRequestInCaseOfDeavtorization()
        DataManager.sharedInstance.clearMyMusic()
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerAutorizationFailedNotification, object: error)
    }
    
    // Вызывается при успешной авторизации
    func vkDidAutorize(parameters: Dictionary<String, String>) {
        NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidAutorizeNotification, object: nil)
    }
    
    // Вызывается при деавторизации
    func vkDidUnautorize() {
        NSNotificationCenter.defaultCenter().postNotificationName(VKAPIManagerDidUnautorizeNotification, object: nil)
        
        userDidUnautorize()
    }
    
    // Вызывается для получения настроек места сохранения токена
    func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
        return (true, "")
    }
    
    // Запрашивает родительский view controller, который будет отображать view controller с окном авторизации
    func vkWillPresentView() -> UIViewController {
        return window!.rootViewController!
    }
    
}