//
//  UITableView+HideSearchBar.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

extension UITableView {
    
    func hideSearchBar() {
        if let bar = self.tableHeaderView as? UISearchBar {
            let height = CGRectGetHeight(bar.frame)
            let offset = self.contentOffset.y
            
            if offset < height {
                self.contentOffset = CGPointMake(0, height)
            }
        }
    }
    
}