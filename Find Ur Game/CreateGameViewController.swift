//
//  CreateGameViewController.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/19/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class CreateGameViewController: UIViewController {
    
    @IBOutlet var gameNotes: UITextView!
    @IBOutlet var groupName: UITextField!
    @IBOutlet var skillLevelLabel: UILabel!
    @IBOutlet var skillLevel: UISlider!
    @IBOutlet var addressLabel: UITextField!
    @IBOutlet var sportLabel: UILabel!
    @IBOutlet var volleyball: UIButton!
    @IBOutlet var soccer: UIButton!
    @IBOutlet var basketball: UIButton!
    @IBOutlet var baseball: UIButton!
    @IBOutlet var gameInformation: UILabel!
    var ref:FIRDatabaseReference!
    var sportArray = ["Baseball", "Basketball", "Soccer", "Volleyball"]
    var geocoder = CLGeocoder()
    var lat : Double = Double()
    var long : Double = Double()
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        //Get Current Date
        let currentDate = NSDate()
        
        //Test Extensions in Log
        NSLog("(Current Hour = \(currentDate.hour())) (Current Minute = \(currentDate.minute())) (Current Short Time String = \(currentDate.toShortTimeString()))")
        
        gameNotes.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        gameNotes.layer.borderWidth = 1.0
        gameNotes.layer.cornerRadius = 5
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGameButton(sender: AnyObject) {
        
        let MyUserID = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        ref.child("games").child("active").childByAutoId().updateChildValues(["sport":self.sportLabel.text!, "lat": lat, "long": long, "gameCreator": MyUserID!, "skillLevel": skillLevelLabel.text!, "groupName": groupName.text!, "gameNotes": gameNotes.text!, "timestamp": timestamp])
    }
    
    @IBAction func baseballButton(sender: AnyObject) {
        let sportAnswer = sportArray[0]
        sportLabel.text = sportAnswer
    }
    
    @IBAction func basketballButton(sender: AnyObject) {
        let sportAnswer = sportArray[1]
        sportLabel.text = sportAnswer
    }
    
    @IBAction func soccerButton(sender: AnyObject) {
        let sportAnswer = sportArray[2]
        sportLabel.text = sportAnswer
    }
    
    @IBAction func volleyballButton(sender: AnyObject) {
        let sportAnswer = sportArray[3]
        sportLabel.text = sportAnswer
    }
    
    @IBAction func addressAction(sender: AnyObject) {
        let address = addressLabel.text
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                self.long = coordinates.longitude
                self.lat = coordinates.latitude
            }
        })
    }
    
    @IBAction func skillLevelAction(sender: AnyObject) {
        sender.setValue(Float(lroundf(skillLevel.value)), animated: true)
        if skillLevel.value == 1 {
            skillLevelLabel.text = "No Experience"
        }
        if skillLevel.value == 2 {
            skillLevelLabel.text = "Recreational"
        }
        if skillLevel.value == 3 {
            skillLevelLabel.text = "High School"
        }
        if skillLevel.value == 4 {
            skillLevelLabel.text = "College"
        }
        if skillLevel.value == 5 {
            skillLevelLabel.text = "Pro"
        }
    }
    
    @IBAction func groupNameAction(sender: AnyObject) {
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
