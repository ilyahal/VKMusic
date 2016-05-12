//
//  MoreTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {

    private var linksToScreens = [LinkToScreen]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillLinksToScreensArray()
        
        // Настройка кнопки назад на дочерних экранах
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .Plain, target: nil, action: nil)
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.sharedInstance.friends.clear()
        if !RequestManager.sharedInstance.getFriends.cancel() {
            RequestManager.sharedInstance.getFriends.dropState()
        }
        
        DataManager.sharedInstance.groups.clear()
        if !RequestManager.sharedInstance.getGroups.cancel() {
            RequestManager.sharedInstance.getGroups.dropState()
        }
    }
    
    // Заполнение массива ссылок на экраны
    func fillLinksToScreensArray() {
        linksToScreens.append(LinkToScreen(title: "Друзья", icon: "icon-UserReverse", segueIdentifier: "ShowFriendsSegue"))
        linksToScreens.append(LinkToScreen(title: "Группы", icon: "icon-MultipleUsersReverse", segueIdentifier: "ShowGroupsSegue"))
        linksToScreens.append(LinkToScreen(title: "Рекомендации", icon: "icon-Recommendation", segueIdentifier: "ShowRecommendationsSegue"))
        linksToScreens.append(LinkToScreen(title: "Популярное", icon: "icon-Favorite", segueIdentifier: "ShowPopularSegue"))
        linksToScreens.append(LinkToScreen(title: "Настройки", icon: "icon-Settings", segueIdentifier: "ShowSettingsSegue"))
    }

}

// MARK: Типы данных

private typealias MoreTableViewControllerDataTypes = MoreTableViewController
extension MoreTableViewControllerDataTypes {
    
    // Ссылки на дочерние экраны
    class LinkToScreen {
        let title: String
        let icon: String
        let segueIdentifier: String
        
        init(title: String, icon: String, segueIdentifier: String) {
            self.title = title
            self.icon = icon
            self.segueIdentifier = segueIdentifier
        }
    }
    
}


// MARK: UITableViewDataSource

private typealias MoreTableViewControllerUITableViewDataSource = MoreTableViewController
extension MoreTableViewControllerUITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linksToScreens.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath)
        let linkToScreen = linksToScreens[indexPath.row]
        
        cell.imageView!.image = UIImage(named: linkToScreen.icon)
        cell.imageView!.tintImageColor((UIApplication.sharedApplication().delegate as! AppDelegate).tintColor)
        cell.textLabel!.text = linkToScreen.title
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias MoreTableViewControllerDelegate = MoreTableViewController
extension MoreTableViewControllerDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let linkToScreen = linksToScreens[indexPath.row]
        performSegueWithIdentifier(linkToScreen.segueIdentifier, sender: nil)
    }

}