//
//  CardViewController.swift
//  CardViewAnimator
//
//  Created by kamalraj venkatesan on 31/10/18.
//  Copyright © 2018 Kamalraj. All rights reserved.
//

import UIKit

open class CardViewController: UIViewController {

  var handleArea = UIView(frame: .zero)

  var visualEffectView = UIVisualEffectView()

  var cardVisible: Bool = false
  var runningAnimations = [UIViewPropertyAnimator]()
  var animationProgressWhenInterrupted:CGFloat = 0
  
  override open func viewDidLoad() {
        super.viewDidLoad()
        self.handleArea = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        self.handleArea.backgroundColor = UIColor.black
        self.view.addSubview(self.handleArea)
    }
}
