//
//  MyMusicViewController.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 31.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

/// Контроллер содержащий контейнер со списком личных аудиозаписей пользователя
class MyMusicViewController: UIViewController {

    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    @IBOutlet weak var miniPlayerButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    private var animator: ARNTransitionAnimator!
    private var musicPlayerViewController: MusicPlayerViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        musicPlayerViewController = storyboard.instantiateViewControllerWithIdentifier("MusicPlayerViewController") as? MusicPlayerViewController
        musicPlayerViewController.modalPresentationStyle = .OverFullScreen
        musicPlayerViewController.tapCloseButtonActionHandler = { [unowned self] in
            self.animator.interactiveType = .None
        }
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerButton.setBackgroundImage(generateImageWithColor(color), forState: .Highlighted)
        
        setupAnimator()
    }
    
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self, toVC: musicPlayerViewController)
        self.animator.usingSpringWithDamping = 0.8
        self.animator.gestureTargetView = self.miniPlayerView
        self.animator.interactiveType = .Present
        
        // Present
        
        self.animator.presentationBeforeHandler = { [unowned self] containerView, transitionContext in
            print("start presentation")
            self.beginAppearanceTransition(false, animated: false)
            
            self.animator.direction = .Top
            
            self.musicPlayerViewController.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
            self.view.insertSubview(self.musicPlayerViewController.view, belowSubview: self.tabBarController!.tabBar)
            
            self.view.layoutIfNeeded()
            self.musicPlayerViewController.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = self.miniPlayerView.frame.origin.y
            let endOriginY = -self.miniPlayerView.frame.size.height
            let diff = -endOriginY + startOriginY
            // tabBar
            let tabStartOriginY = self.tabBarController!.tabBar.frame.origin.y
            let tabEndOriginY = containerView.frame.size.height
            let tabDiff = tabEndOriginY - tabStartOriginY
            
            self.animator.presentationCancelAnimationHandler = { containerView in
                self.miniPlayerView.frame.origin.y = startOriginY
                self.musicPlayerViewController.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
                self.tabBarController!.tabBar.frame.origin.y = tabStartOriginY
                self.container.alpha = 1.0
                self.tabBarController!.tabBar.alpha = 1.0
                self.miniPlayerView.alpha = 1.0
                for subview in self.miniPlayerView.subviews {
                    subview.alpha = 1.0
                }
            }
            
            self.animator.presentationAnimationHandler = { [unowned self] containerView, percentComplete in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                self.miniPlayerView.frame.origin.y = startOriginY - (diff * _percentComplete)
                if self.miniPlayerView.frame.origin.y < endOriginY {
                    self.miniPlayerView.frame.origin.y = endOriginY
                }
                self.musicPlayerViewController.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
                self.tabBarController!.tabBar.frame.origin.y = tabStartOriginY + (tabDiff * _percentComplete)
                if self.tabBarController!.tabBar.frame.origin.y > tabEndOriginY {
                    self.tabBarController!.tabBar.frame.origin.y = tabEndOriginY
                }
                
                let alpha = 1.0 - (1.0 * _percentComplete)
                self.container.alpha = alpha + 0.5
                self.tabBarController!.tabBar.alpha = alpha
                for subview in self.miniPlayerView.subviews {
                    subview.alpha = alpha
                }
            }
            
            self.animator.presentationCompletionHandler = { containerView, completeTransition in
                self.endAppearanceTransition()
                
                if completeTransition {
                    self.miniPlayerView.alpha = 0.0
                    self.musicPlayerViewController.view.removeFromSuperview()
                    containerView.addSubview(self.musicPlayerViewController.view)
                    self.animator.interactiveType = .Dismiss
                    self.animator.gestureTargetView = self.musicPlayerViewController.view
                    self.animator.direction = .Bottom
                } else {
                    self.beginAppearanceTransition(true, animated: false)
                    self.endAppearanceTransition()
                }
            }
        }
        
        // Dismiss
        
        self.animator.dismissalBeforeHandler = { [unowned self] containerView, transitionContext in
            print("start dismissal")
            self.beginAppearanceTransition(true, animated: false)
            
            self.view.insertSubview(self.musicPlayerViewController.view, belowSubview: self.tabBarController!.tabBar)
            
            self.view.layoutIfNeeded()
            self.musicPlayerViewController.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = 0 - self.miniPlayerView.bounds.size.height
            let endOriginY = self.container.bounds.size.height - self.miniPlayerView.frame.size.height
            let diff = -startOriginY + endOriginY
            // tabBar
            let tabStartOriginY = containerView.bounds.size.height
            let tabEndOriginY = containerView.bounds.size.height - self.tabBarController!.tabBar.bounds.size.height
            let tabDiff = tabStartOriginY - tabEndOriginY
            
            self.tabBarController!.tabBar.frame.origin.y = containerView.bounds.size.height
            self.container.alpha = 0.5
            
            self.animator.dismissalCancelAnimationHandler = { containerView in
                self.miniPlayerView.frame.origin.y = startOriginY
                self.musicPlayerViewController.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
                self.tabBarController!.tabBar.frame.origin.y = tabStartOriginY
                self.container.alpha = 0.5
                self.tabBarController!.tabBar.alpha = 0.0
                self.miniPlayerView.alpha = 0.0
                for subview in self.miniPlayerView.subviews {
                    subview.alpha = 0.0
                }
            }
            
            self.animator.dismissalAnimationHandler = { containerView, percentComplete in
                let _percentComplete = percentComplete >= -0.05 ? percentComplete : -0.05
                self.miniPlayerView.frame.origin.y = startOriginY + (diff * _percentComplete)
                self.musicPlayerViewController.view.frame.origin.y = self.miniPlayerView.frame.origin.y + self.miniPlayerView.frame.size.height
                self.tabBarController!.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  _percentComplete)
                
                let alpha = 1.0 * _percentComplete
                self.container.alpha = alpha + 0.5
                self.tabBarController!.tabBar.alpha = alpha
                self.miniPlayerView.alpha = 1.0
                for subview in self.miniPlayerView.subviews {
                    subview.alpha = alpha
                }
            }
            
            self.animator.dismissalCompletionHandler = { containerView, completeTransition in
                self.endAppearanceTransition()
                
                if completeTransition {
                    self.musicPlayerViewController.view.removeFromSuperview()
                    self.animator.gestureTargetView = self.miniPlayerView
                    self.animator.interactiveType = .Present
                } else {
                    self.musicPlayerViewController.view.removeFromSuperview()
                    containerView.addSubview(self.musicPlayerViewController.view)
                    self.beginAppearanceTransition(false, animated: false)
                    self.endAppearanceTransition()
                }
            }
        }
        
        musicPlayerViewController.transitioningDelegate = animator
    }
    
    
    @IBAction func miniPlayerButtonTapped(sender: UIButton) {
        animator.interactiveType = .None
        presentViewController(musicPlayerViewController, animated: true, completion: nil)
    }
    
    private func generateImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
