//
//  MusicPlayerViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 04.06.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    var tapCloseButtonActionHandler : (Void -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
    }
    
    @IBAction func closeButtonTapped() {
        self.tapCloseButtonActionHandler?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
