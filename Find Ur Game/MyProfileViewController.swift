//
//  MyProfileViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/5/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage

class MyProfileViewController: UIViewController {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBodyDetails: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    @IBOutlet var vBasketball: UIView!
    @IBOutlet var btnBasketball: UIButton!
    @IBOutlet var lblBasketball: UILabel!
    
    @IBOutlet var vSoccer: UIView!
    @IBOutlet var btnSoccer: UIButton!
    @IBOutlet var lblSoccer: UILabel!
    
    @IBOutlet var vBaseball: UIView!
    @IBOutlet var btnBaseball: UIButton!
    @IBOutlet var lblBaseball: UILabel!
    
    @IBOutlet var vVoleyball: UIView!
    @IBOutlet var btnVoleyball: UIButton!
    @IBOutlet var lblVoleyball: UILabel!
    
    var sportArray = ["Basketball", "Baseball", "Soccer", "Volleyball"]
    var sportAnswer = ""
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        vBasketball.setCornerRadious(4)
        vBaseball.setCornerRadious(4)
        vSoccer.setCornerRadious(4)
        vVoleyball.setCornerRadious(4)
        
        imgProfile.setCornerRadious(2)
        imgProfile.setBorder(0.5, color: UIColor.blackColor())
        
        print(myUserID)
        ref.child("users").child(myUserID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            let userFirstName = snapshot.value!["userFirstName"] as? String ?? ""
            let userLastName = snapshot.value!["userLastName"] as? String ?? ""
            let userHeight = snapshot.value!["userHeight"] as? String ?? ""
            let userWeight = snapshot.value!["userWeight"] as? String ?? ""
//            let baseballExperience = snapshot.value!["baseball"] as! String!
//            let basketballExperience = snapshot.value!["basketball"] as! String!
//            let soccerExerpience = snapshot.value!["soccer"] as! String!
//            let volleyballExperience = snapshot.value!["volleyball"] as! String!
            
            self.lblName.text = userFirstName + " " + userLastName
            self.lblBodyDetails.text = "\(userWeight) W  -  \(userHeight) H"
            
            if let userSport = snapshot.value!["userSport"] as? String {
                if self.sportArray.contains(userSport) {
                    self.SportAction(((userSport == self.sportArray[0]) ? self.btnBasketball : ((userSport == self.sportArray[1]) ? self.btnBaseball : ((userSport == self.sportArray[2]) ? self.btnSoccer : self.btnVoleyball))))
                }
            }
            
            if let userProfile = snapshot.value!["userProfile"] as? String {
                let userProfileNSURL = NSURL(string: "\(userProfile)")
                self.imgProfile.setImageWithURL(userProfileNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            }
            else if let facebookData = snapshot.value!["facebookData"] as? NSDictionary
                where facebookData["profilePhotoURL"] != nil
            {
                let userProfileNSURL = NSURL(string: "\(facebookData["profilePhotoURL"] as? String ?? "")")
                self.imgProfile.setImageWithURL(userProfileNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            }
            else {
                print("No Profile Picture")
            }
            })
        { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func SportAction(sender: UIButton) {
        vBasketball.backgroundColor = UIColor.whiteColor()
        lblBasketball.textColor = UIColor.blackColor()
        vBaseball.backgroundColor = UIColor.whiteColor()
        lblBaseball.textColor = UIColor.blackColor()
        vSoccer.backgroundColor = UIColor.whiteColor()
        lblSoccer.textColor = UIColor.blackColor()
        vVoleyball.backgroundColor = UIColor.whiteColor()
        lblVoleyball.textColor = UIColor.blackColor()
        
        if sender == btnBasketball {
            sportAnswer = sportArray[0]
            vBasketball.backgroundColor = UIColor.blackColor()
            lblBasketball.textColor = UIColor.whiteColor()
        } else if sender == btnBaseball {
            sportAnswer = sportArray[1]
            vBaseball.backgroundColor = UIColor.blackColor()
            lblBaseball.textColor = UIColor.whiteColor()
        } else if sender == btnSoccer {
            sportAnswer = sportArray[2]
            vSoccer.backgroundColor = UIColor.blackColor()
            lblSoccer.textColor = UIColor.whiteColor()
        } else if sender == btnVoleyball {
            sportAnswer = sportArray[3]
            vVoleyball.backgroundColor = UIColor.blackColor()
            lblVoleyball.textColor = UIColor.whiteColor()
        }
    }
    
    @IBAction func actionLogout(sender: AnyObject)
    {
        let actionSheetController = UIAlertController (title: "Message", message: "Are you sure want to logout?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        actionSheetController.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive, handler: { (actionSheetController) -> Void in
            print("handle Logout action...")
            
            let firebaseAuth = FIRAuth.auth()
            do {
                FBSDKLoginManager().logOut()
                try firebaseAuth?.signOut()
                AppState.sharedInstance.signedIn = false
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError)")
            }
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FirebaseSignInViewController") as! FirebaseSignInViewController!
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }))
        
        presentViewController(actionSheetController, animated: true, completion: nil)
        
    }

}
