//
//  JoinGameViewController.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class JoinGameViewController: UIViewController {
    
    static var gameName = ""
    static var gameTime = Double.self
    static var currentGame = ""
    static var gameID = ""
    var users:[Dictionary<String,String>] = []
    
    var user: FIRUser!
    var ref:FIRDatabaseReference!
    
    @IBOutlet var lblDetailDesc: UILabel!
    @IBOutlet var tblUsers: UITableView!
    @IBOutlet var btnJoin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnJoin.hidden = true
        
        ref = FIRDatabase.database().reference()
        ref.child("players").child(filteredPlaces[activePlace]["key"] ?? "").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var isJoined = false
            for child in snapshot.children {
                var userDict = Dictionary<String,String>()
                let childDict = child.valueInExportFormat() as! NSDictionary
                for key : AnyObject in childDict.allKeys {
                    let stringKey = key as! String
                    if let keyValue = childDict.valueForKey(stringKey) as? String {
                        userDict[stringKey] = keyValue
                        if keyValue == FIRAuth.auth()!.currentUser!.uid {
                            isJoined = true
                        }
                    }
                }
                print(userDict)
                self.users.append(userDict)
            }
            self.btnJoin.hidden = isJoined
            self.tblUsers.reloadData()
        })
        
        var descString = ""
        if let groupName = filteredPlaces[activePlace]["groupName"] {
            descString += "Name of Game: \(groupName) \n\n"
        }
        
        if let gameNotes = filteredPlaces[activePlace]["gameNotes"] {
            descString += "Game Notes: \(gameNotes) \n"
        }

        lblDetailDesc.text = "\(descString)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func joinGameButton(sender: AnyObject) {
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Joining..")
        let enroll:[String:AnyObject] = ["uid":(FIRAuth.auth()?.currentUser?.uid ?? ""), "name" : "\((FIRAuth.auth()?.currentUser?.displayName ?? "My Name"))"];
        ref.child("players").child(filteredPlaces[activePlace]["key"] ?? "").child(FIRAuth.auth()?.currentUser?.uid ?? "").setValue(enroll) { (error, ref) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "opps,Failed to join!")
            }
        }
        
        func signedIn(user: FIRUser?) {
            let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if users.count == 0 {
            let emptyLabel = UILabel(frame: tableView.frame)
            emptyLabel.text = "Are you want to join this game?"
            emptyLabel.textColor = UIColor.lightGrayColor();
            emptyLabel.textAlignment = .Center;
            emptyLabel.numberOfLines = 3
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            tableView.backgroundView = nil
            return users.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell") 
        
        cell.textLabel?.text = users[indexPath.row]["name"] ?? ""
        
        let uid = users[indexPath.row]["uid"] ?? ""
        
        ref.child("users").child(uid).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            if snapshot.exists() {
                if let data = snapshot.valueInExportFormat() as? NSDictionary {
                    let fname:String = data["userFirstName"] as? String ?? ""
                    let lname:String = data["userLastName"] as? String ?? ""
                    cell.textLabel?.text = "\(fname) \(lname)"
                }
            }
        }
        
        return cell
    }
}