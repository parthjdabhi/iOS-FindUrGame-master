//
//  MapViewController.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//


import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var pinColor: UIColor = UIColor.redColor()
    
    override init() {
        super.init()
    }
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var manager: CLLocationManager!
    
    @IBOutlet var map: MKMapView!
    @IBOutlet weak var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
            
            for (index, element) in filteredPlaces.enumerate()
            {
                //print("Item \(index): \(element)")
                let latitude = NSString(string: element["lat"]!).doubleValue
                let longitude = NSString(string: element["long"]!).doubleValue
                let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                let latDelta:CLLocationDegrees = 0.01
                let lonDelta:CLLocationDegrees = 0.01
                let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
                self.map.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = element["title"]
                self.map.addAnnotation(annotation)
                
//                let annotation1 = Annotation()
//                annotation1.coordinate = coordinate
//                //annotation1.title = filteredPlaces[activePlace]["title"]
//                annotation1.pinColor = (index == activePlace) ? UIColor.greenColor() : UIColor.redColor()
//                print((index == activePlace))
//                self.map.addAnnotation(annotation1)
            }
            
            let latitude = NSString(string: filteredPlaces[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: filteredPlaces[activePlace]["long"]!).doubleValue
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let latDelta:CLLocationDegrees = 0.05
            let lonDelta:CLLocationDegrees = 0.05
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            self.map.setRegion(region, animated: false)
        }
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.action(_:)))
        uilpgr.minimumPressDuration = 2.0
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(self.map)
            let newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                if (error == nil) {
                    
                    //if statement was changed
                    if let p = placemarks?[0] {
                        
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        if p.subThoroughfare != nil {
                            
                            subThoroughfare = p.subThoroughfare!
                        }
                        
                        if p.thoroughfare != nil {
                            
                            thoroughfare = p.thoroughfare!
                        }
                        
                        title = "\(subThoroughfare) \(thoroughfare)"
                    }
                }
                
                if title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {

                    title = "Added \(NSDate())"
                }
                
                filteredPlaces.append(["name":title,"lat":"\(newCoordinate.latitude)","lon":"\(newCoordinate.longitude)"])
                print(filteredPlaces)
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                
            })
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
//        let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
//        let longitude = NSString(string: places[activePlace]["long"]!).doubleValue
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let latDelta:CLLocationDegrees = 0.02
        let lonDelta:CLLocationDegrees = 0.02
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        self.map.setRegion(region, animated: true)
    }
    
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//        
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            
//            let colorPointAnnotation = annotation as! Annotation
//            pinView?.pinTintColor = colorPointAnnotation.pinColor
//        }
//        else {
//            pinView?.annotation = annotation
//        }
//        
//        return pinView
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
