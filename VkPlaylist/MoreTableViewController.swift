//
//  MoreTableViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 08.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Контроллер содержащий ссылки на другие страницы приложения
class MoreTableViewController: UITableViewController {

    /// Массив ссылок на другие страницы
    private var linksToScreens = [LinkToScreen]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillLinksToScreensArray()
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
    }
    
    /// Заполнение массива ссылок на экраны
    func fillLinksToScreensArray() {
        linksToScreens.append(LinkToScreen(title: "Друзья", icon: "icon-UserReverse", segueIdentifier: SegueIdentifiers.showFriendsViewControllerSegue))
        linksToScreens.append(LinkToScreen(title: "Группы", icon: "icon-MultipleUsersReverse", segueIdentifier: SegueIdentifiers.showGroupsViewControllerSegue))
        linksToScreens.append(LinkToScreen(title: "Рекомендации", icon: "icon-Recommendation", segueIdentifier: SegueIdentifiers.showRecommendationsMusicViewControllerSegue))
        linksToScreens.append(LinkToScreen(title: "Популярное", icon: "icon-Favorite", segueIdentifier: SegueIdentifiers.showPopularMusicViewControllerSegue))
        linksToScreens.append(LinkToScreen(title: "Настройки", icon: "icon-Settings", segueIdentifier: SegueIdentifiers.showSettingsSegue))
    }

}


// MARK: Типы данных

private typealias _MoreTableViewControllerDataTypes = MoreTableViewController
extension _MoreTableViewControllerDataTypes {
    
    /// Ссылки на дочерние экраны
    struct LinkToScreen {
        
        /// Название страницы
        let title: String
        /// Иконка страницы
        let icon: String
        /// Идентификатор перехода
        let segueIdentifier: String
        
    }
    
}


// MARK: UITableViewDataSource

private typealias _MoreTableViewControllerUITableViewDataSource = MoreTableViewController
extension _MoreTableViewControllerUITableViewDataSource {
    
    // Количество строк в секции
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linksToScreens.count
    }
    
    // Ячейки для строк таблицы
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.moreCell, forIndexPath: indexPath)
        let linkToScreen = linksToScreens[indexPath.row]
        
        cell.imageView!.image = UIImage(named: linkToScreen.icon)
        cell.imageView!.tintImageColor((UIApplication.sharedApplication().delegate as! AppDelegate).tintColor)
        cell.textLabel!.text = linkToScreen.title
        
        return cell
    }
    
}


// MARK: UITableViewDelegate

private typealias _MoreTableViewControllerDelegate = MoreTableViewController
extension _MoreTableViewControllerDelegate {
    
    // Обработка нажатия по ячейке
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let linkToScreen = linksToScreens[indexPath.row]
        performSegueWithIdentifier(linkToScreen.segueIdentifier, sender: nil)
    }

}