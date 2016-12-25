//
//  NumberOfRowsCell.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// Ячейка для строки с количеством единиц в списке
class NumberOfRowsCell: UITableViewCell {

    /// Количество единиц
    @IBOutlet weak var countLabel: UILabel!
    /// Наименование
    @IBOutlet weak var nameLabel: UILabel!
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Убираем разделительную линию
        separatorInset = UIEdgeInsetsMake(0, bounds.size.width, 0, 0)
    }
    
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

private typealias _NumberOfRowsCellDataType = NumberOfRowsCell
extension _NumberOfRowsCellDataType {
    
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