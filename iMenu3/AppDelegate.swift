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
import DKChainableAnimationKit
import MBProgressHUD
import RKDropdownAlert

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    var window: UIWindow?
    
    var _mapManager: BMKMapManager?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        // Override point for customization after application launch.
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: VCAppLetor.Font.UltraLight]
        
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "bar_black.png"), forBarMetrics: UIBarMetrics.Default)
        
        //======= Breeze =============================
        // Init Breeze Storage stack with iCloud
        if BreezeStore.iCloudAvailable() {
            BreezeStore.setupiCloudStoreWithContentNameKey("iCloud-\(BreezeStore.appName())", localStoreName: "\(BreezeStore.appName())", transactionLogs: "iCloud_transaction_logs")
        }
        else {
            BreezeStore.setupStoreWithName("\(BreezeStore.appName())", storeType: NSSQLiteStoreType, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        }
        
        //======= BaiduMap ===========================
        _mapManager = BMKMapManager()
        let ret: Bool = _mapManager!.start(VCAppLetor.BMK.MapKey, generalDelegate: nil)
        if !ret {
            println("BMK Manager start failed!")
        }
        
        //======= ShareSDK ===========================
        // Register for ShareSDK
        ShareSDK.registerApp(VCAppLetor.ShareSDK.appKey)
        
        // Connect Sina Weibo
        ShareSDK.connectSinaWeiboWithAppKey(VCAppLetor.ShareSDK.SinaAppKey, appSecret: VCAppLetor.ShareSDK.SinaAppSecret, redirectUri: VCAppLetor.ShareSDK.SinaRedirectURL, weiboSDKCls: WeiboSDK.classForCoder())
        
        // Connect WeChat
        ShareSDK.connectWeChatWithAppId(VCAppLetor.ShareSDK.WeChatAppKey, appSecret: VCAppLetor.ShareSDK.WeChatAppSecret, wechatCls: WXApi.classForCoder())
        ShareSDK.connectWeChatSessionWithAppId(VCAppLetor.ShareSDK.WeChatAppKey, appSecret: VCAppLetor.ShareSDK.WeChatAppSecret, wechatCls: WXApi.classForCoder())
        
        // Wechat Pay
        let we = WXApi.registerApp(VCAppLetor.ShareSDK.WeChatAppKey, withDescription: "VCheck beta")
        
        if we {
            println("Register WXApi Success")
        }
        else {
            println("Register WXApi failed")
        }
        
        // Connect SMS
        //ShareSDK.connectSMS()
        
        let appName: String = VCAppLetor.StringLine.AppName
        
        //======== XGPush =============================
        // Init & Start XGPush Service
        XGPush.startApp(VCAppLetor.XGPush.appID, appKey: VCAppLetor.XGPush.appKey)
        XGPush.initForReregister { () -> Void in
            
            if !XGPush.isUnRegisterStatus() {
                
                switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch){
                    
                case .OrderedSame, .OrderedDescending: // iOS >= 8.0
                    self.registerPushForIOS8()
                case .OrderedAscending: // iOS < 8.0
                    self.registerPush()
                }
            }
        }
        
        // Clear application badge number
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        // Clear all local notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Handle notification launching action callback
        XGPush.handleLaunching(launchOptions, successCallback: { () -> Void in
            println("[XGPush]HandleLaunching success")
        }) { () -> Void in
            println("[XGPush]HandleLaunching failed")
        }
        
        // Local Notification
//        let fireDate: NSDate = NSDate(timeIntervalSinceNow: 10)
//        let dicUserInfo: NSMutableDictionary = NSMutableDictionary()
//        dicUserInfo.setValue("myid", forKey: "clockID")
//        let userInfo: NSDictionary = dicUserInfo
//        
//        XGPush.localNotification(fireDate, alertBody: "测试本地推送消息", badge: 1, alertAction: "确定", userInfo: userInfo as [NSObject : AnyObject])
        
        
        //=========== App Config =========================
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
    
    // MARK: - Functions
    
    
    // MARK: - XGPush
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        XGPush.localNotificationAtFrontEnd(notification, userInfoKey: "clockID", userInfoValue: "myid")
        
        // remove the notification from local list
        XGPush.delLocalNotification(notification)
//        XGPush.delLocalNotification("clockID", userInfoValue: "myid")
        
        // Clear notification list
//        XGPush.clearLocalNotifications()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // User did allow to receive the following type of notifications
        let allowedTypes: UIUserNotificationType = notificationSettings.types
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        if identifier == "ACCEPT_IDENTIFIER" {
            println("ACCEPT_IDENTIFIER is clicked @ Remote")
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if identifier == "ACCEPT_IDENTIFIER" {
            println("ACCEPT_IDENTIFIER is clicked @ Local")
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Register for Channel OR Server
//        XGSetting.getInstance().Channel = "VCheck"
//        XGSetting.getInstance().GameServer = "VCheck"
        
//        let deviceTokenString: String = NSString(data: deviceToken, encoding: NSUTF8StringEncoding) as! String
        let deviceTokenString: String = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        println("device token: \(deviceTokenString)")
        
        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optDeviceToken, data: deviceTokenString, namespace: "DeviceToken")
        
        let deviceTokenStr: String = XGPush.registerDevice(deviceToken, successCallback: { () -> Void in
            println("[XGPush]Register success for deviceToken")
            
            
        }) { () -> Void in
            println("[XGPush]Register failed for deviceToken")
        }
        
        
        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optDeviceToken, data: deviceTokenStr, namespace: "token")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        println("ERROR @ DeviceToken Error : \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        XGPush.handleReceiveNotification(userInfo, completion: { () -> Void in
            println("[XGPush]HandleReceivedNotification: \(userInfo)")
        })
    }
    
    // Register Push Notification for iOS version above 8.0.0
    func registerPushForIOS8() {
        
        // Types
        let types: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        
        // Actions
        let acceptAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title = "Accept"
        
        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground
        acceptAction.destructive = false
        acceptAction.authenticationRequired = false
        
        // Categories
        let inviteCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        
        inviteCategory.identifier = "INVITE_CATEGORY"
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories: NSSet = NSSet(objects: inviteCategory)
        
        
        let mySettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories as Set<NSObject>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    // Register Push N0tification for iOS version below 8.0.0
    func registerPush() {
        
        UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
    }
    
    // MARK: - Initialization
    
    func getClientConfig() {
        
        // Current app version
        //        let version: Settings = Settings.findFirst(attribute: "name", value: "version_app", contextType: BreezeContextType.Background) as! Settings
        
        if let version = Settings.findFirst(attribute: "name", value: "version_app", contextType: BreezeContextType.Main) as? Settings { // Get current app version
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optVersioniOS, data: version.value, namespace: "appConfig")
        }
        else { // App version DO NOT exist, create one with version "1.0"
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let versionToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                versionToBeCreate.sid = "\(NSDate())"
                versionToBeCreate.name = "version_app"
                versionToBeCreate.value = "1.0.0"
                versionToBeCreate.type = VCAppLetor.SettingType.AppConfig
                versionToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optVersioniOS, data: "1.0.0", namespace: "appConfig")
        }
        
        // Read config from server
        let appVersion: String = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optVersioniOS, namespace: "appConfig")?.data as! String
        
        println("\(VCAppLetor.StringLine.AppName) : \(appVersion)")
        
        Alamofire.request(VCheckGo.Router.AppSettings(appVersion,VCheckGo.DeviceType.iPhone)).validate().responseJSON() {
            (request, response, JSON, error) -> Void in
            
            if error == nil {
                
                let status = (JSON as! NSDictionary).valueForKey("status") as! NSDictionary
                if status.valueForKey("succeed") as! String == "1" {
                    
                    // Check if app update required
                    let configList = ((JSON as! NSDictionary).valueForKey("data") as! NSDictionary).valueForKey("config_list") as! [NSDictionary]
                    
                    for config in configList {
                        
                        let key = config.valueForKey("key") as! String
                        CTMemCache.sharedInstance.set(config.valueForKey("key") as! String, data: config, namespace: "appConfig")
                    }
                    
                    
                    let needUpdate: String = (CTMemCache.sharedInstance.get("need_update", namespace: "appConfig")?.data as! NSDictionary).valueForKey("value") as! String
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
                    
                    let errorDesc = status.valueForKey("error_desc") as! String
                    println("Error @ \(errorDesc)")
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
        
        println("url[handle]: \(url)")
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        println("sourceApp: \(sourceApplication)")
        
        println("URL: Scheme:\(url))")
        
        if sourceApplication == "com.apple.mobilesafari" {
            
            if ((url.query!.componentsSeparatedByString("&").count > 1)) {
                
                let queryStringArr = url.query!.componentsSeparatedByString("&")
                
                let contentStringArr = queryStringArr[1].componentsSeparatedByString("=")
                
                let productId = (contentStringArr[1] as NSString).integerValue
                
                Alamofire.request(VCheckGo.Router.GetProductDetail(productId)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let json = JSON
                            
                            if json["status"]["succeed"].string! == "1" {
                                
                                let product: FoodInfo = FoodInfo(id: (json["data"]["article_info"]["article_id"].string! as NSString).integerValue)
                                
                                product.title = json["data"]["article_info"]["title"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                product.addDate = dateFormatter.dateFromString(json["data"]["article_info"]["article_date"].string!)!
                                
                                product.desc = json["data"]["article_info"]["summary"].string!
                                product.subTitle = json["data"]["article_info"]["sub_title"].string!
                                product.status = json["data"]["article_info"]["menu_info"]["menu_status"]["menu_status_id"].string!
                                product.originalPrice = json["data"]["article_info"]["menu_info"]["price"]["original_price"].string!
                                product.price = json["data"]["article_info"]["menu_info"]["price"]["special_price"].string!
                                product.priceUnit = json["data"]["article_info"]["menu_info"]["price"]["price_unit"].string!
                                product.unit = json["data"]["article_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                product.remainingCount = json["data"]["article_info"]["menu_info"]["stock"]["menu_count"].string!
                                product.remainingCountUnit = json["data"]["article_info"]["menu_info"]["stock"]["menu_unit"].string!
                                product.remainder = json["data"]["article_info"]["menu_info"]["remainder_time"].string!
                                product.outOfStock = json["data"]["article_info"]["menu_info"]["stock"]["out_of_stock_info"].string!
                                product.endDate = json["data"]["article_info"]["menu_info"]["end_date"].string!
                                product.returnable = "1"
                                
                                product.memberIcon = json["data"]["article_info"]["member_info"]["icon_image"]["thumb"].string!
                                
                                product.menuId = json["data"]["article_info"]["menu_info"]["menu_id"].string!
                                product.menuName = json["data"]["article_info"]["menu_info"]["menu_name"].string!
                                
                                product.storeId = json["data"]["article_info"]["store_info"]["store_id"].string!
                                product.storeName = json["data"]["article_info"]["store_info"]["store_name"].string!
                                product.address = json["data"]["article_info"]["store_info"]["address"].string!
                                product.longitude = (json["data"]["article_info"]["store_info"]["longitude_num"].string! as NSString).doubleValue
                                product.latitude = (json["data"]["article_info"]["store_info"]["latitude_num"].string! as NSString).doubleValue
                                product.tel1 = json["data"]["article_info"]["store_info"]["tel_1"].string!
                                product.tel2 = json["data"]["article_info"]["store_info"]["tel_2"].string!
                                product.acp = json["data"]["article_info"]["store_info"]["per"].string!
                                product.icon_thumb = json["data"]["article_info"]["store_info"]["icon_image"]["thumb"].string!
                                product.icon_source = json["data"]["article_info"]["store_info"]["icon_image"]["source"].string!
                                
                                
                                //====== Show Product VC
                                
                                if CTMemCache.sharedInstance.exists(VCAppLetor.ObjectIns.objNavigation, namespace: "object") {
                                    
                                    let parentNav = CTMemCache.sharedInstance.get(VCAppLetor.ObjectIns.objNavigation, namespace: "object")?.data as! UINavigationController
                                    
                                    
                                    let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
                                    foodViewerViewController.foodInfo = product
                                    foodViewerViewController.parentNav = parentNav
                                    
                                    parentNav.showViewController(foodViewerViewController, sender: self)
                                    
                                }
                                else {
                                    
                                    CTMemCache.sharedInstance.set("Product", data: url.query!, namespace: "outcall")
                                }
                            }
                            else {
                                RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            }
                        })
                    }
                    else {
                        
                        println("ERROR @ Request for Product Info with outcall : \(error?.localizedDescription)")
                        RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                })
                
            }
            else {
                
                // route=home
                
                
                
            }
            
            return true
            
        }
        else if sourceApplication == "com.alipay.iphoneclient" {
            
            
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: {
                (Dictionary) -> Void in
                
                
                let dic = Dictionary as NSDictionary
                
                if dic.valueForKey("resultStatus") as! String == "9000" {
                    
                    let resultString = (dic.valueForKey("result") as! String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayTag, data: true, namespace: "pay")
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayResultString, data: resultString, namespace: "pay")
                    
                }
                else if dic.valueForKey("resultStatus") as! String == "6001" {
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayTag, data: false, namespace: "pay")
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayResultStatus, data: "6001", namespace: "pay")
                    
                }
                else if dic.valueForKey("resultStatus") as! String == "6002" {
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayTag, data: false, namespace: "pay")
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayResultStatus, data: "6002", namespace: "pay")
                    
                }
                else if dic.valueForKey("resultStatus") as! String == "4000" {
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayTag, data: false, namespace: "pay")
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payAlipayResultStatus, data: "4000", namespace: "pay")
                    
                }
                
            })
            
            return true
        }
        else if sourceApplication == "com.tencent.xin" {
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.ShareTag.shareWechat, namespace: "share") {
                
                CTMemCache.sharedInstance.cleanNamespace("share")
                return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
                
            }
            else {
                
                if let shareTag = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optShareTag, contextType: BreezeContextType.Main) as? Settings {
                    
                    //RKDropdownAlert.title(shareTag.value, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                    if shareTag.value == "Wechat" {
                        
                        BreezeStore.saveInMain({ contextType -> Void in
                            
                            shareTag.sid = "\(NSDate())"
                            shareTag.value = ""
                        })
                        
                        
                        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
                        
                    }
                    else {
                        
                        if CTMemCache.sharedInstance.exists(VCAppLetor.ObjectIns.objPayVC, namespace: "object") {
                            
                            let paymentVC = CTMemCache.sharedInstance.get(VCAppLetor.ObjectIns.objPayVC, namespace: "object")?.data as! VCPayNowViewController
                            
                            WXApi.handleOpenURL(url, delegate: paymentVC)
                            
                            return true
                        }
                        else {
                            
                            WXApi.handleOpenURL(url, delegate: self)
                            return true
                        }
                    }
                }
                else { //
                    
                    //RKDropdownAlert.title("pay", backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.ObjectIns.objPayVC, namespace: "object") {
                        
                        let paymentVC = CTMemCache.sharedInstance.get(VCAppLetor.ObjectIns.objPayVC, namespace: "object")?.data as! VCPayNowViewController
                        
                        WXApi.handleOpenURL(url, delegate: paymentVC)
                        
                        return true
                    }
                    else {
                        
                        WXApi.handleOpenURL(url, delegate: self)
                        return true
                    }
                }
            }
        }
        else {
            
            return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
            
        }
        
        
    }
    
    // MARK: - Wechat Pay
    
    func onResp(resp: BaseResp!) {
        
        
        
        if resp.isKindOfClass(PayResp.classForCoder()) {
            
            if (resp.errCode == WXSuccess.value) {
                
                let resultString = "\(resp.errCode)"
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payWechatTag, data: true, namespace: "pay")
                
            }
            else if resp.errCode == WXErrCodeUserCancel.value {
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payWechatTag, data: false, namespace: "pay")
            }
            else if resp.errCode == WXErrCodeAuthDeny.value {
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payWechatTag, data: false, namespace: "pay")
            }
            else {
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.payWechatTag, data: false, namespace: "pay")
            }
        }
        else if resp.isKindOfClass(SendMessageToWXResp.classForCoder()) {
            
            // Response from share to WeChat callback
            
        }
        
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

