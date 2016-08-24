//
//  CommonUtils.swift
//  What2Watch
//
//  Created by Dustin Allen 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreLocation

class CommonUtils: NSObject {
    static let sharedUtils = CommonUtils()
    var progressView : MBProgressHUD = MBProgressHUD.init()
    
    // show alert view
    func showAlert(controller: UIViewController, title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        controller.presentViewController(ac, animated: true){}
    }
    
    // show progress view
    func showProgress(view : UIView, label : String) {
        progressView = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressView.labelText = label
    }
    
    // hide progress view
    func hideProgress(){
        progressView.removeFromSuperview()
        progressView.hide(true)
    }
    
    func decodeImage(base64String : String) -> UIImage {
        let decodedData = NSData(base64EncodedString: base64String, options:  NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let image = UIImage(data: decodedData!)
        return image!
    }
}


extension CLPlacemark {
    func LocationString() -> String? {
        
        // Address dictionary
        print(self.addressDictionary)
        
        // Location name
        let locationName = self.addressDictionary?["Name"] as! String!
        print(locationName)
        
        // Street address
        let street = self.addressDictionary?["Thoroughfare"] as! String!
        
        // City
        let city = self.addressDictionary?["City"] as! String!
        
        // Zip code
        let zip = self.addressDictionary?["ZIP"] as! String!
        
        // Country
        let country = self.addressDictionary?["Country"] as! String!
        print(country)
        
        return "\(street), \(city) \(zip)"
        /*
        print("\(self)")
        var LocArray = [""]
        LocArray.removeAll()
//        if (self.locality != nil
//            && self.locality?.characters.count > 1) {
//            LocArray.append(self.locality!)
//        }
//        if self.administrativeArea != nil  && self.administrativeArea?.characters.count > 1 {
//            LocArray.append((self.administrativeArea)!)
//        }
//        if self.country != nil  && self.country?.characters.count > 1 {
//            LocArray.append(self.country!)
//        }
        
        // Street address
        if self.thoroughfare != nil  && self.thoroughfare?.characters.count > 1 {
            LocArray.append(self.thoroughfare!)
        }
        
        // City
        if self.administrativeArea != nil  && self.administrativeArea?.characters.count > 1 {
            LocArray.append(self.administrativeArea!)
        }
        
        // Zip code
        if self.postalCode != nil  && self.postalCode?.characters.count > 1 {
            LocArray.append(self.postalCode!)
        }
        
        // Country
        if self.country != nil  && self.country?.characters.count > 1 {
            LocArray.append(self.country!)
        }
        
        let locationString = LocArray.joinWithSeparator(", ")
        print("String : \(locationString)")
        return locationString
 */
    }
    
}