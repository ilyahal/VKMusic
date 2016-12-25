//
//  MainTabBarController.swift
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

class MainTabBarController: UITabBarController {
    
    /// ViewController с мини-плеером
    var miniPlayerViewController: MiniPlayerViewController {
        return PlayerManager.sharedInstance.miniPlayerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(miniPlayerViewController)
        miniPlayerViewController.view.frame = CGRectMake(0, view.frame.size.height - tabBar.bounds.size.height - 40, view.frame.size.width, 40)
        view.addSubview(miniPlayerViewController.view)
        miniPlayerViewController.didMoveToParentViewController(self)
        
        // По-умолчанию скрываем мини-плеер
        PlayerManager.sharedInstance.hideMiniPlayerAnimated(false)
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == .RemoteControl {
            switch event!.subtype {
            case .RemoteControlPlay:
                PlayerManager.sharedInstance.playTapped()
            case .RemoteControlPause:
                PlayerManager.sharedInstance.pauseTapped()
            case .RemoteControlTogglePlayPause:
                if PlayerManager.sharedInstance.isPauseActive {
                    PlayerManager.sharedInstance.playTapped()
                } else {
                    PlayerManager.sharedInstance.pauseTapped()
                }
            case .RemoteControlNextTrack:
                PlayerManager.sharedInstance.nextTapped()
            case .RemoteControlPreviousTrack:
                PlayerManager.sharedInstance.previousTapped()
            default:
                break
            }
        }
    }

}
