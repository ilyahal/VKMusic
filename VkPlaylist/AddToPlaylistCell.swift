//
//  AddToPlaylistCell.swift
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

/// Ячейка для строки с добавляемой в плейлист офлайн аудиозаписью
class AddToPlaylistCell: UITableViewCell {
    
    weak var delegate: AddToPlaylistCellDelegate?

    /// Название аудиозаписи
    @IBOutlet weak var nameLabel: UILabel!
    /// Исполнитель
    @IBOutlet weak var artistLabel: UILabel!
    /// Метка, указывающая, добавлена ли уже аудиозапись
    @IBOutlet weak var isAddedLabel: UILabel!
    /// Контейнер содержащий кнопку "Добавить" (активная область)
    @IBOutlet weak var addButtonContainer: UIView!
    /// Кнопка "Добавить" аудиозапись
    @IBOutlet weak var addButton: ButtonWithRoundedBorder!
    
    /// Объект распознающий нажатие
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        isAddedLabel.textColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        artistLabel.text = nil
        
        addButtonContainer.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    /// Настройка ячейки для указанного названия аудиозаписи, исполнителя и флагом, добавлена ли уже аудиозапись в плейлист
    func configureForName(name: String, andArtist artist: String, isAdded: Bool) {
        nameLabel.text = name
        artistLabel.text = artist
        
        isAddedLabel.hidden = !isAdded
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTapped))
        addButtonContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Вызывается при нажатии по кнопке "Добавить"
    @IBAction func addButtonTapped(sender: AnyObject) {
        addTapped()
    }
    
    /// Вызывается при тапе либо по кнопке "Добавить", либо по активной области вокруг кнопки
    @objc private func addTapped() {
        delegate?.addTapped(self)
    }
}
