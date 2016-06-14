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
    @IBOutlet weak var volumeSliderView: MPVolumeView!
    /// Иконка "Минимальный звук"
    @IBOutlet weak var muteVolumeImageView: UIImageView!
    /// Иконка "Максимальный звук"
    @IBOutlet weak var loudlyVolumeImageView: UIImageView!
    
    /// Элемент содержащий кнопку "Отобразить в статусе"
    @IBOutlet weak var shareToStatusView: UIView!
    /// Элемент для активного состояния кнопки "Отобразить в статусе"
    @IBOutlet weak var shareToStatusActiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить в статусе" для активного состояния
    @IBOutlet weak var shareToStatusActiveStateIconImageView: UIImageView!
    /// Элемент для неактивного состояния кнопки "Отобразить в статусе"
    @IBOutlet weak var shareToStatusInactiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить в статусе" для неактивного состояния
    @IBOutlet weak var shareToStatusInactiveStateIconImageView: UIImageView!
    /// Элемент содержащий кнопку "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsButtonView: UIView!
    /// Элемент для активного состояния кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsActiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить слова аудиозаписи" для активного состояния
    @IBOutlet weak var lyricsActiveStateIconImageView: UIImageView!
    /// Элемент для неактивного состояния кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsInactiveStateView: UIVisualEffectView!
    /// Кнопка "Отобразить слова аудиозаписи" для неактивного состояния
    @IBOutlet weak var lyricsInactiveStateIconImageView: UIImageView!
    /// Активная область вокруг кнопки "Отобразить слова аудиозаписи"
    @IBOutlet weak var lyricsButtonArea: UIButton!
    /// Элемент содержащий кнопку "Перемешать"
    @IBOutlet weak var shuffleView: UIView!
    /// Элемент для активного состояния кнопки "Перемешать"
    @IBOutlet weak var shuffleActiveStateView: UIVisualEffectView!
    /// Кнопка "Перемешать" для активного состояния
    @IBOutlet weak var shuffleActiveStateIconImageView: UIImageView!
    /// Элемент для неактивного состояния кнопки "Перемешать"
    @IBOutlet weak var shuffleInactiveStateView: UIVisualEffectView!
    /// Кнопка "Перемешать" для неактивного состояния
    @IBOutlet weak var shuffleInactiveStateIconImageView: UIImageView!
    /// Элемент содержащий кнопку "Повторить"
    @IBOutlet weak var repeatView: UIView!
    /// Элемент для активного состояния кнопки "Повторить"
    @IBOutlet weak var repeatActiveStateView: UIVisualEffectView!
    /// Кнопка "Повторить" для активного состояния
    @IBOutlet weak var repeatActiveStateIconImageView: UIImageView!
    /// Элемент для неактивного состояния кнопки "Повторить"
    @IBOutlet weak var repeatInactiveStateView: UIVisualEffectView!
    /// Кнопка "Повторить" для неактивного состояния
    @IBOutlet weak var repeatInactiveStateIconImageView: UIImageView!
    /// Кнопка "Еще"
    @IBOutlet weak var moreIconImageView: UIImageView!
    
    
    /// Распознатель тапов по текстовому полю
    var lyricsTapRecognizer: UITapGestureRecognizer!
    /// Иконка "Скачать"
    let downloadIcon = UIImage(named: "icon-PlayerDownload")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Предыдущая аудиозапись"
    let previousTrackIcon = UIImage(named: "icon-PlayerPreviousTrack")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Play"
    let playIcon = UIImage(named: "icon-PlayerPlay")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Пауза"
    let pauseIcon = UIImage(named: "icon-PlayerPause")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Play" / "Пауза"
    var playOrPauseIcon: UIImage {
        return isPlaying ? pauseIcon : playIcon
    }
    /// Иконка "Следующая аудиозапись"
    let nextTrackIcon = UIImage(named: "icon-PlayerNextTrack")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Текущий плейлист"
    let currentPlaylistIcon = UIImage(named: "icon-PlayerCurrentPlaylist")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Без звука"
    let volumeMuteIcon = UIImage(named: "icon-PlayerVolumeMute")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Громкий звук"
    let volumeLoudlyIcon = UIImage(named: "icon-PlayerVolumeLoudly")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Отобразить в статус"
    let shareToStatusIcon = UIImage(named: "icon-PlayerShareToStatus")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Отобразить слова аудиозаписи"
    let lyricsIcon = UIImage(named: "icon-PlayerLyrics")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Перемешать"
    let shuffleIcon = UIImage(named: "icon-PlayerShuffle")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Повторить"
    let repeatIcon = UIImage(named: "icon-PlayerRepeat")!.tintPicto(UIColor.whiteColor())
    /// Иконка "Повторить одну"
    let repeatOneIcon = UIImage(named: "icon-PlayerRepeatOne")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Повторить" для активного состояния
    var repeatActiveIcon: UIImage {
        return repeatType == .One ? repeatOneIcon : repeatIcon
    }
    /// Иконка для кнопки "Перемешать" для неактивного состояния
    let repeatInactiveIcon = UIImage(named: "icon-PlayerRepeat")!.tintPicto(UIColor.whiteColor())
    /// Иконка для кнопки "Еще"
    let moreIcon = UIImage(named: "icon-More")!.tintPicto(UIColor.whiteColor())
    
    
    /// Состояние плеера
    var state: PlayerState {
        return PlayerManager.sharedInstance.state
    }
    
    /// Прогресс воспроизведения текущей аудиозаписи
    var progress: Float {
        return PlayerManager.sharedInstance.progress
    }
    /// Длина текущей аудиозаписи
    var duration: Double {
        return PlayerManager.sharedInstance.duration
    }
    /// Текущее время воспроизведения текущей аудиозаписи
    var currentTime: Double {
        return PlayerManager.sharedInstance.currentTime
    }
    /// Времени осталось до конца аудиозаписи
    var leftTime: Double {
        let leftTime = duration - currentTime
        
        return leftTime < 0 ? 0 : leftTime
    }
    /// Название исполняемой аудиозаписи
    var trackTitle: String? {
        return PlayerManager.sharedInstance.trackTitle
    }
    /// Имя исполнителя аудиозаписи
    var artist: String? {
        return PlayerManager.sharedInstance.artist
    }
    
    
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
        get {
            return PlayerManager.sharedInstance.isShareToStatus
        }
    }
    /// Перемешать ли плейлист
    var isShuffle: Bool {
        get {
            return PlayerManager.sharedInstance.isShuffle
        }
    }
    /// Тип перемешивания
    var repeatType: PlayerRepeatType {
        get {
            return PlayerManager.sharedInstance.repeatType
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlayerManager.sharedInstance.addDelegate(self)
        
        configureUI()
        
        // Настройка бара отображающего прогресс буфферизации
        bufferingProgressView.setProgress(0, animated: false)
        
        // Настройка слайдера с аудиозаписью
        trackSlider.setValue(PlayerManager.sharedInstance.progress, animated: false)
        
        // Настройка надписей со временм
        currentTimeLabel.text = String.formattedTimeFromSeconds(currentTime)
        leftTimeLabel.text = "-" + String.formattedTimeFromSeconds(leftTime)
        
        // Настройка надписи с названием аудиозаписи
        titleLabel.text = PlayerManager.sharedInstance.trackTitle
        
        // Настройка надписи с именем исполнителя
        artistLabel.text = PlayerManager.sharedInstance.artist
        
        // Настройка кнопки "Скачать"
        downloadButton.hidden = true
        downloadButton.enabled = !PlayerManager.sharedInstance.player.currentItem!.isDownloaded
        
        // Настройка кнопки "Текущий плейлист"
        currentPlaylistButton.hidden = true
        
        // Настройка кнопки "Отобразить в статусе"
        configureShareToStatusButton()
        
        // Настройка кнопки "Отобразить слова аудиозаписи"
        configureLyricsButton()
        
        // Настройка кнопки "Перемешать"
        configureShuffleButton()
        
        // Настройка кнопки "Повторить"
        configureRepeatButton()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        PlayerManager.sharedInstance.deleteDelegate(self)
    }
    
    
    // MARK: UI
    
    /// Настройка интерфейса контроллера
    func configureUI() {
        
        /// Настройка кнопки "Закрыть"
        closeView.layer.cornerRadius = closeView.bounds.size.height / 2
        closeView.layer.masksToBounds = true
        closeButton.setImage(UIImage(named: "icon-PlayerClose")!.tintPicto(UIColor.whiteColor()), forState: .Normal)
        
        // Инициализация распознавателя тапов по элементу с текстом аудиозаписи
        lyricsTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(lyricsTapped))
        lyricsTapRecognizer.delegate = self
        
        // Настройка отображения  элемента со словами аудиозаписи
        lyricsView.hidden = true
        lyricsView.alpha = 0
        
        // Настройка элемента со словами
        lyricsTextView.tintColor = tintColor
        
        // Заполняем пустое слева от слайдера
        let leftSliderSubview = UIView(frame: CGRectMake(0, 0, 3, 2))
        leftSliderSubview.backgroundColor = tintColor
        sliderView.insertSubview(leftSliderSubview, belowSubview: bufferingProgressView)
        
        // Заполняем пустое справа от слайдера
        let rightSliderSubview = UIView(frame: CGRectMake(view.bounds.size.width - 3, 0, 3, 2))
        rightSliderSubview.backgroundColor = UIColor.lightGrayColor()
        sliderView.insertSubview(rightSliderSubview, belowSubview: bufferingProgressView)
    
        // Настройка бара отображающего прогресс буфферизации
        bufferingProgressView.progressTintColor = tintColor.colorWithAlphaComponent(0.4)
        bufferingProgressView.trackTintColor = UIColor.lightGrayColor()
        
        // Настройка слайдера с аудиозаписью
        trackSlider.minimumTrackTintColor = tintColor
        trackSlider.maximumTrackTintColor = UIColor.clearColor()
        trackSlider.setThumbImage(UIImage(named: "icon-PlayerThumbTrack")!.tintPicto(UIColor.whiteColor()), forState: .Normal)
        topSpaceTrackSlider.constant = -9
        
        // Настройка надписей со временм
        currentTimeLabel.textColor = UIColor.whiteColor()
        leftTimeLabel.textColor = UIColor.whiteColor()
        
        // Настройка надписи с названием аудиозаписи
        titleLabel.textColor = UIColor.whiteColor()
        
        // Настройка надписи с именем исполнителя
        artistLabel.textColor = UIColor.whiteColor()
        
        // Настройка кнопки "Скачать"
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
        volumeSliderView.setVolumeThumbImage(UIImage(named: "icon-PlayerThumbVolume")!.tintPicto(UIColor.whiteColor()), forState: .Normal)
        muteVolumeImageView.image = volumeMuteIcon
        loudlyVolumeImageView.image = volumeLoudlyIcon
        
        // Настройка кнопки "Отобразить в статусе"
        shareToStatusView.layer.cornerRadius = 3
        shareToStatusView.layer.masksToBounds = true
        shareToStatusActiveStateIconImageView.image = shareToStatusIcon
        shareToStatusInactiveStateIconImageView.image = shareToStatusIcon
        
        // Настройка кнопки "Отобразить слова аудиозаписи"
        lyricsButtonView.layer.cornerRadius = 3
        lyricsButtonView.layer.masksToBounds = true
        lyricsActiveStateIconImageView.image = lyricsIcon
        lyricsInactiveStateIconImageView.image = lyricsIcon
        
        // Настройка кнопки "Перемешать"
        shuffleView.layer.cornerRadius = 3
        shuffleView.layer.masksToBounds = true
        shuffleActiveStateIconImageView.image = shuffleIcon
        shuffleInactiveStateIconImageView.image = shuffleIcon
        
        // Настройка кнопки "Повторить"
        repeatView.layer.cornerRadius = 3
        repeatView.layer.masksToBounds = true
        repeatInactiveStateIconImageView.image = repeatInactiveIcon
        
        // Настройка кнопки "Еще"
        moreIconImageView.image = moreIcon
    }
    
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
    
    /// Настройка кнопки "Повторить"
    func configureRepeatButton() {
        switch repeatType {
        case .No:
            repeatActiveStateView.hidden = true
            repeatInactiveStateView.hidden = false
        case .All, .One:
            repeatInactiveStateView.hidden = true
            repeatActiveStateView.hidden = false
            
            repeatActiveStateIconImageView.image = repeatActiveIcon
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
    
    /// Слайдер с аудиозаписью начали тащить
    @IBAction func trackSliderBeginDragging(sender: UISlider) {
        PlayerManager.sharedInstance.sliderBeginDragging()
    }
    
    /// Значение слайдера с аудиозаписью изменилось
    @IBAction func trackSliderValueChanged(sender: UISlider) {
        let currentTime = floor(duration * Double(sender.value))
        let timeLeft = floor(duration - currentTime)
        
        currentTimeLabel.text = String.formattedTimeFromSeconds(currentTime < 0 ? 0 : currentTime)
        leftTimeLabel.text = "-" + String.formattedTimeFromSeconds(currentTime < 0 ? duration : timeLeft)
    }
    
    /// Слайдер с аудиозаписью прекратили тащить
    @IBAction func trackSliderEndDragging(sender: UISlider) {
        let currentTime = floor(duration * Double(sender.value))
        
        PlayerManager.sharedInstance.sliderEndDraggingWithSecond(Int(currentTime < 0 ? 0 : currentTime))
    }
    
    /// Кнопка "Скачать" была нажата
    @IBAction func downloadButtonTapped(sender: UIButton) {}
    
    /// Кнопка "Предыдущая аудиозапись" была нажата
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
    
    /// Кнопка "Следующая аудиозапись" была нажата
    @IBAction func nextTrackTapped(sender: UIButton) {
        PlayerManager.sharedInstance.nextTapped()
    }
    
    /// Кнопка "Скачать" была нажата
    @IBAction func currentPlaylistButtonTapped(sender: UIButton) {}
    
    /// Кнопка "Отобразить в статусе" была нажата
    @IBAction func shareToStatusButtonTapped(sender: UIButton) {
        if isShareToStatus {
            PlayerManager.sharedInstance.shareToStatusButtonTapped()
        } else {
            let alertController = UIAlertController(title: nil, message: "Проигрываемая музыка будет транслироваться в Ваш статус на сайте vk.com!", preferredStyle: .ActionSheet)
            
            let continueAction = UIAlertAction(title: "Продолжить", style: .Default) { _ in
                PlayerManager.sharedInstance.shareToStatusButtonTapped()
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
        PlayerManager.sharedInstance.shuffleButtonTapped()
    }
    
    /// Кнопка "Повторить" была нажата
    @IBAction func repeatButtonTapped(sender: UIButton) {
        PlayerManager.sharedInstance.repeatButtonTapped()
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
    func playerManagerGetNewState() {
        switch state {
        case .Ready:
            dismissViewControllerAnimated(true, completion: nil)
        case .Paused, .Playing:
            playOrPauseButton.setImage(playOrPauseIcon, forState: .Normal)
        }
    }
    
    // Менеджер плеера получил новый элемент плеера
    func playerManagerGetNewItem() {
        titleLabel.text = trackTitle
        artistLabel.text = artist
    }
    
    // Менеджер плеера получил новое значение прогресса
    func playerManagerCurrentItemGetNewProgressValue() {
        trackSlider.setValue(progress, animated: false)
    }
    
    // Менеджер плеера получил новое значение текущего времени
    func playerManagerCurrentItemGetNewCurrentTime() {
        currentTimeLabel.text = String.formattedTimeFromSeconds(currentTime)
        leftTimeLabel.text = "-" + String.formattedTimeFromSeconds(leftTime)
    }
    
    // Менеджер плеера изменил настройку "Отправлять ли музыку в статус"
    func playerManagerShareToStatusSettingDidChange() {
        configureShareToStatusButton()
    }
    
    // Менеджер плеера изменил настройку "Перемешивать ли плейлист"
    func playerManagerShuffleSettingDidChange() {
        configureShuffleButton()
    }
    
    // Менеджер плеера изменил настройку "Повторять ли плейлист"
    func playerManagerRepeatTypeDidChange() {
        configureRepeatButton()
    }
    
}
