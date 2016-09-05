//
//  CreateNewGameViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/5/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

import Foundation
import Firebase
import CoreLocation

import IQKeyboardManagerSwift
import IQDropDownTextField

/*
 green color(basket ball) : #1abc9c
 basketball bg color : #222831
 black color : #222831
 */
class CreateNewGameViewController: UIViewController, CLLocationManagerDelegate, SelectLocationDelegate, IQDropDownTextFieldDelegate {

    @IBOutlet var svMain: UIScrollView!
    @IBOutlet var vContent: UIView!
    @IBOutlet var txtGameName: UITextField!
    @IBOutlet var tvDescription: UITextView!
    
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
    
    @IBOutlet var btnCurrentLocation: UIButton!
    @IBOutlet var btnSelectLocation: UIButton!
    @IBOutlet var txtLocation: UITextField!
    
    @IBOutlet var btnExpNoExp: UIButton!
    @IBOutlet var btnExpRecreational: UIButton!
    @IBOutlet var btnExpHighSchool: UIButton!
    @IBOutlet var btnExpCollege: UIButton!
    @IBOutlet var btnExpPro: UIButton!
    
    @IBOutlet var txtDate: IQDropDownTextField?
    @IBOutlet var txtTimeRange: IQDropDownTextField?
    
    @IBOutlet var btnCreateGame: UIButton!
    
    var sportArray = ["Basketball", "Baseball", "Soccer", "Volleyball"]
    var sportAnswer = ""
    var skillAnswer = ""
    
    var ref:FIRDatabaseReference!
    var geocoder = CLGeocoder()
    var user: FIRUser!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

    @IBAction func createGameButton(sender: AnyObject) {
        
        if txtDate!.date > NSDate() {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "invalid end date!")
            return
        }
//        else if txtEndDate!.date > txtStartDate!.date {
//            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "invalid end date!")
//            return
//        }
        
        let MyUserID = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        let startTimestamp = (txtDate?.date ?? NSDate()).timeIntervalSince1970
        //let endTimestamp = (txtEndDate?.date ?? NSDate()).timeIntervalSince1970
        
        let game:[NSObject : AnyObject] = ["locName":self.txtLocation.text!,"sport":sportAnswer, "lat": selectedLocation!.coordinate.latitude, "long": selectedLocation!.coordinate.longitude, "gameCreator": MyUserID!, "skillLevel": txtLocation.text!, "groupName": skillAnswer, "gameNotes": "", "timestamp": timestamp, "startTimestamp": startTimestamp, "endTimestamp": "10:00 - 16:00"]
        
        ref.child("games").child("active").childByAutoId().updateChildValues(game) { (error, ref) in
            if error == nil {
                //CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Game saved successfully!")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Opps,we are uable to create game!")
            }
        }
    }
    
    @IBAction func SportAction(sender: UIButton) {
        vBasketball.backgroundColor = UIColor.whiteColor()
        lblBasketball.textColor = UIColor.blackColor()
        vBaseball.backgroundColor = UIColor.whiteColor()
        lblBasketball.textColor = UIColor.blackColor()
        vSoccer.backgroundColor = UIColor.whiteColor()
        lblBasketball.textColor = UIColor.blackColor()
        vVoleyball.backgroundColor = UIColor.whiteColor()
        lblBasketball.textColor = UIColor.blackColor()
        
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
    
    @IBAction func skillLevelAction(sender: UIButton) {
        
        btnExpNoExp.backgroundColor = UIColor.whiteColor()
        btnExpNoExp.titleLabel?.textColor = UIColor.blackColor()
        btnExpRecreational.backgroundColor = UIColor.whiteColor()
        btnExpRecreational.titleLabel?.textColor = UIColor.blackColor()
        btnExpHighSchool.backgroundColor = UIColor.whiteColor()
        btnExpHighSchool.titleLabel?.textColor = UIColor.blackColor()
        btnExpCollege.backgroundColor = UIColor.whiteColor()
        btnExpCollege.titleLabel?.textColor = UIColor.blackColor()
        btnExpPro.backgroundColor = UIColor.whiteColor()
        btnExpPro.titleLabel?.textColor = UIColor.blackColor()
        
        sender.backgroundColor = UIColor.blackColor()
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        if sender == btnExpNoExp {
            skillAnswer = "No Experience"
        } else if sender == btnExpRecreational {
            skillAnswer = "Recreational"
        } else if sender == btnExpHighSchool {
            skillAnswer = "High School"
        } else if sender == btnExpCollege {
            skillAnswer = "College"
        } else if sender == btnExpPro {
            skillAnswer = "Pro"
        }
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
        secondVC.locationString = self.txtLocation.text
        
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
            txtLocation.text = LocationDetail
        }
    }
}
