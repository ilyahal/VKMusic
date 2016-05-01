//
//  MainViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var resultSearchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self // Объект ответственный за обновление контента
        resultSearchController.dimsBackgroundDuringPresentation = true // Недоступны ли элементы при поиске
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.placeholder = "Поиск в Моей музыке"
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        
        tableView.contentOffset = CGPointMake(0, CGRectGetHeight(resultSearchController.searchBar.frame))
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AudioCell", forIndexPath: indexPath) as! AudioTableViewCell
        
        cell.nameLabel.text = "Name"
        cell.artistLabel.text = "Artist"
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}