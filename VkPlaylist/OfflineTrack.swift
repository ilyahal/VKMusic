//
//  OfflineTrack.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 26.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation
import CoreData

/// Офлайн аудиозапись
class OfflineTrack: NSManagedObject {

    /// URL файла аудиозаписи в файловой системе
    var url: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString // Получаем путь к папке Documents
        return documentsPath.stringByAppendingPathComponent(fileName)
    }
    
}
