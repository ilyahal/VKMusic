//
//  PlayerDelegate.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import Foundation

protocol PlayerDelegate: class {
    
    /// Плеер изменил состояние
    func playerStateDidChange(player: Player)
    /// Плеер изменил воспроизводимый файл
    func playerCurrentItemDidChange(player: Player)
    /// Плеер изменил прогресс воспроизведения
    func playerPlaybackProgressDidChange(player: Player)
    
}