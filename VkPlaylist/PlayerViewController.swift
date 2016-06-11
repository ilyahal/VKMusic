//
//  PlayerViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 05.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import Darwin
import MediaPlayer

/// Контроллер с полноэкранным плеером
class PlayerViewController: UIViewController {
    
    /// Основной цвет приложения
    let tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
    

    /// Обложка аудиозаписи на заднем фоне
    @IBOutlet weak var backgroundArtworkImageView: UIImageView!
    
    /// Область для закрытия контроллера
    @IBOutlet weak var closeAreaButton: UIButton!
    /// Элемент содержащий кнопку "Закрыть"
    @IBOutlet weak var closeView: UIView!
    /// Элемент содержащий размытый задний фон для кнопки "Закрыть"
    @IBOutlet weak var closeButtonBackgroundBlurEffectView: UIVisualEffectView!
    /// Кнопка "Закрыть"
    @IBOutlet weak var closeButton: UIButton!
    
    /// Обложка альбома
    @IBOutlet weak var artworkImageView: UIImageView!
    /// Кнопка над обложкой альбома
    @IBOutlet weak var artworkButton: UIButton!
    
    /// Элемент содержащий размытый фон и слова аудиозаписи
    @IBOutlet weak var lyricsView: UIView!
    /// Элемент с эффектом размытия для заднего фона элемента с текстом аудиозаписи
    @IBOutlet weak var lyricsBackgroundBlurEffectView: UIVisualEffectView!
    /// Элемент с текстом аудиозаписи
    @IBOutlet weak var lyricsTextView: UITextView!
    
    /// Элемент в котором находятся слайдер, бар прогресса буфферизации и метки со временем
    @IBOutlet weak var sliderView: UIView!
    /// Бар с уровнем буфферизации
    @IBOutlet weak var bufferingProgressView: UIProgressView!
    /// Слайдер с аудиозаписью
    @IBOutlet weak var trackSlider: UISlider!
    /// Constraint верхнего отступа для слайдера аудиозаписи
    @IBOutlet weak var topSpaceTrackSlider: NSLayoutConstraint!
    /// Надпись "Прошедшее время от начала аудиозаписи"
    @IBOutlet weak var currentTimeLabel: UILabel!
    /// Надпись "Оставшееся время до конца аудиозаписи"
    @IBOutlet weak var leftTimeLabel: UILabel!
    
    /// Элемент в котором находятся надписи с названием аудиозаписи и именем исполнителя
    @IBOutlet weak var titleAndArtistView: UIView!
    /// Надпись "Название аудиозаписи"
    @IBOutlet weak var titleLabel: UILabel!
    /// Надпись "Имя исполнителя"
    @IBOutlet weak var artistLabel: UILabel!
    
    /// Кнопка "Скачать"
    @IBOutlet weak var downloadButton: UIButton!
    /// Кнопка "Предыдущая аудиозапись"
    @IBOutlet weak var previousTrackButton: UIButton!
    /// Кнопка "Play" или "Пауза"
    @IBOutlet weak var playOrPauseButton: UIButton!
    /// Кнопка "Следующая аудиозапись"
    @IBOutlet weak var nextTrackButton: UIButton!
    /// Кнопка "Текущий плейлист"
    @IBOutlet weak var currentPlaylistButton: UIButton!
    
    /// Элемент содержащий слайдер управления звуком и иконки
    @IBOutlet weak var volumeView: UIView!
    /// Элемент содержащий слайдер управления звуком
    @IBOutlet weak var volumeSliderView: UIView!
    /// Иконка "Минимальный звук"
    @IBOutlet weak var muteVolumeImageView: UIImageView!
    /// Иконка "Максимальный звук"
    @IBOutlet weak var loudlyVolumeImageView: UIImageView!
    
    /// Элемент содержащий кнопку "Отобразить в статусе"
    @IBOutlet weak var shareToStatusView: UIView!
    /// Элемент для активного состояния кнопки "Отобразить в статусе"
    @IBOutlet weak var shareToStatusActiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить в статусе" для активного состояния
    @IBOutlet weak var shareToStatusActiveStateButton: UIButton!
    /// Элемент для неактивного состояния кнопки "Отобразить в статусе"
    @IBOutlet weak var shareToStatusInactiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить в статусе" для неактивного состояния
    @IBOutlet weak var shareToStatusInactiveStateButton: UIButton!
    /// Элемент содержащий кнопку "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsButtonView: UIView!
    /// Элемент для активного состояния кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsActiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить слова аудиозаписи" для активного состояния
    @IBOutlet weak var lyricsActiveStateButton: UIButton!
    /// Элемент для неактивного состояния кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsInactiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить слова аудиозаписи" для неактивного состояния
    @IBOutlet weak var lyricsInactiveStateButton: UIButton!
    /// Активная область вокруг кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsButtonArea: UIButton!
    /// Элемент содержащий кнопку "Перемешать"
    @IBOutlet weak var shuffleView: UIView!
    /// Элемент для активного состояния кнопки "Перемешать"
    @IBOutlet weak var shuffleActiveStateView: UIVisualEffectView!
    /// Кнопка "Перемешать" для активного состояния
    @IBOutlet weak var shuffleActiveStateButton: UIButton!
    /// Элемент для неактивного состояния кнопки "Перемешать"
    @IBOutlet weak var shuffleInactiveStateView: UIVisualEffectView!
    /// Кнопка "Перемешать" для неактивного состояния
    @IBOutlet weak var shuffleInactiveStateButton: UIButton!
    /// Элемент содержащий кнопку "Повторить"
    @IBOutlet weak var repeatView: UIView!
    /// Элемент для активного состояния кнопки "Повторить"
    @IBOutlet weak var repeatActiveStateView: UIVisualEffectView!
    /// Кнопка "Повторить" для активного состояния
    @IBOutlet weak var repeatActiveStateButton: UIButton!
    /// Элемент для неактивного состояния кнопки "Повторить"
    @IBOutlet weak var repeatInactiveStateView: UIVisualEffectView!
    /// Кнопка "Повторить" для неактивного состояния
    @IBOutlet weak var repeatInactiveStateButton: UIButton!
    /// Кнопка "Еще"
    @IBOutlet weak var moreButton: UIButton!
    
    
    /// Показывать ли слова аудиозаписи
    var isShowLyrics = false
    /// Воспроизводится ли аудиозапись
    var isPlaying: Bool {
        get {
            return PlayerManager.sharedInstance.isPlaying
        }
    }
    /// Отображать ли музыку в статусе
    var isShareToStatus: Bool {
        set {
            PlayerManager.sharedInstance.isShareToStatus = newValue
        }
        get {
            return PlayerManager.sharedInstance.isShareToStatus
        }
    }
    /// Перемешать ли плейлист
    var isShuffle: Bool {
        set {
            PlayerManager.sharedInstance.isShuffle = newValue
        }
        get {
            return PlayerManager.sharedInstance.isShuffle
        }
    }
    /// Тип перемешивания
    var repeatType: PlayerRepeatType {
        set {
            PlayerManager.sharedInstance.repeatType = newValue
        }
        get {
            return PlayerManager.sharedInstance.repeatType
        }
    }
    
    /// Распознатель тапов по текстовому полю
    var lyricsTapRecognizer: UITapGestureRecognizer!
    /// Иконка "Скачать"
    var downloadIcon = UIImage(named: "icon-PlayerDownload")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Предыдущая аудиозапись"
    var previousTrackIcon = UIImage(named: "icon-PlayerPreviousTrack")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Play" / "Пауза"
    var playOrPauseIcon: UIImage {
        return UIImage(named: isPlaying ? "icon-PlayerPause" : "icon-PlayerPlay")!.tintPicto(UIColor.whiteColor())
    }
    /// Иконка "Следующая аудиозапись"
    var nextTrackIcon = UIImage(named: "icon-PlayerNextTrack")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Текущий плейлист"
    var currentPlaylistIcon = UIImage(named: "icon-PlayerCurrentPlaylist")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Без звука"
    var volumeMuteIcon = UIImage(named: "icon-PlayerVolumeMute")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Громкий звук"
    var volumeLoudlyIcon = UIImage(named: "icon-PlayerVolumeLoudly")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Отобразить в статус"
    var shareToStatusIcon = UIImage(named: "icon-PlayerShareToStatus")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Отобразить слова аудиозаписи"
    var lyricsIcon = UIImage(named: "icon-PlayerLyrics")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Перемешать"
    var shuffleIcon = UIImage(named: "icon-PlayerShuffle")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Повторить" для активного состояния
    var repeatActiveIcon: UIImage {
        return UIImage(named: repeatType == .One ? "icon-PlayerRepeatOne" : "icon-PlayerRepeat")!.tintPicto(UIColor.whiteColor())
    }
    /// Иконка для кнопки "Перемешать" для неактивного состояния
    var repeatInactiveIcon = UIImage(named: "icon-PlayerRepeat")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Еще"
    var moreIcon = UIImage(named: "icon-More")!.tintPicto(UIColor.whiteColor())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlayerManager.sharedInstance.addDelegate(self)
        
        /// Настройка кнопки "Закрыть"
        closeView.layer.cornerRadius = closeView.bounds.size.height / 2
        closeView.layer.masksToBounds = true
        closeButton.setImage(UIImage(named: "icon-PlayerClose")!.tintPicto(UIColor.whiteColor()), forState: .Normal)

        // Инициализация распознавателя тапов по элементу с текстом аудиозаписи
        lyricsTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(lyricsTapped))
        lyricsTapRecognizer.delegate = self
        
        // Настройка отображения слов аудиозаписи
        lyricsView.hidden = true
        lyricsView.alpha = 0
        
        // Заполняем пустое слева от слайдера
        let leftSliderSubview = UIView(frame: CGRectMake(0, 0, 3, 2))
        leftSliderSubview.backgroundColor = tintColor
        sliderView.insertSubview(leftSliderSubview, belowSubview: bufferingProgressView)
        
        // Заполняем пустое справа от слайдера
        let rightSliderSubview = UIView(frame: CGRectMake(view.bounds.size.width - 3, 0, 3, 2))
        rightSliderSubview.backgroundColor = UIColor.lightGrayColor()
        sliderView.insertSubview(rightSliderSubview, belowSubview: bufferingProgressView)
        
        // Настройка бара отображающего прогресс буфферизации
        bufferingProgressView.setProgress(0, animated: false)
        bufferingProgressView.progressTintColor = tintColor.colorWithAlphaComponent(0.4)
        bufferingProgressView.trackTintColor = UIColor.lightGrayColor()
        
        // Настройка слайдера с аудиозаписью
        trackSlider.setValue(PlayerManager.sharedInstance.progress, animated: false)
        trackSlider.minimumTrackTintColor = tintColor
        trackSlider.maximumTrackTintColor = UIColor.clearColor()
        trackSlider.setThumbImage(UIImage(named: "icon-PlayerThumbTrack")!.tintPicto(UIColor.whiteColor()), forState: .Normal)
        topSpaceTrackSlider.constant = -9
        
        // Настройка надписей со временм
        currentTimeLabel.text = nil
        currentTimeLabel.textColor = UIColor.whiteColor()
        leftTimeLabel.text = nil
        leftTimeLabel.textColor = UIColor.whiteColor()
        
        // Настройка надписи с названием аудиозаписи
        titleLabel.text = PlayerManager.sharedInstance.trackTitle
        titleLabel.textColor = UIColor.whiteColor()
        
        // Настройка надписи с именем исполнителя
        artistLabel.text = PlayerManager.sharedInstance.artist
        artistLabel.textColor = UIColor.whiteColor()
        
        // Настройка кнопки "Скачать"
        downloadButton.enabled = !PlayerManager.sharedInstance.player.currentItem!.isDownloaded
        downloadButton.setImage(downloadIcon, forState: .Normal)
        
        // Настройка кнопки "Предыдущая аудиозапись"
        previousTrackButton.setImage(previousTrackIcon, forState: .Normal)
        
        // Настройка кнопки "Play" / "Пауза"
        playOrPauseButton.setImage(playOrPauseIcon, forState: .Normal)
        
        // Настройка кнопки "Следующая аудиозапись"
        nextTrackButton.setImage(nextTrackIcon, forState: .Normal)
        
        // Настройка кнопки "Текущий плейлист"
        currentPlaylistButton.setImage(currentPlaylistIcon, forState: .Normal)
        
        // Настройка слайдера со звуком
        let MPVolumeSlider = MPVolumeView(frame: CGRectMake(0, 6, view.bounds.size.width * 0.8, 31))
        MPVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        volumeSliderView.addSubview(MPVolumeSlider)
//        NSLayoutConstraint(item: MPVolumeSlider, attribute: .Leading, relatedBy: .Equal, toItem: volumeSliderView, attribute: .Leading, multiplier: 1, constant: 0).active = true
//        NSLayoutConstraint(item: MPVolumeSlider, attribute: .Trailing, relatedBy: .Equal, toItem: volumeSliderView, attribute: .Trailing, multiplier: 1, constant: 0).active = true
//        NSLayoutConstraint(item: MPVolumeSlider, attribute: .CenterY, relatedBy: .Equal, toItem: volumeSliderView, attribute: .CenterY, multiplier: 1, constant: -5).active = true
        MPVolumeSlider.setVolumeThumbImage(UIImage(named: "icon-PlayerThumbVolume")!.tintPicto(UIColor.whiteColor()), forState: .Normal)
        muteVolumeImageView.image = volumeMuteIcon
        loudlyVolumeImageView.image = volumeLoudlyIcon
        
        // Настройка кнопки "Отобразить в статусе"
        shareToStatusView.layer.cornerRadius = 3
        shareToStatusView.layer.masksToBounds = true
        shareToStatusActiveStateButton.setImage(shareToStatusIcon, forState: .Normal)
        shareToStatusInactiveStateButton.setImage(shareToStatusIcon, forState: .Normal)
        configureShareToStatusButton()
        
        // Настройка кнопки "Отобразить слова аудиозаписи"
        lyricsButtonView.layer.cornerRadius = 3
        lyricsButtonView.layer.masksToBounds = true
        lyricsActiveStateButton.setImage(lyricsIcon, forState: .Normal)
        lyricsInactiveStateButton.setImage(lyricsIcon, forState: .Normal)
        configureLyricsButton()
        
        // Настройка кнопки "Перемешать"
        shuffleView.layer.cornerRadius = 3
        shuffleView.layer.masksToBounds = true
        shuffleActiveStateButton.setImage(shuffleIcon, forState: .Normal)
        shuffleInactiveStateButton.setImage(shuffleIcon, forState: .Normal)
        configureShuffleButton()
        
        // Настройка кнопки "Повторить"
        repeatView.layer.cornerRadius = 3
        repeatView.layer.masksToBounds = true
        repeatInactiveStateButton.setImage(repeatInactiveIcon, forState: .Normal)
        configureRepeatButton()
        
        // Настройка кнопки "Еще"
        moreButton.setImage(moreIcon, forState: .Normal)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        PlayerManager.sharedInstance.deleteDelegate(self)
    }
    
    
    // MARK: Помощники
    
    /// Настройка отображения слов аудиозаписи
    func configureLyricsAppear() {
        if isShowLyrics {
            lyricsTextView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false) // Пролистываем текст до верха
            
            lyricsView.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                self.lyricsView.alpha = 1
            }, completion: { _ in
                self.lyricsTextView.addGestureRecognizer(self.lyricsTapRecognizer)
                self.lyricsButtonArea.enabled = true
            })
        } else {
            lyricsTextView.removeGestureRecognizer(lyricsTapRecognizer)
            
            UIView.animateWithDuration(0.5, animations: {
                self.lyricsView.alpha = 0
            }, completion: { _ in
                self.lyricsView.hidden = true
                
                self.artworkButton.enabled = true
                self.lyricsButtonArea.enabled = true
            })
        }
    }
    
    /// Настройка кнопки "Отобразить в статусе" для текущего состояния
    func configureShareToStatusButton() {
        shareToStatusActiveStateView.hidden = !isShareToStatus
        shareToStatusInactiveStateView.hidden = isShareToStatus
    }
    
    /// Настройка кнопки "Отобразить слова аудиозаписи"
    func configureLyricsButton() {
        lyricsActiveStateView.hidden = !isShowLyrics
        lyricsInactiveStateView.hidden = isShowLyrics
    }
    
    /// Настройка кнопки "Перемешать" для текущего состояния
    func configureShuffleButton() {
        shuffleActiveStateView.hidden = !isShuffle
        shuffleInactiveStateView.hidden = isShuffle
    }
    
    /// Переключение типа повторения
    func nextRepeatType() {
        switch repeatType {
        case .No:
            repeatType = .All
        case .All:
            repeatType = .One
        case .One:
            repeatType = .No
        }
    }
    
    /// Настройка кнопки "Повторить"
    func configureRepeatButton() {
        switch repeatType {
        case .No:
            repeatActiveStateView.hidden = true
            repeatInactiveStateView.hidden = false
        case .All, .One:
            repeatInactiveStateView.hidden = true
            repeatActiveStateView.hidden = false
            
            repeatActiveStateButton.setImage(repeatActiveIcon, forState: .Normal)
        }
    }
    
    
    // MARK: Обработка пользовательских действий
    
    /// Кнопка "Закрыть" была нажата
    @IBAction func closeButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// По кнопке над обложкой был тап
    @IBAction func artworkTapped(sender: UIButton) {
        isShowLyrics = !isShowLyrics
        
        configureLyricsAppear()
        configureLyricsButton()
    }
    
    /// По элементу со словами аудиозаписи был тап
    func lyricsTapped() {
        isShowLyrics = !isShowLyrics
        
        configureLyricsAppear()
        configureLyricsButton()
    }
    
    /// Кнопка "Скачать" была нажата
    @IBAction func downloadButtonTapped(sender: UIButton) {
        downloadButton.enabled = false
    }
    
    /// Слайдер с аудиозаписью начали тащить
    @IBAction func trackSliderEditingDidBegin(sender: UISlider) {
        PlayerManager.sharedInstance.sliderEditingDidBegin()
    }
    
    /// Значение слайдера с аудиозаписью изменилось
    @IBAction func trackSliderValueChanged(sender: UISlider) {
        
    }
    
    /// Слайдер с аудиозаписью прекратили тащить
    @IBAction func trackSliderEditingDidEnd(sender: UISlider) {
        let duration = PlayerManager.sharedInstance.duration
        
        var currentTime = floor(Double((Float(duration) * sender.value)))
        if currentTime <= 0 {
            currentTime = 0
        }
        
        PlayerManager.sharedInstance.sliderEditingDidEndWithSecond(Int(currentTime))
    }
    
    /// Кнопка "Предыдущая аудиозапись" была нажат
    @IBAction func previousTrackTapped(sender: UIButton) {
        PlayerManager.sharedInstance.previousTapped()
    }
    
    /// Кнопка "Play" или "Пауза" была нажата
    @IBAction func playOrPauseButtonTapped(sender: UIButton) {
        if isPlaying {
            PlayerManager.sharedInstance.pauseTapped()
        } else {
            PlayerManager.sharedInstance.playTapped()
        }
    }
    
    /// Кнопка "Следующая аудиозапись" была нажат
    @IBAction func nextTrackTapped(sender: UIButton) {
        PlayerManager.sharedInstance.nextTapped()
    }
    
    /// Кнопка "Отобразить в статусе" была нажата
    @IBAction func shareToStatusButtonTapped(sender: UIButton) {
        if isShareToStatus {
            isShareToStatus = false
            configureShareToStatusButton()
        } else {
            let alertController = UIAlertController(title: nil, message: "Проигрываемая музыка будет транслироваться в Ваш статус на сайте vk.com!", preferredStyle: .ActionSheet)
            
            let continueAction = UIAlertAction(title: "Продолжить", style: .Default) { _ in
                self.isShareToStatus = true
                self.configureShareToStatusButton()
            }
            alertController.addAction(continueAction)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /// Кнопка "Отобразить слова аудиозаписи" была нажата
    @IBAction func lyricsButtonTapped(sender: UIButton) {
        sender.enabled = false
        isShowLyrics = !isShowLyrics
        
        configureLyricsAppear()
        configureLyricsButton()
    }
    
    /// Кнопка "Перемешать" была нажата
    @IBAction func shuffleButtonTapped(sender: UIButton) {
        isShuffle = !isShuffle
        configureShuffleButton()
    }
    
    /// Кнопка "Повторить" была нажата
    @IBAction func repeatButtonTapped(sender: UIButton) {
        nextRepeatType()
        configureRepeatButton()
    }
    
    /// Кнопка "Еще" была нажата
    @IBAction func moreButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let addToPlaylistOrAlbumAction = UIAlertAction(title: "Добавить в плейлист", style: .Default, handler: nil)
        alertController.addAction(addToPlaylistOrAlbumAction)
        
        let editArtwork = UIAlertAction(title: "Изменить обложку", style: .Default, handler: nil)
        alertController.addAction(editArtwork)
        
        let removeAction = UIAlertAction(title: "Удалить", style: .Destructive, handler: nil)
        alertController.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


// MARK: UIGestureRecognizerDelegate

extension PlayerViewController: UIGestureRecognizerDelegate {
    
    // Спрашивает делегат позволения если два распознавателя жестов хотят распознавать жесты одновременно
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


// MARK: PlayerManagerDelegate

extension PlayerViewController: PlayerManagerDelegate {
    
    // Менеджер плеера получил новое состояние плеера
    func playerManagerGetNewState(state: PlayerState) {
        switch state {
        case .Ready:
            dismissViewControllerAnimated(true, completion: nil)
        case .Paused, .Playing:
            playOrPauseButton.setImage(playOrPauseIcon, forState: .Normal)
        }
    }
    
    // Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem(item: PlayerItem) {
        titleLabel.text = item.title
        artistLabel.text = item.artist
    }
    
    // Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewTimerProgress(progress: Float) {
        trackSlider.setValue(progress, animated: false)
    }
    
}
