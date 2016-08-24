//
//  ProfileViewController.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/19/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var firstName: UILabel!
    @IBOutlet var lastName: UILabel!
    @IBOutlet var height: UILabel!
    @IBOutlet var baseball: UILabel!
    @IBOutlet var basketball: UILabel!
    @IBOutlet var soccer: UILabel!
    @IBOutlet var volleyball: UILabel!
    var user: FIRUser!
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        let userID = FIRAuth.auth()?.currentUser?.uid

        ref.child("users").child(userID!).observeEventType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            let userFirstName = snapshot.value!["userFirstName"] as! String!
            let userLastName = snapshot.value!["userLastName"] as! String!
            let userHeight = snapshot.value!["userHeight"] as! String!
            let baseballExperience = snapshot.value!["baseball"] as! String!
            let basketballExperience = snapshot.value!["basketball"] as! String!
            let soccerExerpience = snapshot.value!["soccer"] as! String!
            let volleyballExperience = snapshot.value!["volleyball"] as! String!
            self.firstName.text = userFirstName
            self.lastName.text = userLastName
            self.height.text = userHeight
            self.baseball.text = "Baseball Skills: \(baseballExperience)"
            self.basketball.text = "Basketball Skills: \(basketballExperience)"
            self.soccer.text = "Soccer Skills: \(soccerExerpience)"
            self.volleyball.text = "Volleyball Skills: \(volleyballExperience)"
            if let base64String = snapshot.value!["image"] as? String {
                // decode image
                self.profilePicture.image = CommonUtils.sharedUtils.decodeImage(base64String)
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
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
