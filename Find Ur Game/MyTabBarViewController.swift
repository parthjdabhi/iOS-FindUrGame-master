//
//  MyTabBarViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit

public class MyTabBarViewController: ESTabBarController {
    var value: Int64 = 0
    let button: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.lightGrayColor()
        button.setTitle("Click", forState: .Normal)
        button.layer.cornerRadius = 25.0
        button.clipsToBounds = true
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notification"
        //button.addTarget(self, action: #selector(NotificationStyleTabBarController.buttonAction), forControlEvents: .TouchUpInside)
        //self.view.addSubview(button)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let v1          = mainStoryboard.instantiateViewControllerWithIdentifier("CreateNewGameViewController") as! CreateNewGameViewController
        let v2          = mainStoryboard.instantiateViewControllerWithIdentifier("FindGameViewController") as! FindGameViewController
        let v3          = mainStoryboard.instantiateViewControllerWithIdentifier("MyProfileViewController") as! MyProfileViewController
        //let v4          = ExampleViewController()
        //let v5          = ExampleViewController()
        
        let c1 = ESTabBarItemContent.init(animator: NotificationStyleAnimator.init())
        let c2 = ESTabBarItemContent.init(animator: NotificationStyleAnimator.init())
        let c3 = ESTabBarItemContent.init(animator: NotificationStyleAnimator.init())
        //let c4 = ESTabBarItemContent.init(animator: NotificationStyleAnimator.init())
        //let c5 = ESTabBarItemContent.init(animator: NotificationStyleAnimator.init())
        
        c1.highlightEnabled = true
        c2.highlightEnabled = true
        c3.highlightEnabled = true
        //c4.highlightEnabled = true
        //c5.highlightEnabled = true
        
        c1.tintColor = UIColor.redColor()
        c2.highlightEnabled = true
        
        
        v1.tabBarItem   = ESTabBarItem.init(content: c1)
        v2.tabBarItem   = ESTabBarItem.init(content: c2)
        v3.tabBarItem   = ESTabBarItem.init(content: c3)
        //v4.tabBarItem   = ESTabBarItem.init(content: c4)
        //v5.tabBarItem   = ESTabBarItem.init(content: c5)
        
        v1.tabBarItem.image = UIImage.init(named: "calander2")
        v2.tabBarItem.image = UIImage.init(named: "map-fill")
        v3.tabBarItem.image = UIImage.init(named: "user2")
        //v4.tabBarItem.image = UIImage.init(named: "message")
        //v5.tabBarItem.image = UIImage.init(named: "me")
        v1.tabBarItem.selectedImage = UIImage.init(named: "calander1")
        v2.tabBarItem.selectedImage = UIImage.init(named: "map-fill2")
        v3.tabBarItem.selectedImage = UIImage.init(named: "user")
        //v4.tabBarItem.selectedImage = UIImage.init(named: "message_1")
        //v5.tabBarItem.selectedImage = UIImage.init(named: "me_1")
        
        let controllers = [v1, v2, v3]//, v4, v5
        self.viewControllers = controllers
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //button.frame = CGRect.init(x: self.view.bounds.size.width - 120, y: self.view.bounds.size.height / 2, width: 100, height: 50)
    }
    
    func buttonAction() {
        value += 1
        if let item = self.tabBar.items![3] as? ESTabBarItem {
            item.badgeValue = String(value)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
