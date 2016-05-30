//
//  AddPlaylistViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import CoreData

class AddPlaylistViewController: UIViewController {
    
    var downloadsFetchedResultsController: NSFetchedResultsController {
        return DataManager.sharedInstance.downloadsFetchedResultsController
    }
    
    var downloadedTracks: [TrackInPlaylist] { // Загруженные треки
        return downloadsFetchedResultsController.sections!.first!.objects as! [TrackInPlaylist]
    }
    var downloadedCount: Int { // Количество загруженных треков
        return downloadsFetchedResultsController.sections!.first!.numberOfObjects
    }
    
    var filteredTracks = [TrackInPlaylist]() // Массив для результатов поиска по скаченным трекам
    var activeArray: [TrackInPlaylist] { // Массив аудиозаписей отображаемый на экране
        if searchController.active && searchController.searchBar.text != "" {
            return filteredTracks
        } else {
            return downloadedTracks
        }
    }
    
    var selectedTracks = [String : OfflineTrack]()

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var playlistTitleTextField: UITextField!
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Настройка table view
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Настройка клавиатуры для поля с названием плейлиста
        let doneToolBar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 40))
        doneToolBar.barStyle = .Default
        doneToolBar.tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        doneToolBar.backgroundColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        doneToolBar.setItems([flexSpace, doneButton], animated: true)
        
        playlistTitleTextField.inputAccessoryView = doneToolBar
        
        
        // Настройка поисковой панели
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        definesPresentationContext = true
        
        searchEnable(downloadedCount != 0)
        
        
        // Кастомизация tableView
        tableView.tableFooterView = UIView() // Чистим пустое пространство под таблицей
        
        
        // Регистрация ячеек
        var cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) // Ячейка "Ничего не найдено"
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.addToPlaylistCell, bundle: nil) // Ячейка с активной загрузкой
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.addToPlaylistCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.numberOfRowsCell, bundle: nil) // Ячейка с количеством строк
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.numberOfRowsCell)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataManager.sharedInstance.addDataManagerDownloadsDelegate(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.sharedInstance.deleteDataManagerDownloadsDelegate(self)
    }
    
    deinit{
        if let superView = searchController.view.superview
        {
            superView.removeFromSuperview()
        }
    }
    
    // Заново отрисовать таблицу
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func donePressed(sender: UIBarButtonItem) {
        playlistTitleTextField.resignFirstResponder()
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    // Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    var textForNoResultsRow: String {
        return "Нет загруженных треков"
    }
    
    // Получение количества треков в списке для ячейки с количеством аудиозаписей
    func getCountForCellForNumberOfOfflineAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Int? {
        if activeArray.count == indexPath.row {
            return activeArray.count
        } else {
            return nil
        }
    }
    
    // Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    
    // MARK: Получение ячеек для строк таблицы
    
    // Ячейка для строки с сообщением что нет загруженных треков
    func getCellForNoResultsRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        cell.messageLabel.text = textForNoResultsRow
        
        return cell
    }
    
    // Ячейка для строки с загруженным треком
    func getCellForOfflineAudioInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trackInPlaylist = activeArray[indexPath.row]
        let track = trackInPlaylist.track
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.addToPlaylistCell, forIndexPath: indexPath) as! AddToPlaylistCell
        cell.delegate = self
        cell.configureForName(track.title, andArtist: track.artist, isAdded: selectedTracks["\(track.id)_\(track.ownerID)"] == nil ? false : true)
        
        return cell
    }
    
    // Пытаемся получить ячейку для строки с количеством аудиозаписей
    func getCellForNumberOfAudioRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let count = getCountForCellForNumberOfOfflineAudioRowInTableView(tableView, forIndexPath: indexPath)
        
        if let count = count {
            let numberOfRowsCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.numberOfRowsCell) as! NumberOfRowsCell
            numberOfRowsCell.configureForType(.Audio, withCount: count)
            
            return numberOfRowsCell
        }
        
        return nil
    }
    
    // Ячейка для строки с сообщением, что при поиске ничего не было найдено
    func getCellForNothingFoundRowInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nothingFoundCell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! NothingFoundCell
        nothingFoundCell.messageLabel.text = textForNothingFoundRow
        
        return nothingFoundCell
    }
    
    
    // MARK: Работа с клавиатурой
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // Спрятать клавиатуру у поисковой строки
    func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
        
        if searchController.active && searchController.searchBar.text!.isEmpty {
            searchController.active = false
        }
    }
    
    
    // MARK: Поиск
    
    // Управление доступностью поиска
    func searchEnable(enable: Bool) {
        if enable {
            if tableView.tableHeaderView == nil {
                searchController.searchBar.alpha = 1
                tableView.tableHeaderView = searchController.searchBar
                tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame)) // Прячем строку поиска
            }
        } else {
            if let _ = tableView.tableHeaderView {
                searchController.searchBar.alpha = 0
                searchController.active = false
                tableView.tableHeaderView = nil
            }
        }
    }
    
    // Выполнение поиска
    func filterContentForSearchText(searchText: String) {
        filteredTracks = downloadedTracks.filter { trackInPlaylist in
            let track = trackInPlaylist.track
            return track.title.lowercaseString.containsString(searchText.lowercaseString) || track.artist.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    // Вызывается при тапе по кнопке "Отмена"
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Вызывается при тапе по кнопке "Сохранить"
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        view.endEditing(true)
        
        let title = playlistTitleTextField.text!
        
        if DataManager.sharedInstance.isExistsPlaylistWithTitle(playlistTitleTextField.text!) {
            let alertController = UIAlertController(title: "Ошибка", message: "Плейлист с таким названием уже существует, необходимо выбрать другое название!", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let tracks = selectedTracks.map {$1} // Массив выбранных треков
        DataManager.sharedInstance.createPlaylistWithTitle(title, andTracks: tracks)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Обработка пользовательских событий

    // Вызывается когда содержание текстового поля было изменено
    @IBAction func playlistTitleTextFieldValueChanged(sender: UITextField) {
        saveButton.enabled = !playlistTitleTextField.text!.isEmpty
    }

}


// MARK: UITableViewDataSource

extension AddPlaylistViewController: UITableViewDataSource {
    
    // Получение количества строк таблицы
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloadedCount == 0 {
            return 1 // Ячейка с сообщением об отсутствии загруженных треков
        } else {
            return activeArray.count + 1
        }
    }
    
    // Получение ячейки для строки таблицы
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if downloadedCount == 0 {
            return getCellForNoResultsRowInTableView(tableView, forIndexPath: indexPath)
        } else {
            if searchController.active && searchController.searchBar.text != "" && filteredTracks.count == 0 {
                return getCellForNothingFoundRowInTableView(tableView, forIndexPath: indexPath)
            }
            
            if let numberOfRowsCell = getCellForNumberOfAudioRowInTableView(tableView, forIndexPath: indexPath) {
                return numberOfRowsCell
            }
            
            return getCellForOfflineAudioInTableView(tableView, forIndexPath: indexPath)
        }
    }
    
}


// MARK: UITableViewDelegate

extension AddPlaylistViewController: UITableViewDelegate {
    
    // Высота каждой строки
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let count: Int?
        
        if activeArray.count == indexPath.row {
            count = activeArray.count
        } else {
            count = nil
        }
        
        if let _ = count {
            return 44
        }
        
        return 53
    }
    
    // Вызывается при тапе по строке таблицы
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: UISearchBarDelegate

extension AddPlaylistViewController: UISearchBarDelegate {
    
    // Говорит делегату что пользователь хочет начать поиск
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return downloadedCount != 0
    }
    
    // Вызывается когда пользователь начал редактирование поискового текста
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // Вызывается когда пользователь закончил редактирование поискового текста
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    // В поисковой панели была нажата отмена
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredTracks.removeAll()
    }
    
}


// MARK: UISearchResultsUpdating

extension AddPlaylistViewController: UISearchResultsUpdating {
    
    // Вызывается когда поле поиска получает фокус или когда значение поискового запроса изменяется
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        reloadTableView()
    }
    
}


// MARK: DataManagerDownloadsDelegate

extension AddPlaylistViewController: DataManagerDownloadsDelegate {
    
    // Контроллер начал изменять контент
    func dataManagerDownloadsControllerWillChangeContent() {}
    
    // Контроллер совершил изменения определенного типа в укзанном объекте по указанному пути (опционально новый путь)
    func dataManagerDownloadsControllerDidChangeObject(anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {}
    
    // Контроллер закончил изменять контент
    func dataManagerDownloadsControllerDidChangeContent() {
        if activeArray == downloadedTracks {
            reloadTableView()
        }
    }
    
}


// MARK: AddToPlaylistCellDelegate

extension AddPlaylistViewController: AddToPlaylistCellDelegate {
    
    // Вызывается при нажатии по кнопке "+"
    func addTapped(cell: AddToPlaylistCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let trackInPlaylist = activeArray[indexPath.row]
            let track = trackInPlaylist.track
            
            selectedTracks["\(track.id)_\(track.ownerID)"] = track
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
        }
    }
    
}