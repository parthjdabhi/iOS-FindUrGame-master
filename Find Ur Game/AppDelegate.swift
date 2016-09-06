//
//  AppDelegate.swift
//  Find Ur Game
//
//  Created by Dustin Allen on 8/7/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreData
import Mixpanel
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import OAuthSwift
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    var ref: FIRDatabaseReference?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //
        //Fabric.with([Twitter.self])
        //
        //let mixpanel = Mixpanel.sharedInstanceWithToken("57a85a364ed354c028734e7ab5de105b")
        //mixpanel.track("App launched")
        
        FIRApp.configure()
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        IQKeyboardManager.sharedManager().enable = true
        
        
        //UITabBar.appearance().tintColor = UIColor(red: 26/255.0, green: 185/255.0, blue: 106/255.0, alpha: 1.0)
        //UITabBar.appearance().tintColor = UIColor.redColor()
        
        
        if let user = FIRAuth.auth()?.currentUser
        {
            print(user)
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let navigationController = mainStoryboard.instantiateViewControllerWithIdentifier("navHome") as? UINavigationController
//            navigationController?.navigationBarHidden = true // or not, your choice.
//            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//            self.window!.rootViewController = navigationController
//            self.window!.makeKeyAndVisible()
            
            let navigationController = UINavigationController()
            navigationController.navigationBarHidden = true // or not, your choice.
            navigationController.viewControllers = [MyTabBarViewController.init()]
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window!.rootViewController = navigationController
            self.window!.makeKeyAndVisible()
        }
        else
        {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = mainStoryboard.instantiateViewControllerWithIdentifier("navSignin") as? UINavigationController
            navigationController?.navigationBarHidden = true // or not, your choice.
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window!.rootViewController = navigationController
            self.window!.makeKeyAndVisible()
        }
        
        
        //self.saveData()
//        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
//            if snapshot.exists() {
//                let dict = snapshot.valueInExportFormat() as? NSDictionary
//                print(dict)
//            }
//        }
        
        return true
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        print(deviceToken)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        
    }
    
    
    func applicationHandleOpenURL(url: NSURL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handleOpenURL(url)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        applicationHandleOpenURL(url)
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        applicationHandleOpenURL(url)
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            openURL: url,
            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
            annotation: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
        }
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.harloch.Connect_App" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Find-Ur-Game", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    //MARK: Helper method to convert the NSDate to NSDateComponents
    func dateComponentFromNSDate(date: NSDate)-> NSDateComponents{
        
        let calendarUnit: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let dateComponents = NSCalendar.currentCalendar().components(calendarUnit, fromDate: date)
        return dateComponents
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
    }
    
}