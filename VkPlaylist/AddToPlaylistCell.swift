//
//  AddToPlaylistCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
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
