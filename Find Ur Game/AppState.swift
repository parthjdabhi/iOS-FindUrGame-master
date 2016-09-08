//
//  AppState.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?    
    var currentUser: FIRDataSnapshot!
    //var friendID: String?
    //var friend: UserData?
}

let myUserID = {
    return FIRAuth.auth()?.currentUser?.uid
}()

var places:[Dictionary<String,AnyObject>] = []
var filteredPlaces:[Dictionary<String,AnyObject>] = []
var selectedGame: Dictionary<String,AnyObject> = [:]

//Global Data
var CLocation:CLLocation = CLLocation()
var CLocationPlace:String = String()

let storage = FIRStorage.storage()
let storageRef = storage.reference()

// Create file metadata including the content type
//let metadata = {
//    let meta = FIRStorageMetadata()
//    meta.contentType = "image/jpeg"
//    return meta
//}()
        