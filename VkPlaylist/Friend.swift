//
//  Friend.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

class Friend {
    let id: Int?
    let last_name: String?
    let photo_200_orig: String?
    let first_name: String?
    
    init(id: Int?, last_name: String?, photo_200_orig: String?, first_name: String?) {
        self.id = id
        self.last_name = last_name
        self.photo_200_orig = photo_200_orig
        self.first_name = first_name
    }
    
    func getFullName() -> String {
        var userName = ""
        
        if let first_name = first_name {
            userName = first_name
        }
        if let last_name = last_name {
            if !userName.isEmpty {
                userName += " "
            }
            
            userName += last_name
        }
        if userName.isEmpty {
            userName = "UNKNOWN"
        }
        
        return userName
    }
}