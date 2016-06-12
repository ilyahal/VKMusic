//
//  Player.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

final class Player: NSObject {
    
    /// Системный плеер
    var player: AVPlayer?
    /// Наблюдатель за изменениями о прогрессе воспроизведения
    var progressObserver: AnyObject!
    /// Идентификатор задачи в фоне
    var backgroundIdentifier = UIBackgroundTaskInvalid
    
    /// Делегат плеера
    weak var delegate: PlayerDelegate?
    
    /// Индекс воспроизводимого трека
    var playIndex = 0
    /// Очередь на воспроизведение
    var queuedItems = [PlayerItem]()
    /// Состояние плеера
    var state = PlayerState.Ready {
        didSet {
            if oldValue != state {
                delegate?.playerStateDidChange(self)
            }
        }
    }
    
    
    /// Текущий элемент плеера
    var currentItem : PlayerItem? {
        guard playIndex >= 0 && playIndex < queuedItems.count else {
            return nil
        }
        
        return queuedItems[playIndex]
    }
    
    /// Доступно ли воспроизведение
    var playerOperational: Bool {
        return player != nil && currentItem != nil
    }
    
    
    init(delegate: PlayerDelegate? = nil) {
        self.delegate = delegate
        
        super.init()
        
        configureObservers()
        configureAudioSession()
        
        // Подписываем приложение на получение событий удаленного контроля
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Воспроизведение
    
    /// Обновление инфо-центра "Воспроизводится сейчас"
    func updateInfoCenter() {
        guard let item = currentItem else {
            return
        }
        
        let title = item.title ?? item.URL.lastPathComponent!
        let currentTime = item.currentTime ?? 0
        let duration = item.duration ?? 0
        let trackNumber = self.playIndex
        let trackCount = self.queuedItems.count
        
        var nowPlayingInfo: [String : AnyObject] = [
            MPMediaItemPropertyPlaybackDuration : duration,
            MPMediaItemPropertyTitle : title,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : currentTime,
            MPNowPlayingInfoPropertyPlaybackQueueCount : trackCount,
            MPNowPlayingInfoPropertyPlaybackQueueIndex : trackNumber,
            MPMediaItemPropertyMediaType : MPMediaType.Music.rawValue,
            /**/MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: UIImage(named: "placeholder-Player")!)
        ]
        
        if let artist = item.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        
//        if let artwork = currentItem?.artwork {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: artwork)
//        }
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    /// Начать воспроизведение нового элемента системного плеера
    func startNewPlayerForItem(item: AVPlayerItem) {
        
        // Отменяем воспроизведение прошлой аудиозаписи
        stopProgressTimer()
        player?.pause()
        player = nil
        
        // Начинаем воспроизведение новой аудиозаписи
        player = AVPlayer(playerItem: item)
        player!.allowsExternalPlayback = false // Внешнее воспроизведение недоступно
        startProgressTimer()
        
        seekToSecond(0, shouldPlay: true)
        
        updateInfoCenter()
    }
    
    /// Продолжить воспроизведение
    func resumePlayback() {
        if state != .Playing {
            if let player = player {
                startProgressTimer()
                
                player.play()
                
                state = .Playing
                updateInfoCenter()
            } else {
                startNewPlayerForItem(currentItem!.playerItem!)
            }
        }
    }
    
    
    // MARK: Работа с элементами плеера
    
    /// Сохранение аудиозаписей в очередь
    func assignQueuedItems(items: [PlayerItem]) {
        queuedItems = items
        
        for item in queuedItems {
            item.delegate = self
        }
    }
    
    
    // MARK: Отслеживание прогресса
    
    /// Начать наблюдение за временем воспроизведения
    func startProgressTimer() {
        guard let player = player where player.currentItem?.duration.isValid == true else {
            return
        }
        
        progressObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.25, Int32(NSEC_PER_SEC)), queue: nil) { [unowned self] time in
            self.timerAction()
        }
    }
    
    /// Прекратить наблюдение за временем воспроизведения
    func stopProgressTimer() {
        guard let player = player, let progressObserver = progressObserver else {
            return
        }
        
        player.removeTimeObserver(progressObserver)
        self.progressObserver = nil
    }
    
    
    // MARK: Настройки
    
    /// Настройка аудио-сессии
    func configureAudioSession() {
        do {
            // Установка категории аудио-сессии - воспроизведение музыки (чтобы приложение позволяло воспроизводить музыку в фоне, необходимо добавить значение "audio" для ключа UIBackgroundModes на странице настроек приложения)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            // Активирует аудио-сессию
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fatalError("Could not open the audio session, hence Player is unusable!")
        }
    }
    
    /// Создание фоновой задачи воспроизведения аудиозаписи
    private func configureBackgroundAudioTask() {
        backgroundIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundIdentifier)
            self.backgroundIdentifier = UIBackgroundTaskInvalid
        }
    }
    
    /// Настройка слушателей уведомлений
    func configureObservers() {
        
        // Подписка на уведомление о том, что часть медиа-файла не успела загрузиться из сети, чтобы быть воспроизведенной
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleStall), name: AVPlayerItemPlaybackStalledNotification, object: nil)
    }
    
    
    // MARK: Работа с уведомлениями
    
    /// Обработка уведомления о том, что часть медиа-файла не успела загрузиться из сети, чтобы быть воспроизведенной
    func handleStall() {
        player?.pause()
        player?.play()
    }
    
    /// Обновление значений времени для воспроизводимого элемента
    func timerAction() {
        guard let _ = player?.currentItem, let _ = currentItem?.currentTime else {
            return
        }
        
        delegate?.playerPlaybackProgressDidChange(self)
    }
    
    /// Подписка на уведомление об окончании воспроизведения элемента системного плеера для указанного элемента системного плеера
    private func registerForPlayToEndNotification(withItem item: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
    }
    
    /// Обработка уведомления о том, что воспроизводимый элемент системного плеера закончился
    func playerItemDidPlayToEnd() {
        unregisterForPlayToEndNotification(withItem: currentItem!.playerItem!)
        
        /// Если это был последний элемент в очереди на воспроизведение
        if playIndex >= queuedItems.count - 1 {
            stop()
        } else {
            playAtIndex(playIndex + 1)
        }
    }
    
    /// Отписка от уведомлений об окончании воспроизведения элемента системного плеера для указанного элемента системного плеера
    func unregisterForPlayToEndNotification(withItem item: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
    }
    
}


// MARK: PlayerItemDelegate

extension Player: PlayerItemDelegate { }


// MARK: Публичные методы

extension Player {
    
    /// Начать воспроизведение
    func play() {
        playAtIndex(playIndex)
    }
    
    /// Воспроизвести элемент плеера по указанному индексу
    func playAtIndex(index: Int) {
        guard index >= 0 && index < queuedItems.count else {
            return
        }
        
        configureBackgroundAudioTask()
        
        if let _ = queuedItems[index].playerItem where playIndex == index {
            if PlayerManager.sharedInstance.isPauseActive {
                resumePlayback()
            } else {
                seekToSecond(0, shouldPlay: true)
                updateInfoCenter()
            }
        } else {
            if let playerItem = currentItem?.playerItem {
                unregisterForPlayToEndNotification(withItem: playerItem)
            }
            
            playIndex = index
            
            let playerItem = currentItem!.getPlayerItem()
            
            registerForPlayToEndNotification(withItem: playerItem)
            startNewPlayerForItem(playerItem)
            
            delegate?.playerCurrentItemDidChange(self)
        }
    }
    
    /// Поставить воспроизведение на паузу
    func pause() {
        stopProgressTimer()
        
        player?.pause()
        state = .Paused
    }
    
    /// Остановить воспроизведение
    func stop() {
        stopProgressTimer()
        if let playerItem = currentItem?.playerItem {
            unregisterForPlayToEndNotification(withItem: playerItem)
        }
        
        player?.pause()
        player = nil
        
        playIndex = 0
        
        UIApplication.sharedApplication().endBackgroundTask(backgroundIdentifier)
        backgroundIdentifier = UIBackgroundTaskInvalid
        
        state = .Ready
    }
    
    /// Очистить все данные плеера
    func clear() {
        stop()
        
        queuedItems.removeAll()
    }
    
    /// Начать воспроизведение с начала очереди
    func replay(){
        guard playerOperational else {
            return
        }
        
        stopProgressTimer()
        seekToSecond(0)
        playAtIndex(0)
    }
    
    /// Начать воспроизведение следующего элемента плеера
    func playNext() {
        guard playerOperational else {
            return
        }
        
        if playIndex + 1 >= queuedItems.count {
            replayCurrentItem()
        }
        
        playAtIndex(playIndex + 1)
    }
    
    /// Воспроизвести предыдущий элемент плеера
    func playPrevious() {
        guard playerOperational else {
            return
        }
        
        if playIndex - 1 < 0 {
            replayCurrentItem()
        }
        
        playAtIndex(playIndex - 1)
    }
    
    /// Воспроизвести заново текущий элемент плеера
    func replayCurrentItem() {
        guard playerOperational else {
            return
        }
        
        seekToSecond(0, shouldPlay: true)
    }
    
    /// Перемотать элемент плеера на указанную секунду
    func seekToSecond(second: Int, shouldPlay: Bool = false) {
        guard let player = player, let _ = currentItem else {
            return
        }
        
        player.seekToTime(CMTimeMake(Int64(second), 1))
        
        if shouldPlay {
            player.play()
            
            startProgressTimer()
            state = .Playing
        }
        
        updateInfoCenter()
        
        delegate?.playerPlaybackProgressDidChange(self)
    }
    
    /// Добавить элемент плеера в очередь на воспроизведение
    func appendItem(item: PlayerItem) {
        queuedItems.append(item)
        item.delegate = self
    }
    
    /// Удалить элемент плеера из очереди на воспроизведение
    func removeItem(item: PlayerItem) {
        if let index = queuedItems.indexOf({ $0.identifier == item.identifier }) {
            queuedItems.removeAtIndex(index)
        }
    }
    
    /// Удалить все элементы плеера с указанным URL
    func removeItems(withURL url: NSURL) {
        let indexes = queuedItems.indexesOf({ $0.URL == url })
        for index in indexes {
            queuedItems.removeAtIndex(index)
        }
    }
    
}