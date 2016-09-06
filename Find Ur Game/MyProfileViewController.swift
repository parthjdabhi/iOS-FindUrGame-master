//
//  MyProfileViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/5/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

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
        ref.child("users").child(myUserID!).observeEventType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            let userFirstName = snapshot.value!["userFirstName"] as! String!
            let userLastName = snapshot.value!["userLastName"] as! String!
            let userHeight = snapshot.value!["userHeight"] as! String!
//            let baseballExperience = snapshot.value!["baseball"] as! String!
//            let basketballExperience = snapshot.value!["basketball"] as! String!
//            let soccerExerpience = snapshot.value!["soccer"] as! String!
//            let volleyballExperience = snapshot.value!["volleyball"] as! String!
            
            self.lblName.text = userFirstName + " " + userLastName
            self.lblBodyDetails.text = userHeight
            
            if let base64String = snapshot.value!["image"] as? String {
                // decode image
                self.imgProfile.image = CommonUtils.sharedUtils.decodeImage(base64String)
            } else {
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
    
    @IBAction func actionCreategame(sender: AnyObject) {
    }

}
