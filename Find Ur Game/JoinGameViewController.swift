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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        ref.child("players").child(filteredPlaces[activePlace]["key"] ?? "").observeEventType(.Value, withBlock: { (snapshot) in
            if let  players = snapshot.valueInExportFormat() as? NSDictionary {
                for (key,value) in players.enumerate() {
                    self.users.append(["key":"\(key)","name":"\(value)"])
                }
            }
            print(self.users)
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
        
        let enroll:[String:AnyObject] = ["uid":(FIRAuth.auth()?.currentUser?.uid ?? ""), "name" : "\((FIRAuth.auth()?.currentUser?.displayName ?? "My Name"))"];
        ref.child("players").child(filteredPlaces[activePlace]["key"] ?? "").child(FIRAuth.auth()?.currentUser?.uid ?? "").setValue(enroll)
        
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
        if filteredPlaces.count == 0 {
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
            return filteredPlaces.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell") 
        
        cell.textLabel?.text = "test"
        
        return cell
    }
}