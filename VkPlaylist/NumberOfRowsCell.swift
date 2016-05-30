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
    
    override func prepareForReuse() {
        countLabel.text = nil
        nameLabel.text = nil
    }
    
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
        case .Playlist:
            if count >= 11 && count <= 14 {
                name = "плейлистов"
            } else {
                switch count % 10 {
                case 1:
                    name = "плейлист"
                case 2, 3, 4:
                    name = "плейлиста"
                default:
                    name = "плейлистов"
                }
            }
        case .Album:
            if count >= 11 && count <= 14 {
                name = "альбомов"
            } else {
                switch count % 10 {
                case 1:
                    name = "альбом"
                case 2, 3, 4:
                    name = "альбома"
                default:
                    name = "альбомов"
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
        case Playlist // Ячейка с количеством плейлистов
        case Album // Ячейка с количеством альбомов
        case Friend // Ячейка с количеством друзей
        case Group // Ячейка с количеством групп
    }
}