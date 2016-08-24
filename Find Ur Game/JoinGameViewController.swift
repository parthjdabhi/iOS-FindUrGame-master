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
    
    var user: FIRUser!
    var ref:FIRDatabaseReference!
    
    @IBOutlet var lblDetailDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
//        ref.child("games").child("active").observeEventType(.Value, withBlock: { (snapshot) in
//            for child in snapshot.children {
//                let group = child.childSnapshotForPath("groupName").value
//                let groupString = group as! String!
//                print(groupString)
//                let gameNotes = child.childSnapshotForPath("gameNotes").value
//                let gameNotesString = gameNotes as! String!
//                print(gameNotesString)
//                let lat = child.childSnapshotForPath("lat").value
//                let userLat = lat as! Double!
//                print(userLat)
//                let long = child.childSnapshotForPath("long").value
//                let userLong = long as! Double!
//                print(userLong)
//                let sport = child.childSnapshotForPath("sport").value
//                let sportGame = sport as! String!
//                print(sportGame)
//                let skill = child.childSnapshotForPath("skillLevel").value
//                let skillLevel = skill as! String!
//                print(skillLevel)
//                let gameCreator = child.childSnapshotForPath("gameCreator").value
//                let gameCreatorString = gameCreator as! String!
//                print(gameCreatorString)
//                let timestamp = child.childSnapshotForPath("timestamp").value
//                let timestampString = timestamp as! Double!
//                print(timestampString)
//                
//                let geoCoder = CLGeocoder()
//                let location = CLLocation(latitude: userLat, longitude: userLong)
//                geoCoder.reverseGeocodeLocation(location)
//                {
//                    (placemarks, error) -> Void in
//                    let placeArray = placemarks as [CLPlacemark]!
//                    
//                    // Place details
//                    var placeMark: CLPlacemark!
//                    placeMark = placeArray?[0]
//                    
//                    // Address dictionary
//                    print(placeMark.addressDictionary)
//                    
//                    // Location name
//                    let locationName = placeMark.addressDictionary?["Name"] as! String!
//                    print(locationName)
//                    
//                    // Street address
//                    let street = placeMark.addressDictionary?["Thoroughfare"] as! String!
//                    
//                    // City
//                    let city = placeMark.addressDictionary?["City"] as! String!
//                    
//                    // Zip code
//                    let zip = placeMark.addressDictionary?["ZIP"] as! String!
//                    
//                    // Country
//                    let country = placeMark.addressDictionary?["Country"] as! String!
//                    print(country)
//                    
//                    let currentGame = places
//                    
//        /*
//        if places.count >= 1 {
//            places.removeAtIndex(0)
//            places.append(["name":"\(groupString) -- \(street), \(city) \(zip)","lat":"\(userLat)","lon":"\(userLong)"])
//        }*/}
//        }
//    })
        var descString = ""
        if let groupName = places[activePlace]["groupName"] {
            descString += "Name of Game: \(groupName) \n\n"
        }
        
        if let gameNotes = places[activePlace]["gameNotes"] {
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
        
        func signedIn(user: FIRUser?) {
            let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        }
    }
}