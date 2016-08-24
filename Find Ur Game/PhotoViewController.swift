//
//  PhotoViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class PhotoViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet var soccer: UISlider!
    @IBOutlet var volleyball: UISlider!
    @IBOutlet var baseball: UISlider!
    @IBOutlet var soccerExperienceLabel: UILabel!
    @IBOutlet var volleyballExperienceLabel: UILabel!
    @IBOutlet var basballExperienceLabel: UILabel!
    @IBOutlet var experienceLabel: UILabel!
    @IBOutlet var experienceSlider: UISlider!
    @IBOutlet var profileInfo: UITextView!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var imgTaken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        let borderColor : UIColor = UIColor.blackColor()
        profileInfo.layer.borderWidth = 1
        profileInfo.layer.borderColor = borderColor.CGColor
        profileInfo.layer.cornerRadius = 5.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        profileInfo.text = ""
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var photo: UIImageView!
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

    @IBAction func nextButton(sender: AnyObject) {
        ///*
        if imgTaken == false {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
            return
        }
        //*/
        
        let uploadImage : UIImage = photo.image!
        let base64String = self.imgToBase64(uploadImage)
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading image...")
        
        ref.child("users").child(userID!).child("image").setValue(base64String) { (error, firebase) in
            CommonUtils.sharedUtils.hideProgress()
        self.ref.child("users").child(userID!).updateChildValues(["basketball": self.experienceLabel.text!, "soccer": self.soccerExperienceLabel.text!, "volleyball": self.volleyballExperienceLabel.text!, "baseball": self.basballExperienceLabel.text!, "userInfo": self.profileInfo.text!])
            if error == nil {
                let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                self.navigationController?.pushViewController(mainScreenViewController, animated: true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Failed uploading profile image")
            }
        }
    }
    
    @IBAction func skillSlider(sender: AnyObject) {
        sender.setValue(Float(lroundf(experienceSlider.value)), animated: true)
        if experienceSlider.value == 1 {
            experienceLabel.text = "No Experience"
        }
        if experienceSlider.value == 2 {
            experienceLabel.text = "Recreational"
        }
        if experienceSlider.value == 3 {
            experienceLabel.text = "High School"
        }
        if experienceSlider.value == 4 {
            experienceLabel.text = "College"
        }
        if experienceSlider.value == 5 {
            experienceLabel.text = "Pro"
        }
    }
    
    @IBAction func baseballSlider(sender: AnyObject) {
        sender.setValue(Float(lroundf(baseball.value)), animated: true)
        if baseball.value == 1 {
            basballExperienceLabel.text = "No Experience"
        }
        if baseball.value == 2 {
            basballExperienceLabel.text = "Recreational"
        }
        if baseball.value == 3 {
            basballExperienceLabel.text = "High School"
        }
        if baseball.value == 4 {
            basballExperienceLabel.text = "College"
        }
        if baseball.value == 5 {
            basballExperienceLabel.text = "Pro"
        }
    }
    
    @IBAction func volleyballSlider(sender: AnyObject) {
        sender.setValue(Float(lroundf(volleyball.value)), animated: true)
        if volleyball.value == 1 {
            volleyballExperienceLabel.text = "No Experience"
        }
        if volleyball.value == 2 {
            volleyballExperienceLabel.text = "Recreational"
        }
        if volleyball.value == 3 {
            volleyballExperienceLabel.text = "High School"
        }
        if volleyball.value == 4 {
            volleyballExperienceLabel.text = "College"
        }
        if volleyball.value == 5 {
            volleyballExperienceLabel.text = "Pro"
        }
    }

    
    @IBAction func soccerExperience(sender: AnyObject) {
        sender.setValue(Float(lroundf(soccer.value)), animated: true)
        if soccer.value == 1 {
            soccerExperienceLabel.text = "No Experience"
        }
        if soccer.value == 2 {
            soccerExperienceLabel.text = "Recreational"
        }
        if soccer.value == 3 {
            soccerExperienceLabel.text = "High School"
        }
        if soccer.value == 4 {
            soccerExperienceLabel.text = "College"
        }
        if soccer.value == 5 {
            soccerExperienceLabel.text = "Pro"
        }
    }
    
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // Activity Indicator methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photo.contentMode = .ScaleAspectFit
            photo.image = self.scaleImage(pickedImage, maxDimension: 300)
        }
        
        self.imgTaken = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imgToBase64(image: UIImage) -> String {
        let imageData:NSData = UIImagePNGRepresentation(image)!
        let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(base64String)
        
        return base64String
    }
    
    
    
}
