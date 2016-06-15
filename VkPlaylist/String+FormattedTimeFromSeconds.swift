//
//  String+FormattedTimeFromSeconds.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 12.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

extension String {
    
    static func formattedTimeFromSeconds(seconds: Double) -> String {
        let date = NSDate(timeIntervalSince1970: seconds)
        
        if seconds >= 3600 {
            timeFromSecondsDateFormatter.dateFormat = "HH:mm:ss"
        } else {
            timeFromSecondsDateFormatter.dateFormat = "mm:ss"
        }
        
        let result = timeFromSecondsDateFormatter.stringFromDate(date)
        
        return result.hasPrefix("0") ? result.substringWithRange(Range<String.Index>(result.startIndex.advancedBy(1)..<result.endIndex)) : result
    }
    
}