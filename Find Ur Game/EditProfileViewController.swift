//
//  EditProfileViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

import FBSDKLoginKit
import Firebase

import SDWebImage
import UIActivityIndicator_for_SDWebImage

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var facebook: UIButton!
    
    @IBOutlet var imgBackGProfile: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var btnProfileImg: UIButton!
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var tvAboutMe: UITextView!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var dobField: UITextField!
    @IBOutlet var heightField: UITextField!
    @IBOutlet var weightField: UITextField!
    
    @IBOutlet var vBasketball: UIView!
    @IBOutlet var btnBasketball: UIButton!
    @IBOutlet var lblBasketball: UILabel!
    @IBOutlet var lblSkillBasketball: UILabel!
    
    @IBOutlet var vSoccer: UIView!
    @IBOutlet var btnSoccer: UIButton!
    @IBOutlet var lblSoccer: UILabel!
    @IBOutlet var lblSkillSoccer: UILabel!
    
    @IBOutlet var vBaseball: UIView!
    @IBOutlet var btnBaseball: UIButton!
    @IBOutlet var lblBaseball: UILabel!
    @IBOutlet var lblSkillBaseball: UILabel!
    
    @IBOutlet var vVoleyball: UIView!
    @IBOutlet var btnVoleyball: UIButton!
    @IBOutlet var lblVoleyball: UILabel!
    @IBOutlet var lblSkillVoleyball: UILabel!
    
    @IBOutlet var vExpLevelOverlay: UIView!
    @IBOutlet var vExpLevel: UIView!
    @IBOutlet var btnCloseSkillLevelView: UIButton!
    @IBOutlet var lblSkillForSport: UILabel!
    @IBOutlet var btnExpNoExp: UIButton!
    @IBOutlet var btnExpRecreational: UIButton!
    @IBOutlet var btnExpHighSchool: UIButton!
    @IBOutlet var btnExpCollege: UIButton!
    @IBOutlet var btnExpPro: UIButton!
    
    var imgTaken = false
    var finalFeet:String = ""
    var finalInch:String = ""
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    var pickOptionFeet:[String] = ["3'", "4'", "5'", "6'", "7'"]
    var pickOptionInch:[String] = ["1\"","2\"","3\"","4\"", "5\"", "6\"", "7\"", "8\"", "9\"", "10\"", "11\"","12\""]
    
    var sportAnswer = ""
    var skillsAnswer = ["No Experience", "No Experience", "No Experience", "No Experience"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfile.setCornerRadious(imgProfile.frame.width/2)
        //imgProfile.setBorder(1, color: clrGreen)
        imgBackGProfile.setCornerRadious(imgBackGProfile.frame.width/2)
        
        vBasketball.setCornerRadious(4)
        vBaseball.setCornerRadious(4)
        vSoccer.setCornerRadious(4)
        vVoleyball.setCornerRadious(4)
        
        firstNameField.setCornerRadious(4)
        lastNameField.setCornerRadious(4)
        phoneField.setCornerRadious(4)
        dobField.setCornerRadious(4)
        heightField.setCornerRadious(4)
        weightField.setCornerRadious(4)
        
        firstNameField.setLeftMargin(8)
        lastNameField.setLeftMargin(8)
        phoneField.setLeftMargin(8)
        dobField.setLeftMargin(8)
        heightField.setLeftMargin(8)
        weightField.setLeftMargin(8)
        
        btnBasketball.setCornerRadious(4)
        //SportAction(btnBasketball)
        
        self.vExpLevelOverlay.alpha = 0
        vExpLevel.setCornerRadious(6)
        btnExpNoExp.setCornerRadious(4)
        btnExpHighSchool.setCornerRadious(4)
        btnExpCollege.setCornerRadious(4)
        btnExpRecreational.setCornerRadious(4)
        btnExpPro.setCornerRadious(4)
        btnCloseSkillLevelView.setCornerRadious(btnCloseSkillLevelView.frame.width/2)
        
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        heightField.inputView = pickerView
        
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.phoneField.delegate = self
        self.dobField.delegate = self
        self.heightField.delegate = self
        self.weightField.delegate = self
        
//        if let row = data.indexOf(selected) {
//            picker.selectRow(row, inComponent: 0, animated: false)
//        }
        
        print(myUserID)
        CommonUtils.sharedUtils.showProgress(self.view, label:"Loading..")
        ref.child("users").child(myUserID!).observeEventType(.Value, withBlock: { (snapshot) in
            
            CommonUtils.sharedUtils.hideProgress()
            
            AppState.sharedInstance.currentUser = snapshot
            self.firstNameField.text = snapshot.value!["userFirstName"] as? String ?? ""
            self.lastNameField.text = snapshot.value!["userLastName"] as? String ?? ""
            
            self.phoneField.text = snapshot.value!["userPhoneNumber"] as? String ?? ""
            self.dobField.text = snapshot.value!["userDOB"] as? String ?? ""
            self.heightField.text = snapshot.value!["userHeight"] as? String ?? ""
            self.weightField.text = snapshot.value!["userWeight"] as? String ?? ""
            
            if let aboutMe = snapshot.value!["aboutMe"] as? String {
                self.tvAboutMe.text =  aboutMe
                self.tvAboutMe.textColor = UIColor.blackColor()
            } else {
                self.tvAboutMe.text = txtPlaceHAboutMe
                self.tvAboutMe.textColor = UIColor.lightGrayColor()
            }
            
            self.skillsAnswer[0] = snapshot.value!["basketball"] as? String ?? "-"
            self.skillsAnswer[1] = snapshot.value!["baseball"] as? String ?? "-"
            self.skillsAnswer[2] = snapshot.value!["soccer"] as? String ?? "-"
            self.skillsAnswer[3] = snapshot.value!["volleyball"] as? String ?? "-"
            
            self.lblSkillBasketball.text = self.skillsAnswer[0]
            self.lblSkillBaseball.text = self.skillsAnswer[1]
            self.lblSkillSoccer.text = self.skillsAnswer[2]
            self.lblSkillVoleyball.text = self.skillsAnswer[3]
            
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
        })
        { (error) in
            print(error.localizedDescription)
        }
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
        //return pickOption[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            finalFeet = String(pickOptionFeet[row])
        } else {
            finalInch = String(pickOptionInch[row])
        }
        print("feet", finalFeet, "inch ", finalInch)
        heightField.text = finalFeet + " " + finalInch
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
    
    @IBAction func actionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
            //vBasketball.backgroundColor = clrBlackSelected
            //lblBasketball.textColor = UIColor.whiteColor()
            ShowGameDetail(sportAnswer, index: 0)
        } else if sender == btnBaseball {
            sportAnswer = sportArray[1]
            //vBaseball.backgroundColor = clrBlackSelected
            //lblBaseball.textColor = UIColor.whiteColor()
            ShowGameDetail(sportAnswer, index: 1)
        } else if sender == btnSoccer {
            sportAnswer = sportArray[2]
            //vSoccer.backgroundColor = clrBlackSelected
            //lblSoccer.textColor = UIColor.whiteColor()
            ShowGameDetail(sportAnswer, index: 2)
        } else if sender == btnVoleyball {
            sportAnswer = sportArray[3]
            //vVoleyball.backgroundColor = clrBlackSelected
            //lblVoleyball.textColor = UIColor.whiteColor()
            ShowGameDetail(sportAnswer, index: 3)
        }
    }
    
    // MARK: - UITextView Place holder
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == txtPlaceHAboutMe {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = txtPlaceHAboutMe
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    // MARK: - Game Detail View
    @IBAction func actionCloseSkillLevelView(sender: AnyObject)
    {
        UIView.animateWithDuration(0.5, animations: {
            self.vExpLevelOverlay.alpha = 0
        }) { (completion) in
            print(completion)
        }
        
        if self.btnCloseSkillLevelView.tag == 0 {
            self.lblSkillBasketball.text = self.skillsAnswer[0]
        } else if self.btnCloseSkillLevelView.tag == 1 {
            self.lblSkillBaseball.text = self.skillsAnswer[1]
        } else if self.btnCloseSkillLevelView.tag == 2 {
            self.lblSkillSoccer.text = self.skillsAnswer[2]
        } else if self.btnCloseSkillLevelView.tag == 3 {
            self.lblSkillVoleyball.text = self.skillsAnswer[3]
        }
    }
    
    func ShowGameDetail(sport:String,index:Int)
    {
        UIView.animateWithDuration(0.5, animations: {
            self.vExpLevelOverlay.alpha = 1
        })
        print(sport)
        
        btnCloseSkillLevelView.tag = index
        lblSkillForSport.text = "Select your game level for \(sport)"
        
        btnExpNoExp.backgroundColor = UIColor.whiteColor()
        btnExpNoExp.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpRecreational.backgroundColor = UIColor.whiteColor()
        btnExpRecreational.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpHighSchool.backgroundColor = UIColor.whiteColor()
        btnExpHighSchool.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpCollege.backgroundColor = UIColor.whiteColor()
        btnExpCollege.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpPro.backgroundColor = UIColor.whiteColor()
        btnExpPro.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        var btnSelectedSkill = btnExpNoExp
        
        if skillsAnswer[index] == skillsArray[0] {
            btnSelectedSkill = btnExpNoExp
        } else if skillsAnswer[index] == skillsArray[1] {
            btnSelectedSkill = btnExpRecreational
        } else if skillsAnswer[index] == skillsArray[2] {
            btnSelectedSkill = btnExpHighSchool
        } else if skillsAnswer[index] == skillsArray[3] {
            btnSelectedSkill = btnExpCollege
        } else if skillsAnswer[index] == skillsArray[4] {
            btnSelectedSkill = btnExpPro
        }
        
        btnSelectedSkill.backgroundColor = clrBlackSelected
        btnSelectedSkill.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    @IBAction func skillLevelAction(sender: UIButton) {
        
        btnExpNoExp.backgroundColor = UIColor.whiteColor()
        btnExpNoExp.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpRecreational.backgroundColor = UIColor.whiteColor()
        btnExpRecreational.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpHighSchool.backgroundColor = UIColor.whiteColor()
        btnExpHighSchool.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpCollege.backgroundColor = UIColor.whiteColor()
        btnExpCollege.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnExpPro.backgroundColor = UIColor.whiteColor()
        btnExpPro.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        sender.backgroundColor = clrBlackSelected
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        var skill = skillsAnswer[btnCloseSkillLevelView.tag]
        if sender == btnExpNoExp {
            skill = "No Experience"
        } else if sender == btnExpRecreational {
            skill = "Recreational"
        } else if sender == btnExpHighSchool {
            skill = "High School"
        } else if sender == btnExpCollege {
            skill = "College"
        } else if sender == btnExpPro {
            skill = "Pro"
        }
        skillsAnswer[btnCloseSkillLevelView.tag] = skill
        self.actionCloseSkillLevelView(btnCloseSkillLevelView)
    }
    
    // MARK: - Update Profile
    @IBAction func saveProfile(sender: AnyObject)
    {
        // make sure the user entered both email & password
        //Validate email,password,name,height,weight
        
        if firstNameField.text == "" || firstNameField.text?.characters.count < 3 ||
            lastNameField.text == "" || lastNameField.text?.characters.count < 3
        {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Required you name!")
            return
        }
        else if heightField.text == "" ||
            weightField.text == ""
        {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Please add your height and weight!")
            return
        }
        
        if imgTaken == false {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
            self.saveProfile(nil, imgPath: nil)
        } else {
            self.saveImage { (downloadURL,imgPath) in
                self.saveProfile(downloadURL,imgPath: imgPath)
            }
        }
    }
    
    func saveProfile(ProfileUrl:String?,imgPath:String?) {
        let fName = self.firstNameField.text ?? ""
        let lName = self.lastNameField.text ?? ""
        
        var data:Dictionary<String,AnyObject> = ["userFirstName": fName,
                                                 "userLastName": lName,
                                                 "name": "\(fName) \(fName)",
                                                 "isProfileSet": "1",
                                                 //"userSport": self.sportAnswer,
            "basketball": self.skillsAnswer[0],
            "baseball": self.skillsAnswer[1],
            "soccer": self.skillsAnswer[2],
            "volleyball": self.skillsAnswer[3],
            "userPhoneNumber": self.phoneField.text ?? "",
            "userDOB": self.dobField.text!,
            "userHeight": self.heightField.text ?? "",
            "userWeight": self.weightField.text ?? "",
            "aboutMe": self.tvAboutMe.text ?? ""]
        
        if ProfileUrl != nil && imgPath != nil
        {
            data["userProfile"] = ProfileUrl
            data["userProfilePath"] = imgPath
        }
        
        print(data)
        self.ref.child("users").child(myUserID!).updateChildValues(data) { (error, ref) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                })
            }
        }
    }
    
    func saveImage(onCompletion:(downloadURL:String,imagePath:String)->Void)
    {
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        let imgData: NSData = UIImageJPEGRepresentation(imgProfile.image!, 0.7)!
        let imgPath = "images/\(NSDate().timeIntervalSince1970).jpg"
        // Create a reference to the file you want to upload
        let imagesRef = storageRef.child(imgPath)
        
        let uploadTask = imagesRef.putData(imgData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print(error)
                CommonUtils.sharedUtils.hideProgress()
            } else {
                print(metadata)
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()?.absoluteString ?? ""
                print(downloadURL,imgPath)
                onCompletion(downloadURL: downloadURL,imagePath: imgPath)
            }
        }
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
        // 1
        view.endEditing(true)
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .Camera
                                                imagePicker.allowsEditing = true
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 4
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .Default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .PhotoLibrary
                                            imagePicker.allowsEditing = true
                                            self.presentViewController(imagePicker,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        // 6
        presentViewController(imagePickerActionSheet, animated: true,
                              completion: nil)
    }
    
    // Image picker Delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgProfile.image = editedImage
            //imgProfile.image = self.scaleImage(pickedImage, maxDimension: 300)
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfile.contentMode = .ScaleAspectFit
            imgProfile.image = pickedImage
        }
        
        self.imgTaken = true
        dismissViewControllerAnimated(true, completion: nil)
    }
}

