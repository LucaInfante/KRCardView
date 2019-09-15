//
//  CardView.swift
//  KRCardView
//
//  Created by kamalraj venkatesan on 02/11/18.
//

import Foundation
import UIKit

public enum CardState: Int {
  case expanded, collapsed
}

public protocol KRCardView {
  var cardViewController: CardViewController! { get set }

  var cardHandleAreaHeight: CGFloat { get }
  var cardHeight: CGFloat { get }

}

extension KRCardView where Self: UIViewController {

  public func addKRCardView() {

    // Visual Effect View
    cardViewController.visualEffectView.frame = self.view.frame
    cardViewController.visualEffectView.isUserInteractionEnabled = false
    self.view.addSubview(cardViewController.visualEffectView)

    // Card view
    self.addChildViewController(cardViewController)
    self.view.addSubview(cardViewController.view)

    cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: self.cardHeight)
    
    cardViewController.view.clipsToBounds = true

  }

}


fileprivate extension UIViewController {


  var nextState: CardState {
    let bottomView = self as! KRCardView
    return bottomView.cardViewController.cardVisible ? .collapsed : .expanded
  }

  func animationTransitionIfNeeded(state: CardState, duration: TimeInterval) {

    guard var bottomView = self as? KRCardView else {
      return
    }

    guard bottomView.cardViewController.runningAnimations.isEmpty else {
      return
    }

    // Frame
    var frameAnimator: UIViewPropertyAnimator {

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        switch state {
        case .expanded:
          bottomView.cardViewController.view.frame.origin.y = self.view.bounds.height - bottomView.cardHeight
        case .collapsed:
          bottomView.cardViewController.view.frame.origin.y = self.view.bounds.height - bottomView.cardHandleAreaHeight
        }
      }

      animator.addCompletion { _ in
        bottomView.cardViewController.cardVisible = !bottomView.cardViewController.cardVisible
        bottomView.cardViewController.visualEffectView.isUserInteractionEnabled = !bottomView.cardViewController.cardVisible
        bottomView.cardViewController.runningAnimations.removeAll()
      }

      animator.startAnimation()

      return animator
    }

    // Corner Radius

    var cornerRadiusAnimator: UIViewPropertyAnimator {

      let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        bottomView.cardViewController.view.layer.cornerRadius = (state == .expanded) ? 12 : 0
      }
      animator.startAnimation()

      return animator
    }

    // Visual Effect

    var blurAnimator: UIViewPropertyAnimator {

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        bottomView.cardViewController.visualEffectView.effect = (state == .expanded) ? UIBlurEffect.init(style: .dark) : nil
      }

      animator.startAnimation()
      return animator
    }


    bottomView.cardViewController.runningAnimations.append(frameAnimator)
    bottomView.cardViewController.runningAnimations.append(cornerRadiusAnimator)
    bottomView.cardViewController.runningAnimations.append(blurAnimator)
  }


  func startInteractiveTransition(state: CardState, duration: TimeInterval) {

    guard var bottomView = self as? KRCardView else {
      return
    }

    if bottomView.cardViewController.runningAnimations.isEmpty {

      self.animationTransitionIfNeeded(state: state, duration: duration)
    }

    bottomView.cardViewController.runningAnimations.forEach{ animator in
      animator.pauseAnimation()
      bottomView.cardViewController.animationProgressWhenInterrupted = animator.fractionComplete
    }
  }

  func updateInteractiveTransition(fractionCompleted: CGFloat) {

    guard var bottomView = self as? KRCardView else {
      return
    }

    for animator in bottomView.cardViewController.runningAnimations {
      animator.fractionComplete = fractionCompleted + bottomView.cardViewController.animationProgressWhenInterrupted
    }

  }

  func continueInteractiveTransition() {

    guard var bottomView = self as? KRCardView else {
      return
    }

    for animator in bottomView.cardViewController.runningAnimations {
      animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }

  }
}



