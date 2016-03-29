//
//  AppDelegate.swift
//  GoatFinder
//
//  Created by Daniel Hauagge on 3/3/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let realm = try! Realm()
        
        print("We have \(realm.objects(Goat).count) goats")
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Create a backgrond process to fetch goat positions
        dispatch_async(dispatch_queue_create("background", nil)) {
            
            while(true) {
                print("looking for goat position")
                
                let realm = try! Realm()
                let goats = realm.objects(Goat)
                var goatNames = [String]()
                for goat in goats {
                    goatNames.append(goat.name)
                }
                
                let params = ["goats": goatNames]
                
                Alamofire.request(.GET, "http://169.54.42.86:9000/position", parameters:params)
                    .validate()
                    .responseJSON(completionHandler: { response in
                        
                        // Runs when we get back the response
                        print(response.result.value)
                        
                        let json = JSON(response.result.value!)
                        
                        let realm = try! Realm()
                        try! realm.write({
                            
                            for goat in realm.objects(Goat) {
                                
                                goat.latitude = json[goat.name]["latitude"].doubleValue
                                goat.longitude = json[goat.name]["longitude"].doubleValue
                                
                            }
                            
                        })
                        realm.refresh() // we are running on a background thread, so we need to tell realm to sync the copy we have of the database with the other threads copies
                    })
                
                NSThread.sleepForTimeInterval(3)
            }
            
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

