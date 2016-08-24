//
//  TableViewController.swift
//  Memorable Places
//
//  Created by Rob Percival on 13/03/2015.
//  Copyright (c) 2015 Appfish. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

var places:[Dictionary<String,String>] = []
var filteredPlaces:[Dictionary<String,String>] = []
var activePlace = -1

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var user: FIRUser!
    var ref:FIRDatabaseReference!
    var gameNameString = ""
    var filterWithKm = 5
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    @IBOutlet var tblGroups: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        refreshData()
    }
    override func viewWillAppear(animated: Bool) {
        tblGroups.reloadData()
        //refreshData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newPlace" {
            activePlace = -1
        }
    }
    
    func refreshData()
    {
        CommonUtils.sharedUtils.showProgress(self.view, label: "Getting list of games..")
        let myGroup = dispatch_group_create()
        dispatch_group_enter(myGroup)
        ref = FIRDatabase.database().reference()
        ref.child("games").child("active").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            places.removeAll()
            //self.tblGroups.reloadData()
            for child in snapshot.children {
                
                var placeDict = Dictionary<String,String>()
                let childDict = child.valueInExportFormat() as! NSDictionary
                //print(childDict)
                
                //let jsonDic = NSJSONSerialization.JSONObjectWithData(childDict, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<String, AnyObject>;
                for key : AnyObject in childDict.allKeys {
                    let stringKey = key as! String
                    if let keyValue = childDict.valueForKey(stringKey) as? String {
                        placeDict[stringKey] = keyValue
                    } else if let keyValue = childDict.valueForKey(stringKey) as? Double {
                        placeDict[stringKey] = "\(keyValue)"
                    }
                    
                }
                placeDict["key"] = child.key
                
                let group = child.childSnapshotForPath("groupName").value
                let groupString = group as! String!
                print(groupString)
                let gameNotes = child.childSnapshotForPath("gameNotes").value
                let gameNotesString = gameNotes as! String!
                print(gameNotesString)
                let lat = child.childSnapshotForPath("lat").value
                let userLat = lat as! Double!
                print(userLat)
                let long = child.childSnapshotForPath("long").value
                let userLong = long as! Double!
                print(userLong)
                let sport = child.childSnapshotForPath("sport").value
                let sportGame = sport as! String!
                print(sportGame)
                let skill = child.childSnapshotForPath("skillLevel").value
                let skillLevel = skill as! String!
                print(skillLevel)
                let gameCreator = child.childSnapshotForPath("gameCreator").value
                let gameCreatorString = gameCreator as! String!
                print(gameCreatorString)
                let timestamp = child.childSnapshotForPath("timestamp").value
                let timestampString = timestamp as! Double!
                print(timestampString)
                
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: userLat, longitude: userLong)
                dispatch_group_enter(myGroup)
                geoCoder.reverseGeocodeLocation(location)
                {
                    (placemarks, error) -> Void in
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    // Address dictionary
                    print(placeMark.addressDictionary)
                    
                    // Location name
                    let locationName = placeMark.addressDictionary?["Name"] as! String!
                    print(locationName)
                    
                    // Street address
                    let street = placeMark.addressDictionary?["Thoroughfare"] as! String!
                    
                    // City
                    let city = placeMark.addressDictionary?["City"] as! String!
                    
                    // Zip code
                    let zip = placeMark.addressDictionary?["ZIP"] as! String!
                    
                    // Country
                    let country = placeMark.addressDictionary?["Country"] as! String!
                    print(country)
                    
                    //places.removeAtIndex(0)
                    placeDict["title"] = "\(groupString) -- \(street), \(city) \(zip)"
                    //placeDict["lat"] = "\(userLat)"
                    //placeDict["long"] = "\(userLong)"
                    places.append(placeDict)
                    
                    print(placeDict)
                    
                    dispatch_group_leave(myGroup)
                }
            }
            dispatch_group_leave(myGroup)
        })
        dispatch_group_notify(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                // update UI
                CommonUtils.sharedUtils.hideProgress()
                self.filterData()
                self.tblGroups.reloadData()
                print(places)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filterData()
    {
        //Can Filter data
        if filterWithKm == 0 || currentLocation == nil {
            filteredPlaces = places
        } else {
            
            //Filter data with limit
            filteredPlaces = places.filter({ (game:[String : String]) -> Bool in
                if let lat = (game["lat"])?.toDouble(),
                    long = (game["long"])?.toDouble()
                {
                    let loc1 = CLLocation(latitude: lat, longitude: long)
                    let distanceInMeters = currentLocation?.distanceFromLocation(loc1) ?? 0
                    print("distanceInMeters : \(distanceInMeters)")
                    //print(Int(distanceInMeters) < (1000 * Int(filterWithKm)))
                    return (Int(distanceInMeters) < (1000 * Int(filterWithKm)))
                }
                return false
            })
        }
        
        //Sort Data
        if currentLocation != nil && places.count > 0 {
            filteredPlaces = filteredPlaces.sort({ (game1:[String : String], game2:[String : String]) -> Bool in
                    if let lat1 = (game1["lat"])?.toDouble(),
                        long1 = (game1["long"])?.toDouble(),
                        lat2 = (game2["lat"])?.toDouble(),
                        long2 = (game2["long"])?.toDouble()
                    {
                        let loc1 = CLLocation(latitude: lat1, longitude: long1)
                        let loc2 = CLLocation(latitude: lat2, longitude: long2)
                        let distanceInMeters1 = currentLocation?.distanceFromLocation(loc1) ?? 0
                        let distanceInMeters2 = currentLocation?.distanceFromLocation(loc2) ?? 0
                        //print((distanceInMeters1 < distanceInMeters2))
                        return (distanceInMeters1 < distanceInMeters2)
                    }
                    return false
                })
        }
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            filterWithKm = 5
            break
        case 1:
            filterWithKm = 10
            break
        case 2:
            filterWithKm = 15
            break
        case 3:
            filterWithKm = 0
            break
        default:
            filterWithKm = 0
            break;
        }
        self.filterData()
        tblGroups.reloadData()
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
        if self.currentLocation == nil
        {
            let location = locations.last! as CLLocation
            currentLocation = location
            CLocation = location
        }
        locationManager.stopUpdatingLocation()
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
            emptyLabel.text = "Currently you do not have any nearby games!"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("GameTableviewCell", forIndexPath: indexPath) as! GameTableviewCell
        
        cell.lblTitle.text =  filteredPlaces[indexPath.row]["title"]
        
        cell.btnJoin.tag = indexPath.row
        cell.btnJoin.addTarget(self, action: #selector(TableViewController.joinGameButton(_:)), forControlEvents: .TouchUpInside)

        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        activePlace = indexPath.row
        return indexPath
    }
    
    @IBAction func joinGameButton(sender: UIButton) {
        
        activePlace = sender.tag
        //let gameNameInformation = String(places[activePlace])
        //JoinGameViewController.gameName = String(gameNameInformation)
        let joinGameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("JoinGameViewController") as! JoinGameViewController!
        self.navigationController?.pushViewController(joinGameViewController, animated: true)
    }
    
    @IBAction func actionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}
