//
//  NotificationStyleAnimator.swift
//  Find Ur Game
//
//  Created by iParth on 9/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

import UIKit

public class NotificationStyleAnimator: BackgroundStyleAnimator {
    
    public var duration = 0.3
    
    public override func badgeChangedAnimation(content content: UIView, completion: (() -> ())?) {
        super.badgeChangedAnimation(content: content, completion: completion)
        if let content = content as? ESTabBarItemContent {
            notificationAnimation(content.imageView)
        }
    }
    
    internal func notificationAnimation(view: UIView) {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        impliesAnimation.values = [0.0 ,-8.0, 4.0, -4.0, 3.0, -2.0, 0.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        
        view.layer.addAnimation(impliesAnimation, forKey: nil)
    }
    
}