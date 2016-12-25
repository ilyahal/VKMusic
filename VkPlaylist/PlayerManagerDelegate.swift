//
//  PlayerManagerDelegate.swift
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

import Foundation

protocol PlayerManagerDelegate: class {
    
    /// Менеджер плеера получил новое состояние плеера
    func playerManagerGetNewState()
    /// Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem()
    /// Менеджер обновил слова аудиозаписи
    func playerManagerUpdateLyrics()
    /// Менеджер получил обложку аудиозаписи
    func playerManagerGetArtwork()
    /// Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewProgressValue()
    /// Менеджер плеера получил новое значение прогресса буфферизации
    func playerManagerCurrentItemGetNewBufferingProgressValue()
    /// Менеджер плеера получил новое значение текущего времени
    func playerManagerCurrentItemGetNewCurrentTime()
    /// Менеджер плеера изменил настройку "Отправлять ли музыку в статус"
    func playerManagerShareToStatusSettingDidChange()
    /// Менеджер плеера изменил настройку "Перемешивать ли плейлист"
    func playerManagerShuffleSettingDidChange()
    /// Менеджер плеера изменил настройку "Повторять ли плейлист"
    func playerManagerRepeatTypeDidChange()
    
}