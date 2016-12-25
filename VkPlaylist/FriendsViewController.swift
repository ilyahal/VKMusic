//
//  FriendsViewController.swift
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

/// Контроллер содержит контейнер со списком друзей
class FriendsViewController: UIViewController {

    /// Правило для нижней границы контейнера с таблицей
    @IBOutlet weak var containerBottomLayoutConstraint: NSLayoutConstraint!
    
    /// Значение для правила для нижней границы контейнера с таблицей
    var containerBottomLayoutConstraintConstantValue: CGFloat {
        return PlayerManager.sharedInstance.isPlaying ? -9 : -49
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateContainerBottomLayoutConstraintAnimated(false)
        
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidShowMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(playerManagerDidHideMiniPlayerNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.updateContainerBottomLayoutConstraintAnimated(true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidShowMiniPlayerNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: playerManagerDidHideMiniPlayerNotification, object: nil)
    }
    
    
    /// Обновить отступ для нижней границы контейнера с аудиозаписями
    func updateContainerBottomLayoutConstraintAnimated(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.containerBottomLayoutConstraint.constant = self.containerBottomLayoutConstraintConstantValue
        }
    }
    
}
