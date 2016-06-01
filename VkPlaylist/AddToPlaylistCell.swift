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
    @IBOutlet weak var isAddedLabel: UILabel!
    @IBOutlet weak var addButtonContainer: UIView!
    @IBOutlet weak var addButton: AddToPlaylistButton!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func drawRect(rect: CGRect) {
        isAddedLabel.textColor = (UIApplication.sharedApplication().delegate as! AppDelegate).tintColor
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        artistLabel.text = nil
        
        addButtonContainer.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
    }
    
    func configureForName(name: String, andArtist artist: String, isAdded: Bool) {
        nameLabel.text = name
        artistLabel.text = artist
        
        isAddedLabel.hidden = !isAdded
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
        addButtonContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Вызывается при нажатии по кнопке "+"
    @IBAction func addButtonTapped(sender: AnyObject) {
        delegate?.addTapped(self)
    }
}
