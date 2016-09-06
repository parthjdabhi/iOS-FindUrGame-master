//
//  SignUpViewController.swift
//  Ballpoint
//
//  Created by Dustin Allen on 7/2/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var facebook: UIButton!
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    //@IBOutlet var phoneField: UITextField!
    @IBOutlet var dobField: UITextField!
    @IBOutlet var heightField: UITextField!
    @IBOutlet var weightField: UITextField!
    
    var finalFeet:String = ""
    var finalInch:String = ""
    var ref:FIRDatabaseReference!
    var pickOptionFeet:[String] = ["3'", "4'", "5'", "6'", "7'"]
    var pickOptionInch:[String] = ["1\"","2\"","3\"","4\"", "5\"", "6\"", "7\"", "8\"", "9\"", "10\"", "11\"","12\""]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        heightField.inputView = pickerView
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        //self.phoneField.delegate = self
        self.dobField.delegate = self
        self.heightField.delegate = self
        self.weightField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickOptionFeet.count
        }
            
        else {
            return pickOptionInch.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(pickOptionFeet[row])
        } else {
            
            return String(pickOptionInch[row])
        }
//        return pickOption[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            finalFeet = String(pickOptionFeet[row])
        } else {
            finalInch = String(pickOptionInch[row])
        }
        print("final feet", finalFeet, "inch ", finalInch)
        heightField.text = finalFeet + " " + finalInch
    }
    
    @IBAction func facebookSignUp(sender: AnyObject) {
        let manager = FBSDKLoginManager()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    else {
                        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            if ((error) != nil) {
                                // Process error
                                print("Error: \(error)")
                            } else {
                                print("fetched user: \(result)")
                                
                                let fName = result.valueForKey("first_name") as? String ?? ""
                                let lName = result.valueForKey("last_name") as? String ?? ""
                                
                                let data = [ "facebookData": ["userFirstName": fName,
                                    "userLastName": lName,
                                    "gender": result.valueForKey("gender") as? String ?? "",
                                    "email": result.valueForKey("email") as? String ?? ""],
                                    "userFirstName": fName,
                                    "userLastName": lName,
                                    "email": result.valueForKey("email") as? String ?? "",
                                    "name": "\(fName) \(fName)" ]
                                
                                self.ref.child("users").child(user!.uid).setValue(data)
                                
                                if let picture = result.objectForKey("picture") {
                                    if let pictureData = picture.objectForKey("data"){
                                        if let pictureURL = pictureData.valueForKey("url") {
                                            print(pictureURL)
                                            self.ref.child("users").child(user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                        }
                                    }
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    @IBAction func createProfile(sender: AnyObject)
    {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    let fName = self.firstNameField.text ?? ""
                    let lName = self.lastNameField.text ?? ""
                    
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": fName,
                        "userLastName": lName,
                        "email": email,
                        //"userPhoneNumber": self.phoneField.text!,
                        "userDOB": self.dobField.text!,
                        "userHeight": self.heightField.text!,
                        "userWeight": self.weightField.text!,
                        "name": "\(fName) \(fName)"])
                    CommonUtils.sharedUtils.hideProgress()
                    
                    //after we directly get user picture in sign up screen
                    //let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                    //self.navigationController?.pushViewController(photoViewController, animated: true)
                    
                    self.navigationController?.pushViewController(MyTabBarViewController.init(), animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
    }
    
    
    @IBAction func dobChange(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dobField.text = dateFormatter.stringFromDate(sender.date)
        
    }
}
