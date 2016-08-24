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

import IQKeyboardManagerSwift
import IQDropDownTextField

class CreateGameViewController: UIViewController, CLLocationManagerDelegate, SelectLocationDelegate, IQDropDownTextFieldDelegate {
    
    @IBOutlet var gameNotes: UITextView!
    @IBOutlet var groupName: UITextField!
    @IBOutlet var skillLevelLabel: UILabel!
    @IBOutlet var skillLevel: UISlider!
    @IBOutlet var addressLabel: UITextField!
    @IBOutlet var btnLocation: UIButton!
    
    @IBOutlet var sportLabel: UILabel!
    @IBOutlet var volleyball: UIButton!
    @IBOutlet var soccer: UIButton!
    @IBOutlet var basketball: UIButton!
    @IBOutlet var baseball: UIButton!
    @IBOutlet var gameInformation: UILabel!
    
    @IBOutlet var txtStartDate: IQDropDownTextField?
    @IBOutlet var txtEndDate: IQDropDownTextField?
    
    var ref:FIRDatabaseReference!
    var sportArray = ["Baseball", "Basketball", "Soccer", "Volleyball"]
    var geocoder = CLGeocoder()
    var user: FIRUser!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    
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
        
        addressLabel.text = "Select Location"
        
        txtStartDate?.isOptionalDropDown = false
        txtStartDate?.dropDownMode = IQDropDownMode.DateTimePicker
        txtStartDate?.setDate(NSDate(), animated: true)
        
        txtEndDate?.isOptionalDropDown = false
        txtEndDate?.dropDownMode = IQDropDownMode.DateTimePicker
        txtEndDate?.setDate(NSDate(), animated: true)
        
        self.initLocationManager()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGameButton(sender: AnyObject) {
        
        if addressLabel.text == "Select Location" || selectedLocation == nil {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Please select location for game!")
            return
        }
        else if txtEndDate!.date > NSDate() {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "invalid end date!")
            return
        }
        else if txtEndDate!.date > txtStartDate!.date {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "invalid end date!")
            return
        }
        
        let MyUserID = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        let startTimestamp = (txtStartDate?.date ?? NSDate()).timeIntervalSince1970
        let endTimestamp = (txtEndDate?.date ?? NSDate()).timeIntervalSince1970
        
        let game:[NSObject : AnyObject] = ["locName":self.addressLabel.text!,"sport":self.sportLabel.text!, "lat": selectedLocation!.coordinate.latitude, "long": selectedLocation!.coordinate.longitude, "gameCreator": MyUserID!, "skillLevel": skillLevelLabel.text!, "groupName": groupName.text!, "gameNotes": gameNotes.text!, "timestamp": timestamp, "startTimestamp": startTimestamp, "endTimestamp": endTimestamp]
        
        ref.child("games").child("active").childByAutoId().updateChildValues(game) { (error, ref) in
            if error == nil {
                //CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Game saved successfully!")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Opps,we are uable to create game!")
            }
        }
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
//        let address = addressLabel.text
//        let geocoder = CLGeocoder()
//        
//        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
//            if((error) != nil){
//                print("Error", error)
//            }
//            if let placemark = placemarks?.first {
//                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                self.long = coordinates.longitude
//                self.lat = coordinates.latitude
//            }
//        })
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
    
    @IBAction func actionSelectLocation(sender: AnyObject) {
        didTapSelectLocation()
    }
    
    // MARK: - IQDropDownTextFieldDelegate Methods
    func textField(textField: IQDropDownTextField, didSelectDate date: NSDate?) {
        print(date)
    }
    
    // MARK: - Location
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        locationManager.stopUpdatingLocation()
        print("\(error)")
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if self.selectedLocation == nil
            && self.currentLocation == nil
        {
            let location = locations.last! as CLLocation
            currentLocation = location
            CLocation = location
            CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {(placemarks, error)->Void in
                let pm = placemarks![0]
                self.OnSelectUserLocation(self.currentLocation, LocationDetail: pm.LocationString())
                if let place = pm.LocationString()
                {
                    CLocationPlace = place
                }
            })
        }
        locationManager.stopUpdatingLocation()
    }
    
    func didTapSelectLocation()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewControllerWithIdentifier("SelectLocationViewController") as! SelectLocationViewController
        secondVC.delegate = self
        secondVC.selectedLocation = (self.selectedLocation != nil) ? self.selectedLocation : currentLocation
        secondVC.locationString = self.addressLabel.text
        
        presentViewController(secondVC, animated: true, completion: nil)
    }
    
    // MARK: - Location Selction Delegate Methods
    func OnSelectUserLocation(Location: CLLocation?, LocationDetail: String?)
    {
        if (Location != nil
            && LocationDetail != "Select Locaion"
            && LocationDetail?.characters.count > 3)
        {
            self.selectedLocation = Location
            addressLabel.text = LocationDetail
        }
    }

}
