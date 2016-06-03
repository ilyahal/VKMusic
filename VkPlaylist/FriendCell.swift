//
//  FriendCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

/// Ячейка для строки с другом
class FriendCell: UITableViewCell {
    
    /// Задача для загрузки аватарки друга
    private var downloadTask: NSURLSessionDownloadTask?
    
    /// Аватарка друга
    @IBOutlet weak var userImageView: UIImageView!
    /// Полное имя друга
    @IBOutlet weak var userNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.bounds.size.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel() // Отменяем загрузку
        downloadTask = nil
        userImageView.image = nil
        userNameLabel.text = nil
    }
    
    /// Настройка ячейки для указанного друга с указанным кэшем аватарок пользователя
    func configureForFriend(friend: Friend, withImageCacheStorage imageCache: NSCache) {
        
        // Настройка имени
        userNameLabel.text = friend.getFullName()
        
        // Настройка фотографии
        userImageView.image = UIImage(named: "friend-photo-placeholder-icon")!
        userImageView.tintImageColor(UIColor.blackColor()) // Заливаем изображение указанным цветом
        
        if let imageFromCache = imageCache.objectForKey(friend.id) as? UIImage { // Пытаемся загрузить изображение из кэша
            userImageView.image = imageFromCache
        } else {
            if let url = NSURL(string: friend.photo_200_orig) { // Если есть URL с аватаркой друга
                let session = NSURLSession.sharedSession()
                let id = friend.id // Идентификатор пользователя
                
                let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak userImageView, weak imageCache] url, response, error in // Создаем задачу загрузки файла по указанному URL
                    if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) { // Если нет ошибок и имеется путь к загруженному файлу и возможно создать NSData из данных по указанному URL и возможно содать объект изображения из указанного NSData
                        dispatch_async(dispatch_get_main_queue()) {
                            if let strongUserImageView = userImageView, strongImageCache = imageCache { // Если объект еще существует
                                let userImage = image.resizedImageWithBounds(strongUserImageView.bounds.size)
                                
                                strongUserImageView.image = userImage // Устанавливаем загруженное изображение
                                strongImageCache.setObject(userImage, forKey: id) // Добавляем значение в кэш
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
