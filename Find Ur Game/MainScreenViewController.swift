//
//  MainScreenViewController.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/7/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class MainScreenViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGameButton(sender: AnyObject) {
        let createGameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CreateGameViewController") as! CreateGameViewController!
        self.navigationController?.pushViewController(createGameViewController, animated: true)
    }
    
    @IBAction func gameScheduleButton(sender: AnyObject) {
        let gameScheduleViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameScheduleViewController") as! GameScheduleViewController!
        self.navigationController?.pushViewController(gameScheduleViewController, animated: true)
    }
    
    @IBAction func currentGameButton(sender: AnyObject) {
        let tableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TableViewController") as! TableViewController!
        self.navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FirebaseSignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func mapButton(sender: AnyObject) {
        //let mapOptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MapOptionViewController") as! MapOptionViewController!
        //self.navigationController?.pushViewController(mapOptionViewController, animated: true)
    }
    
    @IBAction func profileButton(sender: AnyObject) {
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController!
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }

}
