//
//  FindGameViewController.swift
//  Find Ur Game
//
//  Created by iParth on 9/5/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

import Firebase

class FindGameViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var btnCurrentLocation: UIButton!
    @IBOutlet weak var mvLocation: MKMapView!
    @IBOutlet weak var cvGames: UICollectionView!
    
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    var geocoder = CLGeocoder()
    var user: FIRUser!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    var getCurrentLocation: Bool = true
    
    var isRefreshingData = false
    var filterWithKm = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnCurrentLocation.setCornerRadious(btnCurrentLocation.frame.size.width/2)
        self.initLocationManager()
        if CLocation.coordinate.latitude != 0 {
            refreshData()
        }
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

    func refreshData()
    {
        if isRefreshingData == true {
            return
        }
        
        isRefreshingData = true
        let myGroup = dispatch_group_create()
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Getting list of games..")
        
        dispatch_group_enter(myGroup)
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
                self.isRefreshingData = false
                self.filterData()
                self.ShowFilteredGamePlace()
                print(places)
            }
        }
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
    func ShowFilteredGamePlace() {
        for (index, element) in filteredPlaces.enumerate()
        {
            //print("Item \(index): \(element)")
            let latitude = NSString(string: element["lat"]!).doubleValue
            let longitude = NSString(string: element["long"]!).doubleValue
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = element["title"]
            self.mvLocation.addAnnotation(annotation)
        }
        
//        let latitude = NSString(string: filteredPlaces[activePlace]["lat"]!).doubleValue
//        let longitude = NSString(string: filteredPlaces[activePlace]["long"]!).doubleValue
//        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let latDelta:CLLocationDegrees = 0.05
        let lonDelta:CLLocationDegrees = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(CLocation.coordinate, span)
        self.mvLocation.setRegion(region, animated: false)
    }
    
    @IBAction func actionGetCurrentLocation(sender: AnyObject) {
        getCurrentLocation = true
        locationManager.startUpdatingLocation()
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
        if (self.selectedLocation == nil
            && self.currentLocation == nil) || getCurrentLocation == true
        {
            let location = locations.last! as CLLocation
            currentLocation = location
            CLocation = location
            
            refreshData()
            
            let center = CLLocationCoordinate2D(latitude: CLocation.coordinate.latitude, longitude: CLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mvLocation.setRegion(region, animated: true)
            //mvLocation.removeAnnotations(mvLocation.annotations)
            //AddAnnotationAtCoord(center)
            
            CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {(placemarks, error)->Void in
                let pm = placemarks![0]
                if let place = pm.LocationString()
                {
                    CLocationPlace = place
                }
            })
        }
        locationManager.stopUpdatingLocation()
    }
    func AddAnnotationAtCoord(Coord: CLLocationCoordinate2D)
    {
        let newAnotation = MKPointAnnotation()
        newAnotation.coordinate = Coord
        newAnotation.title = "Current Location"
        newAnotation.subtitle = ""
        mvLocation.addAnnotation(newAnotation)
        //mapView(mvLocation, viewForAnnotation: newAnotation)!.annotation = newAnotation
        //mvLocation.addAnnotation(newAnotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var imgPin = UIImage(named: "map-location-white")
        if annotation is MKUserLocation {
            imgPin = UIImage(named: "map-location-green")
        }
        
        let annotationIdentifier = "Pin"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = nil
            annotationView.image = imgPin
        }
        
        return annotationView
    }
}
