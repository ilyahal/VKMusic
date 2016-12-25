//
//  EditPlaylistViewController.swift
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

import UIKit

/// Контроллер содержащий интерфейс для редактирования плейлиста
class EditPlaylistViewController: UIViewController {
    
    /// Редактируемый плейлист
    var playlistToEdit: Playlist?
    
    /// Текстовое поле для ввода названия плейлиста
    @IBOutlet weak var playlistTitleTextField: UITextField!
    /// Контейнер содержащий контроллер содержащий текущий список аудиозаписей редактируемого плейлиста
    @IBOutlet weak var editPlaylistTableViewControllerContainer: UIView!
    
    /// Контроллер содержащий текущий список аудиозаписей редактируемого плейлиста
    weak var editPlaylistMusicTableViewController: EditPlaylistMusicTableViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка клавиатуры для поля для ввода названия плейлиста
        let doneToolBar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 40))
        doneToolBar.barStyle = .Default
        doneToolBar.tintColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
        doneToolBar.backgroundColor = UIColor.whiteColor()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        doneToolBar.setItems([flexSpace, doneButton], animated: true)
        
        playlistTitleTextField.inputAccessoryView = doneToolBar
        playlistTitleTextField.delegate = self
        
        // Настройка текстового поля для ввода названия плейлиста
        playlistTitleTextField.text = playlistToEdit?.title
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showEditPlaylistMusicTableViewControllerInContainerSegue {
            let editPlaylistMusicTableViewController = segue.destinationViewController as! EditPlaylistMusicTableViewController
            editPlaylistMusicTableViewController.playlistToEdit = playlistToEdit
            
            self.editPlaylistMusicTableViewController = editPlaylistMusicTableViewController
        }
    }
    
    
    // MARK: Кнопки на навигационной панели
    
    /// Вызывается при тапе по кнопке "Отмена"
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        view.endEditing(true) // Принудительно закрываем все клавиатуры
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Вызывается при тапе по кнопке "Сохранить"
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        view.endEditing(true) // Принудительно закрываем все клавиатуры
        
        let title = playlistTitleTextField.text! == "" ? "Новый плейлист" : playlistTitleTextField.text!
        let tracks = editPlaylistMusicTableViewController.tracks
        
        if let playlistToEdit = playlistToEdit {
            DataManager.sharedInstance.updatePlaylist(playlistToEdit, withTitle: title, andTracks: tracks)
        } else {
            DataManager.sharedInstance.createPlaylistWithTitle(title, andTracks: tracks)
        }
            
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Обработка пользовательских событий
    
    /// Нажата кнопка "Готово" на тулбаре клавиатуры для ввода названия плейлиста
    func donePressed(sender: UIBarButtonItem) {
        playlistTitleTextField.resignFirstResponder()
    }

}


// MARK: UITextFieldDelegate

extension EditPlaylistViewController: UITextFieldDelegate {
    
    // Была нажата кнопка "Готово"
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
}
