//
//  ProfileSkillsViewController.swift
//  Ballpoint
//
//  Created by Dustin Allen on 7/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class ProfileSkillsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var skillSlider: UISlider!
    @IBOutlet var oftenSlider: UISlider!
    @IBOutlet var styleSlider: UISlider!
    @IBOutlet var skillAnswer: UILabel!
    @IBOutlet var oftenAnswer: UILabel!
    @IBOutlet var styleAnswer: UILabel!
    @IBOutlet var shoe: UITextField!
    @IBOutlet var age: UITextField!
    var ref:FIRDatabaseReference!
    var user: FIRUser!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        self.shoe.delegate = self
        self.age.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func skillSliderChange(sender: AnyObject) {
        sender.setValue(Float(lroundf(skillSlider.value)), animated: true)
        if skillSlider.value == 1 {
            skillAnswer.text = "Beginner"
        }
        if skillSlider.value == 2 {
            skillAnswer.text = "Novice"
        }
        if skillSlider.value == 3 {
            skillAnswer.text = "Hooper"
        }
        if skillSlider.value == 4 {
            skillAnswer.text = "Baller"
        }
        if skillSlider.value == 5 {
            skillAnswer.text = "All-Star"
        }
    }
    @IBAction func oftenSliderChange(sender: AnyObject) {
        sender.setValue(Float(lroundf(oftenSlider.value)), animated: true)
        if oftenSlider.value == 1 {
            oftenAnswer.text = "Multiple Times Daily"
        }
        if oftenSlider.value == 2 {
            oftenAnswer.text = "I Play Everyday"
        }
        if oftenSlider.value == 3 {
            oftenAnswer.text = "Every Few Days"
        }
        if oftenSlider.value == 4 {
            oftenAnswer.text = "Once A Week"
        }
        if oftenSlider.value == 5 {
            oftenAnswer.text = "Here & There"
        }
    }
    @IBAction func styleSliderChange(sender: AnyObject) {
        sender.setValue(Float(lroundf(styleSlider.value)), animated: true)
        if styleSlider.value == 1 {
            styleAnswer.text = "1 on 1"
        }
        if styleSlider.value == 2 {
            styleAnswer.text = "2 on 2"
        }
        if styleSlider.value == 3 {
            styleAnswer.text = "3 on 3"
        }
        if styleSlider.value == 4 {
            styleAnswer.text = "4 on 4"
        }
        if styleSlider.value == 5 {
            styleAnswer.text = "5 on 5"
        }
    }
    @IBAction func createProfile(sender: AnyObject) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        self.ref.child("users").child(user!.uid).setValue(["userSkillLevel": self.skillAnswer.text!, "userOftenLevel": self.oftenAnswer.text!, "userStyleLevel": self.styleAnswer.text!, "userShoe": self.shoe.text!, "userAge": self.age.text!])
        
        CommonUtils.sharedUtils.hideProgress()
        let signUpSocialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TheMainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(signUpSocialViewController, animated: true)
    }
}
