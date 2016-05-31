//
//  AddPlaylistViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AddPlaylistViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var playlistTitleTextField: UITextField!
    @IBOutlet weak var addPlaylistTableViewControllerContainer: UIView!
    
    weak var addPlaylistMusicTableViewController: AddPlaylistMusicTableViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка клавиатуры для поля с названием плейлиста
        let doneToolBar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 40))
        doneToolBar.barStyle = .Default
        doneToolBar.tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        doneToolBar.backgroundColor = UIColor.whiteColor()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        doneToolBar.setItems([flexSpace, doneButton], animated: true)
        
        playlistTitleTextField.inputAccessoryView = doneToolBar
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddPlaylistMusicTableViewControllerInContainerSegue" {
            let addPlaylistMusicTableViewController = segue.destinationViewController as! AddPlaylistMusicTableViewController
            self.addPlaylistMusicTableViewController = addPlaylistMusicTableViewController
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
        let tracks = addPlaylistMusicTableViewController.selectedTracks.map {$1} // Массив выбранных треков
        
        DataManager.sharedInstance.createPlaylistWithTitle(title, andTracks: tracks)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Обработка пользовательских событий

    // Вызывается когда содержание текстового поля было изменено
    @IBAction func playlistTitleTextFieldValueChanged(sender: UITextField) {
        saveButton.enabled = !playlistTitleTextField.text!.isEmpty
    }
    
    // Нажата кнопка готово на тулбаре клавиатуры для ввода названия плейлиста
    func donePressed(sender: UIBarButtonItem) {
        playlistTitleTextField.resignFirstResponder()
    }

}
