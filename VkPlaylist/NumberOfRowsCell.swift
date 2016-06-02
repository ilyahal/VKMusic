//
//  NumberOfRowsCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с количеством единиц в списке
class NumberOfRowsCell: UITableViewCell {

    /// Количество единиц
    @IBOutlet weak var countLabel: UILabel!
    /// Наименование
    @IBOutlet weak var nameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        countLabel.text = nil
        nameLabel.text = nil
    }
    
    /// Настройка ячейки для указанного наименования и количества единиц
    func configureForType(type: Type, withCount count: Int) {
        
        // Склоняем наименование
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
        
        // Отображение данных
        countLabel.text = "\(count)"
        nameLabel.text = name
    }
    
}


// MARK: NumberOfRowsCellDataType

private typealias NumberOfRowsCellDataType = NumberOfRowsCell
extension NumberOfRowsCellDataType {
    
    /// Перечисление содержащие возможное наименование единиц
    enum Type {
        
        /// Аудиозаписи
        case Audio
        /// Плейлисты
        case Playlist
        /// Альбомы
        case Album
        /// Друзья
        case Friend
        /// Группы
        case Group
        
    }
    
}