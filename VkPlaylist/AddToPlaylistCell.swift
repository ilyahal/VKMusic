//
//  AddToPlaylistCell.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 30.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class AddToPlaylistCell: UITableViewCell {
    
    weak var delegate: AddToPlaylistCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addButtonContainer: UIView!
    @IBOutlet weak var addButton: AddToPlaylistButton!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func prepareForReuse() {
        nameLabel.text = nil
        artistLabel.text = nil
        addButton.cornerRadius = 13
        addButton.borderWidth = 1
        
        addButtonContainer.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    func configureForName(name: String, andArtist artist: String, isAdded: Bool) {
        nameLabel.text = name
        artistLabel.text = artist
        
        if isAdded {
            addButton.borderWidth = 0
            addButton.cornerRadius = 0
            addButton.titleLabel!.text = "✓" // Для ускорения отображения
            addButton.setTitle("✓", forState: .Normal)
        } else {
            addButton.borderWidth = 1
            addButton.cornerRadius = 13
            addButton.titleLabel!.text = "+" // Для ускорения отображения
            addButton.setTitle("+", forState: .Normal)
        }
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
        addButtonContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Вызывается при нажатии по кнопке "+"
    @IBAction func addButtonTapped(sender: AnyObject) {
        if addButton.titleForState(.Normal) == "+" {
            delegate?.addTapped(self)
        }
    }
}
