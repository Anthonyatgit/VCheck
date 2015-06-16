//
//  AppDelegate.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SCLAlertView
import RKDropdownAlert
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var _mapManager: BMKMapManager?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Init Breeze Storage stack with iCloud
        if BreezeStore.iCloudAvailable() {
            BreezeStore.setupiCloudStoreWithContentNameKey("iCloud-\(BreezeStore.appName())", localStoreName: "\(BreezeStore.appName())", transactionLogs: "iCloud_transaction_logs")
        }
        else {
            BreezeStore.setupStoreWithName("\(BreezeStore.appName())", storeType: NSSQLiteStoreType, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        }
        
        // BaiduMap
        _mapManager = BMKMapManager()
        let ret: Bool = _mapManager!.start(VCAppLetor.BMK.MapKey, generalDelegate: nil)
        if !ret {
            println("BMK Manager start failed!")
        }
        
        // Register for ShareSDK
        ShareSDK.registerApp("7bcd1d7bc200")
        
        // Connect Sina Weibo
        ShareSDK.connectSinaWeiboWithAppKey("4012589497", appSecret: "cad1412fd89be70722de86337a571a54", redirectUri: "http://192.168.100.100", weiboSDKCls: WeiboSDK.classForCoder())
        
        // Connect WeChat
        ShareSDK.connectWeChatWithAppId("wx76e86073a6e91077", appSecret: "f02a4fac3a25c49245e6b7317a7e8026", wechatCls: WXApi.classForCoder())
        ShareSDK.connectWeChatSessionWithAppId("wx76e86073a6e91077", appSecret: "f02a4fac3a25c49245e6b7317a7e8026", wechatCls: WXApi.classForCoder())
        
        // Connect SMS
        ShareSDK.connectSMS()
        
        let appName: String = "VCheck"
        
        // Get client config
        self.getClientConfig()
        
        
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    // MARK: - Initialization
    
    func getClientConfig() {
        
        // Current app version
//        let version: Settings = Settings.findFirst(attribute: "name", value: "version_app", contextType: BreezeContextType.Background) as! Settings
        
        if let version = Settings.findFirst(attribute: "name", value: "version_app", contextType: BreezeContextType.Main) as? Settings { // Get current app version
            
            CTMemCache.sharedInstance.set("version_app", data: version.value, namespace: "appConfig")
        }
        else { // App version DO NOT exist, create one with version "1.0"
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let versionToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                versionToBeCreate.sid = "\(NSDate())"
                versionToBeCreate.name = "version_app"
                versionToBeCreate.value = "1.0"
                versionToBeCreate.type = VCAppLetor.SettingType.AppConfig
                versionToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set("version_app", data: "1.0", namespace: "appConfig")
        }
        
        // Read config from server
        let appVersion: String = CTMemCache.sharedInstance.get("version_app", namespace: "appConfig")?.data as! String
        
        Alamofire.request(VCheckGo.Router.AppSettings(appVersion,VCheckGo.DeviceType.iPhone)).validate().responseJSON() {
            (request, response, JSON, error) -> Void in
            
            if error == nil {
                
                let status = (JSON as! NSDictionary).valueForKey("status") as! NSDictionary
                if status.valueForKey("succeed") as! String == "1" {
                    
                    // Check if app update required
                    let configList = ((JSON as! NSDictionary).valueForKey("data") as! NSDictionary).valueForKey("config_list") as! [NSDictionary]
                    
                    for config in configList {
                        
                        CTMemCache.sharedInstance.set(config.valueForKey("key") as! String, data: config, namespace: "appConfig")
                    }
                    
                    let needUpdate: String = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNeedUpdate, namespace: "appConfig")?.data as! NSDictionary).valueForKey("value") as! String
                    if (needUpdate == "1") { // Enforce to update app
                        
                        let isShowTip: String = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optTipForUpdate, namespace: "appConfig")?.data as! NSDictionary).valueForKey("value") as! String
                        if (isShowTip == "1") { // With alertview?
                            
                            let alert = SCLAlertView()
                            alert.addButton(VCAppLetor.StringLine.UpdateNowButtonTitle, target:self, selector:"updateNow")
                            alert.showNotice(VCAppLetor.StringLine.UpdateNoticeTitle, subTitle:VCAppLetor.StringLine.UpdateDescription)
                        }
                        else { // Update app directly (redirect to App Store page)
                            println("Go Update!")
                        }
                    }
                    
                }
                else {
                    println("Error: JSON Return ERROR: Succeed fail")
                }
            }
            else {
                println("Error with App Settings Request: \(error?.localizedDescription)")
            }
        }
    }
    
    // Update in progressing when user click UPDATE NOW button on the update alert view
    func updateNow() {
        println("Go Update!")
    }
    
    // MARK: - ShareSDK URL Schemes Handler
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "cc.siyo.iMenu3" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("iMenu3", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("iMenu3.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

