//
//  NumberOfRowsCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class NumberOfRowsCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configureForType(type: Type, withCount count: Int) {
        countLabel.text = String(count)
        
        let name: String!
        switch type {
        case .Audio:
            if count >= 11 && count <= 14 {
                name = "аудиозаписей"
            } else {
                switch count % 10 {
                case 1:
                    name = "аудиозапись"
                case 2, 3, 4:
                    name = "аудиозаписи"
                default:
                    name = "аудиозаписей"
                }
            }
        case .Friend:
            if count >= 11 && count <= 14 {
                name = "друзей"
            } else {
                switch count % 10 {
                case 1:
                    name = "друг"
                case 2, 3, 4:
                    name = "друга"
                default:
                    name = "друзей"
                }
            }
        case .Group:
            if count >= 11 && count <= 14 {
                name = "сообществ"
            } else {
                switch count % 10 {
                case 1:
                    name = "сообщество"
                case 2, 3, 4:
                    name = "сообщества"
                default:
                    name = "сообществ"
                }
            }
        }
        
        nameLabel.text = name
    }
    
}


// MARK: NumberOfRowsCellDataType

private typealias NumberOfRowsCellDataType = NumberOfRowsCell
extension NumberOfRowsCellDataType {
    enum Type {
        case Audio // Ячейка с количеством аудиозаписей
        case Friend // Ячейка с количеством друзей
        case Group // Ячейка с количеством групп
    }
}