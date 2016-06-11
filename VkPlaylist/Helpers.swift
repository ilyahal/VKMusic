//
//  Helpers.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 01.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

/// Выполнить с задержкой
func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

/// Преобразатель цифрового отображения даты в читабельную человеком
var timeFromSecondsDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return formatter
}()