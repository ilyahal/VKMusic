//
//  GroupCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 10.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    var downloadTask: NSURLSessionDownloadTask?
    
    
    @IBOutlet weak var groupImageView: UIImageView!
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
    
    func configureForGroup(group: Group, withImageCacheStorage imageCache: NSCache) {
        
        // Настройка имени
        groupNameLabel.text = group.name
        
        // Настройка фотографии
        groupImageView.image = UIImage(named: "friend-photo-placeholder-icon")!
        groupImageView.tintImageColor(UIColor.blackColor())
        if let imageFromCache = imageCache.objectForKey(group.id!) as? UIImage { // Пытаемся загрузить изображение из кэша
            groupImageView.image = imageFromCache
        } else {
            if let url = NSURL(string: group.photo_200!) { // Если есть URL с изоражением 60 пикс
                let session = NSURLSession.sharedSession()
                let id = group.id! // Идентификатор пользователя
                
                let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak groupImageView, weak imageCache] url, response, error in // Создаем задачу загрузки файла по указанному URL
                    if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) { // Если нет ошибок и имеется путь к загруженному файлу и возможно создать NSData из данных по указанному URL и возможно содать объект изображения из указанного NSData
                        dispatch_async(dispatch_get_main_queue()) { // Выполняем в основном потоке
                            if let strongGroupImageView = groupImageView, let strongImageCache = imageCache { // Если объект еще существует
                                let resultImage = image.resizedImageWithBounds(CGSize(width: 45, height: 45))
                                
                                strongGroupImageView.image = resultImage // Устанавливаем загруженное изображение
                                strongImageCache.setObject(resultImage, forKey: id) // Добавляем значение в кэш
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
