//
//  GroupCell.swift
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

/// Ячейка для строки с группой
class GroupCell: UITableViewCell {

    /// Задача для загрузки аватарки друга
    private var downloadTask: NSURLSessionDownloadTask?
    
    /// Аватарка группы
    @IBOutlet weak var groupImageView: UIImageView!
    /// Название группы
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        groupImageView.layer.cornerRadius = groupImageView.bounds.size.width / 2
        groupImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel() // Отменяем загрузку
        downloadTask = nil
        groupImageView.image = nil
        groupNameLabel.text = nil
    }
    
    /// Настройка ячейки для указанной группы с указанным кэшем аватарок групп
    func configureForGroup(group: Group, withImageCacheStorage imageCache: NSCache) {
        
        // Настройка названия
        groupNameLabel.text = group.name
        
        // Настройка фотографии
        groupImageView.image = UIImage(named: "friend-photo-placeholder-icon")!
        groupImageView.tintImageColor(UIColor.blackColor()) // Заливаем изображение указанным цветом
        
        if let imageFromCache = imageCache.objectForKey(group.id) as? UIImage { // Пытаемся загрузить изображение из кэша
            groupImageView.image = imageFromCache
        } else {
            if let url = NSURL(string: group.photo_200) { // Если есть URL с аватаркой группы
                let session = NSURLSession.sharedSession()
                let id = group.id // Идентификатор группы
                
                let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak groupImageView, weak imageCache] url, response, error in // Создаем задачу загрузки файла по указанному URL
                    if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) { // Если нет ошибок и имеется путь к загруженному файлу и возможно создать NSData из данных по указанному URL и возможно содать объект изображения из указанного NSData
                        dispatch_async(dispatch_get_main_queue()) {
                            if let strongGroupImageView = groupImageView, strongImageCache = imageCache { // Если объект еще существует
                                let groupImage = image.resizedImageWithBounds(strongGroupImageView.bounds.size)
                                
                                strongGroupImageView.image = groupImage // Устанавливаем загруженное изображение
                                strongImageCache.setObject(groupImage, forKey: id) // Добавляем значение в кэш
                            }
                        }
                    }
                })
                
                downloadTask.resume() // Начинаем загрузку
                
                self.downloadTask = downloadTask
            }
        }
    }

}
