//
//  FoodListController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import RKDropdownAlert
import MBProgressHUD

class FoodListController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate {
    
    var foodListItems: NSMutableArray = NSMutableArray()
    
    var parentNavigationController : UINavigationController?
    
    var tableView: UITableView!
    
    let imageCache = NSCache()
    
    
    // MARK - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.AppName
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFood")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "userPanel")
        
        // Setup tableView
        self.tableView = UITableView()
        self.tableView.frame = self.view.bounds
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        // Register Cell View
        self.tableView.registerClass(FoodListTableViewCell.self, forCellReuseIdentifier: "foodItemCell")
        
        // Init App Info - 
        // Loading foodlist & init member info
        self.initAppInfo()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispoe of any resources that can be recreated
    }
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    // MARK: - Tableview data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        return foodListItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FoodListTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("foodItemCell", forIndexPath: indexPath) as! FoodListTableViewCell
        
        //let foodDict:NSDictionary = foodListItems.objectAtIndex(indexPath.row) as! NSDictionary
        let foodItem: FoodItem = foodListItems.objectAtIndex(indexPath.row) as! FoodItem
        
        cell.identifier = foodItem.identifier
        cell.foodTitle.text = foodItem.title
        cell.foodDesc.text = foodItem.desc
        
        let imageURL = foodItem.foodImage
        let foodImageView = cell.foodImageView
        
        if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
            foodImageView.image = image
        }
        else {
            
            foodImageView.image = nil
            
            cell.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                
                (request, _, image, error) in
                
                if error == nil && image != nil {
                    let foodImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.view.bounds.width, height: 100.0), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    self.imageCache.setObject(foodImage, forKey: request.URLString)
                    
                    if request.URLString == cell.request?.request.URLString {
                        foodImageView.image = foodImage
                    }
                    else {
                        // Resolve when the foodList has changed
                    }
                }
            }
        }
        
        return cell
        
    }
    
    //    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    //        println("Food: \(indexPath.row)")
    //    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodIdentifier = foodListItems[indexPath.row].identifier
        foodViewerViewController.title = "Food Detail"
        foodViewerViewController.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController!.showViewController(foodViewerViewController, sender: self)
        
    }
    
    // Override to support editing the table view
    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    
    if(self.foodListItems.count > 0) {
    
    let foodDict:NSDictionary = self.foodListItems.objectAtIndex(indexPath.row) as! NSDictionary
    let identifier:String = foodDict.objectForKey("identifier") as! String
    let predicate:NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")
    let foodToDelete:FoodItem = FoodItem.findFirst(predicate: predicate, sortedBy: nil, ascending: false, contextType: BreezeContextType.Background) as! FoodItem
    
    foodToDelete.deleteInContextOfType(BreezeContextType.Background)
    
    BreezeStore.saveInBackground({contextType -> Void in
    
    }, completion: {error -> Void in
    self.loadFoodList(indexPath: indexPath)
    })
    
    }
    
    }
    else if editingStyle == .Insert {
    
    }
    }
    */
    
    // MARK - Functions
    
    func userPanel() {
        
        let memberPanel: UserPanelViewController = UserPanelViewController()
        memberPanel.parentNav = self.navigationController
        self.navigationController?.showViewController(memberPanel, sender: self)
    }
    
    func addFood() {
        
        let foodIdentifier = "\(NSDate())"
        
        BreezeStore.saveInBackground({ contextType -> Void in
            
            let foodItem = FoodItem.createInContextOfType(contextType) as! FoodItem
            foodItem.identifier = foodIdentifier
            foodItem.title = "Food-\(foodIdentifier)"
            foodItem.desc = "Food Description Block with text and html content\nThis is the second line with link <a href='#'>website</a>"
            foodItem.addDate = NSDate()
            
            let serNumber = arc4random_uniform(7)
            
            let foodImageURL: String = "http://www.siyo.cc/t/mood\(serNumber + 1).jpg"
            foodItem.foodImage = foodImageURL
            
            }, completion: { error -> Void in
                
                if (error != nil) {
                    println("\(error?.localizedDescription)")
                }
                else {
                    self.insertRowAtTop(foodIdentifier)
                }
        })
        
    }
    
    func initAppInfo() {
        
        // Show hud
        let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Determinate
        hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            // Foodlist
            self.loadFoodList()
            
            // Member info
            self.initMemberStatus()
        }
        else {
            self.showInternetUnreachable()
        }
        
        hud.hide(true)
    }
    
    func initMemberStatus() {
        
        // Get token from app data, connect serverside to auth user login status
        if let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings { // Get token
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: token.value, namespace: "member")
        }
        else { // App version DO NOT exist, create one with empty token
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let tokenToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                tokenToBeCreate.sid = "\(NSDate())"
                tokenToBeCreate.name = "token"
                tokenToBeCreate.value = "0"
                tokenToBeCreate.type = VCAppLetor.SettingType.AppConfig
                tokenToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: "", namespace: "member")
        }
        
        
        let tokenString: String = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "member")?.data as! String
        let cMid: String = self.currentMid()
        println("token: \(tokenString), currentMid: \(cMid)")
        
        if (tokenString != "0" && cMid != "0") {
            
            // Connnect server to async member signin status, check if member token is validate
            
            Alamofire.request(VCheckGo.Router.LoginWithToken(tokenString, cMid)).validate().responseSwiftyJSON({
                (request, response, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string == "1" { // Login with token succeed
                        
                        
                        // Cache token
                        if let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInBackground({ contextType -> Void in
                                
                                token.sid = "\(NSDate())"
                                token.value = json["data"]["token"].string!
                                
                                println("token changed: \(token.value)")
                                
                                }, completion: { error -> Void in
                                    
                                    if (error != nil) {
                                        println("ERROR @ update token value @ loginWithToken : \(error?.localizedDescription)")
                                    }
                                    else {
                                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: json["data"]["token"].string!, namespace: "member")
                                    }
                            })
                        }
                        // update local data
                        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInBackground({ contextType -> Void in
                                
                                isLogin.sid = "\(NSDate())"
                                isLogin.value = "1"
                                
                                }, completion: { error -> Void in
                                    
                                    if (error != nil) {
                                        println("ERROR @ update isLogin value @ loginWithToken : \(error?.localizedDescription)")
                                    }
                                    else {
                                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: true, namespace: "member")
                                    }
                            })
                        }
                        
                        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInBackground({ contextType -> Void in
                                
                                cMid.sid = "\(NSDate())"
                                cMid.value = json["data"]["member_id"].string!
                                
                                println("currentMid: \(cMid.value)")
                                
                                }, completion: { error -> Void in
                                    
                                    if (error != nil) {
                                        println("ERROR @ update currentMid value @ loginWithToken : \(error?.localizedDescription)")
                                    }
                                    else {
                                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: json["data"]["member_id"].string!, namespace: "member")
                                    }
                            })
                        }
                        
                        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInBackground({ contextType -> Void in
                                
                                loginType.sid = "\(NSDate())"
                                loginType.value = VCAppLetor.LoginType.Token
                                
                                }, completion: { error -> Void in
                                    
                                    if (error != nil) {
                                        println("ERROR @ update loginType value @ loginWithToken : \(error?.localizedDescription)")
                                    }
                                    else {
                                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.Token, namespace: "member")
                                    }
                            })
                        }
                        
                        
                        
                    }
                    else { // Login fail
                        println("ERROR @ Login fail with loginWithToken : " + json["status"]["error_desc"].string!)
                        
                    }
                }
                else {
                    println("ERROR @ Request for LoginWithToken: \(error?.localizedDescription)")
                }
            })
            
        }
        else {
            
            // Clean up local cache with member status to ensure true
            self.cleanLocalMemberStatus()
        }
    }
    
    // Get current mid
    func currentMid() -> String {
        
        if let cmid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            return cmid.value as String
        }
        else {
            return "0"
        }
    }
    
    // Clean local cache and local data
    func cleanLocalMemberStatus() {
        
        CTMemCache.sharedInstance.cleanNamespace("member")
        
        // ========== ISLOGIN ===========
        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                isLogin.sid = "\(NSDate())"
                isLogin.value = "0"
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update isLogin value : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: false, namespace: "member")
                    }
            })
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                let isLoginToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                isLoginToBeCreate.sid = "\(NSDate())"
                isLoginToBeCreate.name = VCAppLetor.SettingName.optNameIsLogin
                isLoginToBeCreate.value = "0"
                isLoginToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                isLoginToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: false, namespace: "member")
        }
        // ====== LOGINTYPE ========
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.None
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update loginType value : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.None, namespace: "member")
                    }
            })
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                let loginTypeToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                loginTypeToBeCreate.sid = "\(NSDate())"
                loginTypeToBeCreate.name = VCAppLetor.SettingName.optNameLoginType
                loginTypeToBeCreate.value = VCAppLetor.LoginType.None
                loginTypeToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                loginTypeToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.None, namespace: "member")
        }
        
        // ======== CURRENT MID ============
        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                cMid.sid = "\(NSDate())"
                cMid.value = "0"
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update loginType value : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: "0", namespace: "member")
                    }
            })
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                let cMidToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                cMidToBeCreate.sid = "\(NSDate())"
                cMidToBeCreate.name = VCAppLetor.SettingName.optNameCurrentMid
                cMidToBeCreate.value = "0"
                cMidToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                cMidToBeCreate.data = ""
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: "0", namespace: "member")
        }
    }
    
    
    // Add new FoodItem
    func insertRowAtTop(identifier: String) {
        
        let foodItem: FoodItem = FoodItem.findFirst(attribute: "identifier", value: identifier, contextType: BreezeContextType.Background) as! FoodItem
        
        self.tableView.beginUpdates()
        
        self.foodListItems.insertObject(foodItem, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
        self.tableView.endUpdates()
        
    }
    
    func refreshFoodList() {
        //
        //        refreshControl?.beginRefreshing()
        //
        //        loadFoodList()
        //
        //        refreshControl?.endRefreshing()
    }
    
    func loadFoodList(indexPath:NSIndexPath? = nil) {
        
        // Check Internet connection
        foodListItems.removeAllObjects()
        
        let foodItems:NSArray = FoodItem.findAll(predicate: nil, sortedBy: "addDate", ascending: false, contextType: BreezeContextType.Background)
        
        if(foodItems.count > 0) {
            
            for food in foodItems {
                
                let foodItem:FoodItem = food as! FoodItem
                self.foodListItems.addObject(foodItem)
            }
        }
        
        if(indexPath != nil) {
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        self.tableView.reloadData()
        
    }
    
    func setInternetReachableTableStyle(reachability: Bool) {
        
        if reachability {
            self.tableView.scrollEnabled = true
        }
        else {
            self.tableView.scrollEnabled = false
        }
        
    }
    
    func showInternetUnreachable() {
        
        self.foodListItems.removeAllObjects()
        self.tableView.reloadData()
        
        let bgView: UIView = UIView()
        bgView.frame = self.view.bounds
        
        let internetIcon: UIImageView = UIImageView.newAutoLayoutView()
        internetIcon.alpha = 0.1
        internetIcon.image = UIImage(named: VCAppLetor.IconName.InternetBlack)
        bgView.addSubview(internetIcon)
        
        let internetUnreachLabel: UILabel = UILabel.newAutoLayoutView()
        internetUnreachLabel.text = VCAppLetor.StringLine.InternetUnreachable
        internetUnreachLabel.font = VCAppLetor.Font.NormalFont
        internetUnreachLabel.textColor = UIColor.lightGrayColor()
        internetUnreachLabel.textAlignment = .Center
        bgView.addSubview(internetUnreachLabel)
        
        self.tableView.backgroundView = bgView
//        self.tableView.scrollEnabled = false
        
        internetIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        internetIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
        internetIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
        
        internetUnreachLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
        internetUnreachLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: internetIcon, withOffset: 20.0)
        internetUnreachLabel.autoAlignAxisToSuperviewAxis(.Vertical)
    }
    
    
    // MARK: - Notification
    func reachabilityChanged(notification: NSNotification) {
        
        let reachability = notification.object as! Reachability
        
        if reachability.isReachable() {
            self.loadFoodList()
        } else {
            self.showInternetUnreachable()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        println("segue call")
        
        println("\(sender)")
        
        if(segue.identifier == "viewFoodDetail") {
            (segue.destinationViewController as! FoodViewerViewController).foodIdentifier = sender?.identifier
        }
        
    }
    
    
}



