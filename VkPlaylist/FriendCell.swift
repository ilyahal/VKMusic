//
//  FriendCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
    var downloadTask: NSURLSessionDownloadTask?
    

    @IBOutlet weak var userImageView: UIImageView!
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
    
    func configureForFriend(friend: Friend, withImageCacheStorage imageCache: NSCache) {
        
        // Настройка имени
        if let first_name = friend.first_name {
            userNameLabel.text = first_name
        }
        if let last_name = friend.last_name {
            if !userNameLabel.text!.isEmpty {
                userNameLabel.text! += " "
            }
            
            userNameLabel.text! += last_name
        }
        if userNameLabel.text!.isEmpty {
            userNameLabel.text = "UNKNOWN"
        }
        
        // Настройка фотографии
        userImageView.image = UIImage(named: "friend-photo-placeholder-icon")!
        userImageView.tintImageColor(UIColor.blackColor())
        if let imageFromCache = imageCache.objectForKey(friend.id!) as? UIImage { // Пытаемся загрузить изображение из кэша
            userImageView.image = imageFromCache
        } else {
            if let url = NSURL(string: friend.photo_200_orig!) { // Если есть URL с изоражением 60 пикс
                let session = NSURLSession.sharedSession()
                let id = friend.id! // Идентификатор пользователя
                
                let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak userImageView, weak imageCache] url, response, error in // Создаем задачу загрузки файла по указанному URL
                    if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) { // Если нет ошибок и имеется путь к загруженному файлу и возможно создать NSData из данных по указанному URL и возможно содать объект изображения из указанного NSData
                        dispatch_async(dispatch_get_main_queue()) { // Выполняем в основном потоке
                            if let strongUserImageView = userImageView, let strongImageCache = imageCache { // Если объект еще существует
                                let resultImage = image.resizedImageWithBounds(CGSize(width: 45, height: 45))
                                
                                strongUserImageView.image = resultImage // Устанавливаем загруженное изображение
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
