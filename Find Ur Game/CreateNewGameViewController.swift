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
import MapKit

import IQKeyboardManagerSwift
import IQDropDownTextField

/*
 green color(basket ball) : #1abc9c
 basketball bg color : #222831
 black color : #222831
 */

class CreateNewGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, SelectLocationDelegate, IQDropDownTextFieldDelegate {

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
    
    @IBOutlet var btnExpNoExp: UIButton!
    @IBOutlet var btnExpRecreational: UIButton!
    @IBOutlet var btnExpHighSchool: UIButton!
    @IBOutlet var btnExpCollege: UIButton!
    @IBOutlet var btnExpPro: UIButton!
    
    @IBOutlet var txtNoOfPlayer: UITextField!
    @IBOutlet var txtDate: IQDropDownTextField?
    @IBOutlet var txtTimeRange: UITextField?
    @IBOutlet var pickerTimeRange: UIPickerView! = UIPickerView()
    //let RangeArray = ["00:00", "00:00", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30"]
    var SH = 12, SM = 0, EH = 12, EM = 0;
    var SMT = "AM",EMT = "AM"
    
    @IBOutlet var btnCurrentLocation: UIButton!
    @IBOutlet var btnSelectLocation: UIButton!
    @IBOutlet var txtLocation: UITextField!
    @IBOutlet weak var mvLocation: MKMapView!
    
    @IBOutlet var btnCreateGame: UIButton!
    
    var sportAnswer = ""
    var skillAnswer = ""
    
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    var geocoder = CLGeocoder()
    var user: FIRUser!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    var getCurrentLocation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        vBasketball.setCornerRadious(4)
        vBaseball.setCornerRadious(4)
        vSoccer.setCornerRadious(4)
        vVoleyball.setCornerRadious(4)
        
        btnExpNoExp.setCornerRadious(4)
        btnExpHighSchool.setCornerRadious(4)
        btnExpCollege.setCornerRadious(4)
        btnExpRecreational.setCornerRadious(4)
        btnExpPro.setCornerRadious(4)
        
        btnCreateGame.setCornerRadious(4)
        
        txtGameName.setCornerRadious(4)
        txtNoOfPlayer.setCornerRadious(4)
        txtDate?.setCornerRadious(4)
        txtTimeRange?.setCornerRadious(4)
        txtLocation.setCornerRadious(4)
        
        txtGameName.setLeftMargin(8)
        txtNoOfPlayer.setLeftMargin(8)
        txtDate?.setLeftMargin(8)
        txtTimeRange?.setLeftMargin(6)
        txtLocation.setLeftMargin(8)
        txtLocation.text = "Select Location"
        
        let startDateFormat = NSDateFormatter()
        startDateFormat.dateFormat = "dd MMM yyyy"
        
        txtDate?.isOptionalDropDown = false
        txtDate?.dropDownMode = IQDropDownMode.DatePicker
        txtDate?.dateFormatter = startDateFormat
        txtDate?.setDate(NSDate(), animated: true)
        txtDate?.minimumDate = NSDate()
        
        txtTimeRange?.inputView = pickerTimeRange
        //txtTimeRange?.text = "12:00AM - 12:00AM"
        txtTimeRange?.text = "\(String(format: "%02d:%02d\(SMT) - %02d:%02d\(EMT)", SH,SM, EH, EM))"
        pickerTimeRange.delegate = self
        pickerTimeRange.dataSource = self
        
        self.initLocationManager()
        
        SportAction(btnBasketball)
        skillLevelAction(btnExpNoExp)
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

    @IBAction func createGameButton(sender: AnyObject)
    {
        if txtGameName.text == "" || txtGameName.text?.characters.count <= 4 {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Invalid game name!")
            return
        }
        else if txtLocation.text == "Select Location" || selectedLocation == nil {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Please select location for game!")
            return
        }
        else if tvDescription.text == "Description" {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Please some game description!")
            return
        }
        else if Int(txtNoOfPlayer.text ?? "11") < 4 {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "There should be minimum 4 player that can join your game!")
            return
        }
//        else if txtEndDate!.date > txtStartDate!.date {
//            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "invalid end date!")
//            return
//        }
        
        let timestamp = NSDate().timeIntervalSince1970
        let startTimestamp = (txtDate?.date ?? NSDate()).timeIntervalSince1970
        //let endTimestamp = (txtEndDate?.date ?? NSDate()).timeIntervalSince1970
        
        var game:[NSObject : AnyObject] = ["locName":self.txtLocation.text!,"sport":sportAnswer, "lat": selectedLocation!.coordinate.latitude, "long": selectedLocation!.coordinate.longitude, "gameCreator": myUserID!, "skillLevel": skillAnswer, "groupName": txtGameName.text!, "gameNotes": tvDescription.text,"noOfPlayer": (txtNoOfPlayer.text ?? "11"), "timestamp": timestamp, "startTimestamp": startTimestamp, "endTimestamp": txtTimeRange?.text ?? ""]
        game["activeStatus"] = "active"
        print(game)
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading..")
        ref.child("games").child("active").childByAutoId().updateChildValues(game) { (error, ref) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Game saved successfully!")
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
            vBasketball.backgroundColor = clrBlackSelected
            lblBasketball.textColor = UIColor.whiteColor()
        } else if sender == btnBaseball {
            sportAnswer = sportArray[1]
            vBaseball.backgroundColor = clrBlackSelected
            lblBaseball.textColor = UIColor.whiteColor()
        } else if sender == btnSoccer {
            sportAnswer = sportArray[2]
            vSoccer.backgroundColor = clrBlackSelected
            lblSoccer.textColor = UIColor.whiteColor()
        } else if sender == btnVoleyball {
            sportAnswer = sportArray[3]
            vVoleyball.backgroundColor = clrBlackSelected
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
        
        sender.backgroundColor = clrBlackSelected
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
    
    @IBAction func actionGetCurrentLocation(sender: AnyObject) {
        getCurrentLocation = true
        locationManager.startUpdatingLocation()
    }
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 4
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return (component == 0 || component == 2) ? 24 : 60
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0 || component == 2) {
            return "\(String(format: "%02d", (row%12 == 0) ? 12 : row%12 ))"
        } else if (component == 1 || component == 3) {
            return "\(String(format: "%02d", row))"
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("select : \(component) - \(row)")
        //pickerBizCat.hidden = true;
        switch component {
        case 0:
            SH = (((row % 12) == 0) ? 12 : (row % 12))
            SMT = (row <= 11) ? "AM" : "PM"
        case 1:
            SM = row
        case 3:
            EH = (((row % 12) == 0) ? 12 : (row % 12))
            SMT = (row <= 11) ? "AM" : "PM"
        case 4:
            SM = row
        default:
            print(component)
        }
        txtTimeRange?.text = "\(String(format: "%02d:%02d\(SMT) - %02d:%02d\(EMT)", SH,SM, EH, EM))"
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
            
            let center = CLLocationCoordinate2D(latitude: CLocation.coordinate.latitude, longitude: CLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mvLocation.setRegion(region, animated: true)
            mvLocation.removeAnnotations(mvLocation.annotations)
            AddAnnotationAtCoord(center)
            
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
            && LocationDetail?.characters.count > 3) || (getCurrentLocation == true)
        {
            getCurrentLocation = false
            self.selectedLocation = Location
            txtLocation.text = LocationDetail
            
            let center = CLLocationCoordinate2D(latitude: Location?.coordinate.latitude ?? 0, longitude: Location?.coordinate.longitude ?? 0)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mvLocation.setRegion(region, animated: true)
            mvLocation.removeAnnotations(mvLocation.annotations)
            AddAnnotationAtCoord(self.selectedLocation!.coordinate)
        }
    }
    
    func AddAnnotationAtCoord(Coord: CLLocationCoordinate2D)
    {
        let newAnotation = MKPointAnnotation()
        newAnotation.coordinate = Coord
        newAnotation.title = "Selected Location"
        newAnotation.subtitle = ""
        mvLocation.addAnnotation(newAnotation)
    }
}
