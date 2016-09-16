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
import SDWebImage
import UIActivityIndicator_for_SDWebImage

class FindGameViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var btnCurrentLocation: UIButton!
    @IBOutlet weak var findRangeSC: UISegmentedControl!
    @IBOutlet weak var mvLocation: MKMapView!
    @IBOutlet weak var cvGames: UICollectionView!
    
    //Game Detail View
    @IBOutlet var vOverlay: UIView!
    @IBOutlet var vGameDetail: UIView!
    @IBOutlet var btnCloseDetalView: UIButton!
    @IBOutlet var lblSport: UILabel!
    @IBOutlet var lblGameName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var btnJoinGame: UIButton!
    @IBOutlet weak var cvUserThisGame: UICollectionView!
    
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    var geocoder = CLGeocoder()
    var user: FIRUser!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    var getCurrentLocation: Bool = true
    
    var isRefreshingData = false
    var filterWithKm = 20
    var PlayerInGame:Array<String> = []
    
    private var currentPage: Int = 1
    private var pageSize: CGSize {
        let layout = self.cvGames.collectionViewLayout as! PDCarouselFlowLayout
        var pageSize = layout.itemSize
//        if layout.scrollDirection == .Horizontal {
//            pageSize.width += layout.minimumLineSpacing
//        } else {
//            pageSize.height += layout.minimumLineSpacing
//        }
        return pageSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.vOverlay.alpha = 0
        
        self.cvGames.showsHorizontalScrollIndicator = false
        let layout = self.cvGames.collectionViewLayout as! PDCarouselFlowLayout
        //layout.spacingMode = PDCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 100)
        layout.spacingMode = PDCarouselFlowLayoutSpacingMode.fixed(spacing: 20)
        layout.scrollDirection = .Horizontal
        
        btnCurrentLocation.setCornerRadious(btnCurrentLocation.frame.size.width/2)
        btnJoinGame.setCornerRadious(2)
        
//        let hLayout = PDHorizantalFlowLayout()
//        hLayout.itemSize = CGSizeMake(50, 50)
//        self.cvUserThisGame.collectionViewLayout = hLayout
        
        let hLayout = UICollectionViewFlowLayout()
        hLayout.scrollDirection = .Horizontal
        //hLayout.itemSize = CGSizeMake(50, 50)
        self.cvUserThisGame.collectionViewLayout = hLayout
        self.cvUserThisGame.showsHorizontalScrollIndicator = false
        
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
        
        ref.child("games").child("active").queryOrderedByChild("activeStatus").queryEqualToValue("active")
            .observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
                //Filter Active Game Only
        //})
        //ref.child("games").child("active").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
            places.removeAll()
            
            print("\(NSDate().timeIntervalSince1970)")
            //self.tblGroups.reloadData()
            for child in snapshot.children {
                
                var placeDict = Dictionary<String,AnyObject>()
                let childDict = child.valueInExportFormat() as! NSDictionary
                //print(childDict)
                
                print(childDict.valueForKey("startTimestamp"))
                
                if let startTimestamp = childDict.valueForKey("startTimestamp") as? Double
                    where startTimestamp.asDateFromMiliseconds.isExpiredDate(NSDate()) == true
                {
                    print("\(startTimestamp) : \(startTimestamp.asDateFromMiliseconds.formattedWith())")
                    print("Skip this record and mark them expired : \(startTimestamp.asDateFromMiliseconds.isExpiredDate(NSDate()))")
                    // Set to expired
                    let StatusDict = ["activeStatus" : "expired"]
                    self.ref.child("games").child("active").child(child.key).updateChildValues(StatusDict)
                    continue
                }
                
                // Hide game which already have 11 or more player
                if let players = childDict["players"] as? Dictionary<String,AnyObject>
                    //where players.convertToDictionary() != nil
                {
                    //print(players.keys)
                    print(players.keys.count)
                    if players.keys.count >= 11 && players.keys.contains(myUserID!) == false {
                        print("Hide This Game : \(child.key ?? "")")
                        continue
                    }
                }
                
                //let jsonDic = NSJSONSerialization.JSONObjectWithData(childDict, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<String, AnyObject>;
                for key : AnyObject in childDict.allKeys {
                    let stringKey = key as! String
                    if let keyValue = childDict.valueForKey(stringKey) as? String {
                        placeDict[stringKey] = keyValue
                    } else if let keyValue = childDict.valueForKey(stringKey) as? Double {
                        placeDict[stringKey] = "\(keyValue)"
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? Dictionary<String,AnyObject> {
                        placeDict[stringKey] = keyValue
                    }
                    else if let keyValue = childDict.valueForKey(stringKey) as? NSDictionary {
                        placeDict[stringKey] = keyValue
                    }
                    
                }
                placeDict["key"] = child.key
                
                let group = child.childSnapshotForPath("groupName").value
                let groupString = group as? String ?? ""
                let lat = child.childSnapshotForPath("lat").value
                let userLat = lat as! Double!
                let long = child.childSnapshotForPath("long").value
                let userLong = long as! Double!
                
//                let timestamp = child.childSnapshotForPath("timestamp").value
//                let timestampString = timestamp as! Double!
//                print(timestampString)
                
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
                    placeDict["Address"] = "\(street), \(city) \(zip)"
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
            filteredPlaces = places.filter({ (game:[String : AnyObject]) -> Bool in
                if let lat = (game["lat"] as? String)?.toDouble(),
                    long = (game["long"] as? String)?.toDouble()
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
            filteredPlaces = filteredPlaces.sort({ (game1:[String : AnyObject], game2:[String : AnyObject]) -> Bool in
                if let lat1 = (game1["lat"] as? String)?.toDouble(),
                    long1 = (game1["long"] as? String)?.toDouble(),
                    lat2 = (game2["lat"] as? String)?.toDouble(),
                    long2 = (game2["long"] as? String)?.toDouble()
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
        
        cvGames.reloadData()
    }
    
    func ShowFilteredGamePlace(LatLongDelta:CLLocationDegrees = 0.05)
    {
        mvLocation.removeAnnotations(mvLocation.annotations)
        
        for (index, element) in filteredPlaces.enumerate()
        {
            //print("Item \(index): \(element)")
            let latitude = NSString(string: element["lat"] as? String ?? "0").doubleValue
            let longitude = NSString(string: element["long"] as? String ?? "0").doubleValue
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = element["title"] as? String ?? ""
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
    
    @IBAction func findRangeChanged(sender: UISegmentedControl) {
        
        var LatLongDelta:CLLocationDegrees = 0.05
        
        switch findRangeSC.selectedSegmentIndex
        {
        case 0:
            filterWithKm = 5
            LatLongDelta = 0.05
            break
        case 1:
            filterWithKm = 10
            LatLongDelta = 0.10
            break
        case 2:
            filterWithKm = 20
            LatLongDelta = 0.20
            break
        case 3:
            filterWithKm = 50
            LatLongDelta = 0.50
            break
        default:
            filterWithKm = 0
            LatLongDelta = 0.50
            break;
        }
        self.filterData()
        self.ShowFilteredGamePlace()
        cvGames.reloadData()
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(LatLongDelta, LatLongDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(CLocation.coordinate, span)
        self.mvLocation.setRegion(region, animated: true)
        
//        mvLocation.region = MKCoordinateRegionMakeWithDistance(
//            CLocation.coordinate,
//            MilesToMeters(Double(filterWithKm)),
//            MilesToMeters(Double(filterWithKm))
//        );
    }
    
    func MilesToMeters(miles: Double) -> Double {
        // 1 mile is 1609.344 meters
        // source: http://www.google.com/search?q=1+mile+in+meters
        //return 1609.344 * miles;
        return 1000.0 * miles;
    }
    
    @IBAction func actionGetCurrentLocation(sender: AnyObject) {
        getCurrentLocation = true
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Card Collection Delegate & DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Set Static values 5 here for test purpose
        if collectionView == cvGames {
            return filteredPlaces.count
        } else if collectionView == cvUserThisGame {
            return PlayerInGame.count
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == cvGames {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GameNearMeCollectionViewCell.identifier, forIndexPath: indexPath) as! GameNearMeCollectionViewCell
            
            let game = filteredPlaces[indexPath.row]
            print(game)
            //cell.image.layer.cornerRadius = max(cell.image.frame.size.width, cell.image.frame.size.height) / 2
            //cell.image.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).CGColor
            
            cell.imgUser1.setCornerRadious(2)
            cell.imgUser2.setCornerRadious(2)
            cell.imgUser3.setCornerRadious(2)
            
            let sport = game["sport"] as? String ?? ""
            cell.lblSport.textColor = ((sport == sportArray[0]) ? clrGreen : ((sport == sportArray[1]) ? clrOrange : ((sport == sportArray[2]) ? clrRed : clrPurple)))
            
            cell.lblSport.text = game["sport"] as? String ?? ""
            cell.lblGameName.text = game["groupName"] as? String ?? ""
            //cell.lblDate.text = (game["startTimestamp"] as? String ?? "1").asDateUTC?.strDateInUTC
            cell.lblDate.text = (game["startTimestamp"] as? String)?.asDateFromMiliseconds?.formattedWith()
            cell.lblTime.text = game["endTimestamp"] as? String ?? ""
            //cell.lblMoreCount.text = "2+"
            
            cell.selectedBackgroundView = nil
            
            var PlayerInThisGame:Array<String> = []
            if let players = game["players"] as? Dictionary<String,AnyObject>
                //where players.convertToDictionary() != nil
            {
                for key : String in Array(players.keys) {
                    PlayerInThisGame.append(key)
                }
                print(" index : \(indexPath.row) Player in game : \(PlayerInThisGame.count) ")
                
                if PlayerInThisGame.count >= 1 {
                    cell.imgUser1.hidden = false
                    loadUserImageToImageView(cell.imgUser1, uid: PlayerInThisGame[0])
                } else {
                    cell.imgUser1.hidden = true
                }
                if PlayerInThisGame.count >= 2 {
                    cell.imgUser2.hidden = false
                    loadUserImageToImageView(cell.imgUser2, uid: PlayerInThisGame[1])
                } else {
                    cell.imgUser2.hidden = true
                }
                if PlayerInThisGame.count >= 3 {
                    cell.imgUser3.hidden = false
                    cell.lblMoreCount.hidden = false
                } else {
                    cell.imgUser3.hidden = true
                    cell.lblMoreCount.hidden = true
                    cell.lblMoreCount.text = "+\(PlayerInThisGame.count-2)"
                }
            } else {
                cell.imgUser1.hidden = true
                cell.imgUser2.hidden = true
                cell.imgUser3.hidden = true
                cell.lblMoreCount.hidden = true
            }

            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerInGameCollectionViewCell.identifier, forIndexPath: indexPath) as! PlayerInGameCollectionViewCell
            
            let game = PlayerInGame[indexPath.row]
            print(game)
            //cell.image.layer.cornerRadius = max(cell.image.frame.size.width, cell.image.frame.size.height) / 2
            //cell.image.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).CGColor
            
            loadUserImageToImageView(cell.imgPlayer, uid: PlayerInGame[indexPath.row])
            
            cell.selectedBackgroundView = nil
            
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if collectionView == cvGames {
            selectedGame = filteredPlaces[indexPath.row]
            ShowGameDetail(filteredPlaces[indexPath.row])
        } else if collectionView == cvUserThisGame {
            
        }
    }
    
    func loadUserImageToImageView(imgUser:UIImageView,uid:String) {
        ref.child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let userProfile = snapshot.value!["userProfile"] as? String {
                let userProfileNSURL = NSURL(string: "\(userProfile)")
                imgUser.setImageWithURL(userProfileNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            }
            else if let facebookData = snapshot.value!["facebookData"] as? NSDictionary
                where facebookData["profilePhotoURL"] != nil
            {
                let userProfileNSURL = NSURL(string: "\(facebookData["profilePhotoURL"] as? String ?? "")")
                imgUser.setImageWithURL(userProfileNSURL, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.AllowInvalidSSLCertificates, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            }
            else {
                //print("No Profile Picture")
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        if scrollView == cvGames {
            let layout = self.cvGames.collectionViewLayout as! PDCarouselFlowLayout
            let pageSide = (layout.scrollDirection == .Horizontal) ? self.pageSize.width : self.pageSize.height
            let offset = (layout.scrollDirection == .Horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
            
            currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            print("currentPage = \(currentPage)")
            
            let game = filteredPlaces[currentPage]
            let lat = Double(game["lat"] as? String ?? "1") ?? 0
            let long = Double(game["long"] as? String ?? "1") ?? 0
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mvLocation.setRegion(region, animated: true)
        }
        
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
        imgPin = UIImage(named: "map-location-green")
        
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
    
    // MARK: - Game Detail View
    @IBAction func actionCloseGameDetail(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {
            self.vOverlay.alpha = 0
        }) { (completion) in
                self.cvGames.alpha = 1
        }
    }
    
    func ShowGameDetail(game:Dictionary<String,AnyObject>)
    {
        UIView.animateWithDuration(0.5, animations: {
            self.vOverlay.alpha = 1
        })
        print(game)
        
        lblSport.text = game["sport"] as? String ?? ""
        lblGameName.text = game["groupName"] as? String ?? ""
        lblDate.text = (game["startTimestamp"] as? String)?.asDateFromMiliseconds?.formattedWith()
        lblTime.text = game["endTimestamp"] as? String ?? ""
        lblSport.text = game["sport"] as? String ?? ""
        lblLocation.text = game["Address"] as? String ?? ""
        lblDescription.text = game["gameNotes"] as? String ?? ""
        
        
        btnJoinGame.setBorder(0, color: clrGreen)
        btnJoinGame.backgroundColor = clrGreen
        btnJoinGame.setTitle("Join Game", forState: .Normal)
        btnJoinGame.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnJoinGame.setCornerRadious(2)
        btnJoinGame.userInteractionEnabled = true

        PlayerInGame.removeAll()
        if let players = game["players"] as? Dictionary<String,AnyObject>
            //where players.convertToDictionary() != nil
        {
            //let playersDict = players.convertToDictionary()!
            if let joinData = players[myUserID!] {
                print(joinData)
                btnJoinGame.setTitle("Already Joined", forState: .Normal)
                btnJoinGame.setBorder(2, color: clrGreen)
                btnJoinGame.setTitleColor(clrGreen, forState: .Normal)
                btnJoinGame.backgroundColor = UIColor.whiteColor()
                btnJoinGame.setCornerRadious(2)
                btnJoinGame.userInteractionEnabled = false
            }
            
            for key : String in Array(players.keys) {
                PlayerInGame.append(key)
            }
            print(PlayerInGame)
            self.cvUserThisGame.reloadData()
        }
    }
    
    @IBAction func joinGameButton(sender: AnyObject) {
        
        if PlayerInGame.count >= 11 {
            CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Ooops, it looks like eleven player is alredy joined to this game!")
            return
        }
        
        let timestamp = NSDate().timeIntervalSince1970
        let enrollGame:[String:AnyObject] = ["joinedAt": timestamp, "uid": myUserID!]
        print(enrollGame,selectedGame)
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Joining..")
        ref.child("games").child("active").child(selectedGame["key"] as? String ?? "").child("players").child(myUserID!).updateChildValues(enrollGame) { (error, ref) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "You Joined successfully!")
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Opps,we are uable to join you in game!")
            }
        }
    }
    
}
