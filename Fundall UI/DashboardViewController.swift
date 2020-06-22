//
//  DashboardViewController.swift
//  Fundall UI
//
//  Created by Aboyeji Tolulope on 22/06/2020.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

enum CardState {
    case expanded
    case collapsed
}

    @IBOutlet var cardViewController: UIView!
    @IBOutlet weak var handleArea: UIView!
    
    
    var visualEffectView:UIVisualEffectView!
    
   
        var cardHeight:CGFloat!
        var cardHandleAreaHeight:CGFloat!
        
    var safeAreaHeight: CGFloat {
                    if #available(iOS 11, *) {
                       return self.view.safeAreaLayoutGuide.layoutFrame.size.height
                    }
                   return self.view.bounds.height
               }
    
        var cardVisible = false
        var nextState:CardState {
            return cardVisible ? .collapsed : .expanded
        }
        
        var runningAnimations = [UIViewPropertyAnimator]()
        var animationProgressWhenInterrupted:CGFloat = 0
        
        override func viewDidLoad() {
            super.viewDidLoad()
          
           
            cardHeight = (80/100) * (safeAreaHeight)
            cardHandleAreaHeight = (40/100) * (safeAreaHeight)
              setupCard()
        }
        
        func setupCard() {
            visualEffectView = UIVisualEffectView()
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)
            
            self.view.addSubview(cardViewController)
            
            cardViewController.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
            
            cardViewController.clipsToBounds = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.handleCardTap(recognzier:)))
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DashboardViewController.handleCardPan(recognizer:)))
            
            handleArea.addGestureRecognizer(tapGestureRecognizer)
            handleArea.addGestureRecognizer(panGestureRecognizer)
//            self.view.addGestureRecognizer(tapGestureRecognizer)
            
            
        }

        @objc
        func handleCardTap(recognzier:UITapGestureRecognizer) {
            switch recognzier.state {
            case .ended:
                animateTransitionIfNeeded(state: nextState, duration: 0.9)
            default:
                break
            }
        }
        
        @objc
        func handleCardPan (recognizer:UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                startInteractiveTransition(state: nextState, duration: 0.9)
            case .changed:
                let translation = recognizer.translation(in: self.cardViewController)
                var fractionComplete = translation.y / cardHeight
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            case .ended:
                continueInteractiveTransition()
            default:
                break
            }
            
        }
        
        func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.cardViewController.frame.origin.y = self.view.frame.height - self.cardHeight
                    case .collapsed:
                        self.cardViewController.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                    }
                }
                
                frameAnimator.addCompletion { _ in
                    self.cardVisible = !self.cardVisible
                    self.runningAnimations.removeAll()
                }
                
                frameAnimator.startAnimation()
                runningAnimations.append(frameAnimator)
                
                
                let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                    switch state {
                    case .expanded:
                        self.cardViewController.layer.cornerRadius = 50
                        self.handleArea.layer.cornerRadius = 50
                    case .collapsed:
                        self.cardViewController.layer.cornerRadius = 50
                        self.handleArea.layer.cornerRadius = 50
                    }
                }
                
                cornerRadiusAnimator.startAnimation()
                runningAnimations.append(cornerRadiusAnimator)
                
                let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    case .collapsed:
                        self.visualEffectView.effect = nil
                    }
                }
                
                blurAnimator.startAnimation()
                runningAnimations.append(blurAnimator)
                
            }
        }
        
        func startInteractiveTransition(state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                animateTransitionIfNeeded(state: state, duration: duration)
            }
            for animator in runningAnimations {
                animator.pauseAnimation()
                animationProgressWhenInterrupted = animator.fractionComplete
            }
        }
        
        func updateInteractiveTransition(fractionCompleted:CGFloat) {
            for animator in runningAnimations {
                animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
            }
        }
        
        func continueInteractiveTransition (){
            for animator in runningAnimations {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        }
        
    }