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

class FoodListController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate, UIViewControllerTransitioningDelegate {
    
    var foodListItems: NSMutableArray = NSMutableArray()
    var cityList: NSMutableArray = NSMutableArray()
    
    var parentNavigationController : UINavigationController?
    
    var tableView: UITableView!
    
    let imageCache = NSCache()
    
    var hud: MBProgressHUD!
    
    var cityListView: UIView!
    let cityListViewWrap: UIView = UIView.newAutoLayoutView()
    var cityListAnimatedView: MGFashionMenuView!
    
    let cityButton: UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
    let selectedCityName: UIButton = UIButton(frame: CGRectMake(38.0, 0.0, 32.0, 32.0))
    let memberButton: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 32.0, 32.0))
    
    
    // City listing
    var serviceCityTitle: UILabel!
    var serviceCityTitleUnderline: CustomDrawView!
    
    var serviceCityNote: UILabel!
    
    var cityNamesView: UIView!
    
    var tapGuesture: UITapGestureRecognizer!
    
    // MARK: - LifetimeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.AppName
        
        let cityView: UIView = UIView(frame: CGRectMake(6.0, 0.0, 74.0, 32.0))
        cityView.backgroundColor = UIColor.clearColor()
        
        self.cityButton.setImage(UIImage(named: VCAppLetor.IconName.PlaceBlack)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.cityButton.layer.cornerRadius = self.cityButton.width / 2.0
        self.cityButton.backgroundColor = UIColor.clearColor()
        self.cityButton.addTarget(self, action: "willSwitchCity", forControlEvents: .TouchUpInside)
        cityView.addSubview(self.cityButton)
        
        self.selectedCityName.setTitle(VCAppLetor.StringLine.CityXian, forState: .Normal)
        self.selectedCityName.titleLabel?.font = VCAppLetor.Font.BigFont
        self.selectedCityName.titleLabel?.textAlignment = .Left
        self.selectedCityName.titleLabel?.textColor = UIColor.whiteColor()
        self.selectedCityName.backgroundColor = UIColor.clearColor()
        self.selectedCityName.addTarget(self, action: "addFood", forControlEvents: .TouchUpInside)
        cityView.addSubview(self.selectedCityName)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cityView)
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        // Member Center Entrain
        self.memberButton.setImage(UIImage(named: VCAppLetor.IconName.MemberBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        self.memberButton.addTarget(self, action: "userPanel", forControlEvents: .TouchUpInside)
        self.memberButton.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.memberButton)
        
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFood")
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        //        self.tableView.frame = self.view.bounds
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            self.loadFoodList()
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
        
        self.view.addSubview(self.tableView)
        // Register Cell View
        self.tableView.registerClass(FoodListTableViewCell.self, forCellReuseIdentifier: "foodItemCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 320.0
        
        // Init App Info -
        // Loading foodlist & init member info
        self.initAppInfo()
        
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
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
        return self.foodListItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FoodListTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("foodItemCell", forIndexPath: indexPath) as! FoodListTableViewCell
        
        //let foodDict:NSDictionary = foodListItems.objectAtIndex(indexPath.row) as! NSDictionary
        let foodItem: FoodItem = self.foodListItems.objectAtIndex(indexPath.row) as! FoodItem
        
        cell.foodItem = foodItem
        cell.setupViews()
        
        cell.setNeedsUpdateConstraints()
        
        return cell
        
    }
    
    //    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    //        println("Food: \(indexPath.row)")
    //    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 390
    //    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodIdentifier = foodListItems[indexPath.row].identifier
        foodViewerViewController.foodItem = self.foodListItems[indexPath.row] as? FoodItem
        foodViewerViewController.parentNav = self.navigationController
        
        self.navigationController!.showViewController(foodViewerViewController, sender: self)
        
    }
    
    // Override to support editing the table view
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if(self.foodListItems.count > 0) {
                
                
                let foodItem:FoodItem = self.foodListItems.objectAtIndex(indexPath.row) as! FoodItem
                
                if let foodToDelete = FoodItem.findFirst(attribute: "identifier", value: foodItem.identifier, contextType: BreezeContextType.Main) as? FoodItem {
                    foodToDelete.deleteInContextOfType(BreezeContextType.Background)
                }
                
                BreezeStore.saveInBackground({contextType -> Void in
                    
                    }, completion: {error -> Void in
                        self.loadFoodList(indexPath: indexPath)
                })
                
            }
            
        }
        else if editingStyle == .Insert {
            
        }
    }
    
    
    // MARK: - Functions
    func willSwitchCity() {
        
        
        if (!self.cityListAnimatedView.isShown) {
            self.cityListAnimatedView.show()
        }
        else {
            self.cityListAnimatedView.hide()
        }
        
//        let cityListVC: VCCityListViewController = VCCityListViewController()
//        cityListVC.view.frame = CGRectMake(0, 80, self.view.width, self.view.height-80)
//        cityListVC.modalPresentationStyle = UIModalPresentationStyle.Custom
//        cityListVC.cityList = self.cityList
//        cityListVC.transitioningDelegate = self
//        
//        
//        
//        self.presentViewController(cityListVC, animated: true) { () -> Void in
//            // Do something after present citylist vc
//        }
    }
    
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
            foodItem.title = VCAppLetor.StringLine.FoodTitle
            
            let startIndex = arc4random_uniform(30).hashValue
            let start = advance(VCAppLetor.StringLine.FoodDesc.startIndex, startIndex)
            let end = advance(VCAppLetor.StringLine.FoodDesc.endIndex, -1)
            var range = Range<String.Index>(start: start, end: end)
            foodItem.desc = VCAppLetor.StringLine.FoodDesc.substringWithRange(range)
            
            foodItem.addDate = NSDate()
            
            let serNumber = arc4random_uniform(7)
            
            let foodImageURL: String = "http://www.siyo.cc/t/mood\(serNumber + 1).jpg"
            foodItem.foodImage = foodImageURL
            
            foodItem.status = "在售"
            
            foodItem.originalPrice = "188元"
            foodItem.price = "118元"
            foodItem.unit = "/位"
            foodItem.remainingCount = "20"
            foodItem.endDate = "2015.6.30"
            foodItem.returnable = "可随时退款"
            foodItem.favoriteCount = "17"
            
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
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            // Foodlist
            self.loadFoodList()
            
            // Member info
            self.initMemberStatus()
            
            // City list
            self.getCityList()
        }
        else {
            self.showInternetUnreachable()
            self.hud.hide(true)
        }
        
    }
    
    func getCityList() {
        
        Alamofire.request(VCheckGo.Router.GetCityList()).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let list: Array = json["data"]["region_list"].arrayValue
                    
                    for item in list {
                        
                        let cid: String = item["region_id"].string!
                        let name: String = item["region_name"].string!
                        let orderId: Int = (item["sort_order"].string! as NSString).integerValue
                        
                        
                        let city: CityInfo = CityInfo(cid: cid, name: name)
                        city.sort_order = orderId
                        self.cityList.addObject(city)
                        
                    }
                    
                    // Sort city list by "sort_order" given from server
                    for (var i=0; i<self.cityList.count; i++) {
                        
                        let city: CityInfo = self.cityList[i] as! CityInfo
                        
                        for (var j=i+1; j<self.cityList.count; j++) {
                            
                            let cityToBeCompared: CityInfo = self.cityList[j] as! CityInfo
                            
                            if city.sort_order > cityToBeCompared.sort_order {
                                self.cityList.exchangeObjectAtIndex(i, withObjectAtIndex: j)
                            }
                        }
                    }
                    
                    // Setup city list views
                    self.cityListView = UIView(frame: CGRectMake(0, 64, self.view.width, self.view.height-64))
                    self.cityListView.backgroundColor = UIColor.darkGrayColor()
                    
                    
                    self.serviceCityTitle = UILabel(frame: CGRectMake(60, 80, self.view.width-120, 30))
                    self.serviceCityTitle.text = VCAppLetor.StringLine.ServiceCityTitle
                    self.serviceCityTitle.font = VCAppLetor.Font.NormalFont
                    self.serviceCityTitle.textAlignment = .Left
                    self.serviceCityTitle.textColor = UIColor.whiteColor()
                    self.cityListView.addSubview(self.serviceCityTitle)
                    
                    self.serviceCityTitleUnderline = CustomDrawView(frame: CGRectMake(60, 115, self.view.width-120, 5))
                    self.serviceCityTitleUnderline.drawType = "DoubleLine"
                    self.serviceCityTitleUnderline.lineColor = UIColor.whiteColor()
                    self.cityListView.addSubview(self.serviceCityTitleUnderline)
                    
                    self.serviceCityNote = UILabel(frame: CGRectMake(30, self.cityListView.height-50, self.view.width-60, 20))
                    self.serviceCityNote.text = VCAppLetor.StringLine.ServiceCityNote
                    self.serviceCityNote.font = VCAppLetor.Font.SmallFont
                    self.serviceCityNote.textAlignment = .Center
                    self.serviceCityNote.textColor = UIColor.lightGrayColor()
                    self.cityListView.addSubview(self.serviceCityNote)
                    
                    
                    self.cityNamesView = UIView(frame: CGRectMake(60, 120, self.view.width-120, 180))
                    if self.cityList.count > 0 {
                        
                        for (var i=0; i<self.cityList.count; i++) {
                            
                            let ins: CGFloat = CGFloat(i)
                            
                            var cityItem: CityInfo = self.cityList.objectAtIndex(i) as! CityInfo
                            
                            let cityName: UIButton = UIButton(frame: CGRectMake(0.0, 60.0*ins, self.view.width-120, 50.0))
                            cityName.setTitle(cityItem.city_name, forState: .Normal)
                            cityName.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                            cityName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                            cityName.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
                            cityName.titleLabel?.textAlignment = .Left
                            cityName.titleLabel?.font = VCAppLetor.Font.XXXLarge
                            cityName.tag = (cityItem.city_id as NSString).integerValue
                            cityName.addTarget(self, action: "didCityTap:", forControlEvents: .TouchUpInside)
                            
                            self.cityNamesView.addSubview(cityName)
                        }
                    }
                    
                    self.cityListView.addSubview(self.cityNamesView)
                    
                    self.tapGuesture = UITapGestureRecognizer(target: self, action: "cityViewDidTap:")
                    self.tapGuesture.numberOfTapsRequired = 1
                    self.tapGuesture.numberOfTouchesRequired = 1
                    
                    self.cityListView.addGestureRecognizer(self.tapGuesture)
                    
                    self.cityListAnimatedView = MGFashionMenuView(menuView: self.cityListView, animationType: MGAnimationType.Wave)
                    
                    self.view.addSubview(self.cityListAnimatedView)
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                println("ERROR @ Request for city list : \(error?.localizedDescription)")
            }
        })
    }
    
    func cityViewDidTap(gesture: UITapGestureRecognizer) {
        
        self.cityListAnimatedView.hide()
    }
    
    func didCityTap(cityName: UIButton) {
        
        println("cityid: \(cityName.tag)")
        self.cityListAnimatedView.hide()
    }
    
    func initMemberStatus() {
        
        // Get token from app data, connect serverside to auth user login status
        if let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings { // Get token
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: token.value, namespace: "token")
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
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: "0", namespace: "token")
        }
        
        
        let tokenString: String = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
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
                            
                            BreezeStore.saveInMain({ contextType -> Void in
                                
                                token.sid = "\(NSDate())"
                                token.value = json["data"]["token"].string!
                                
                                println("token changed: \(token.value)")
                                
                            })
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: json["data"]["token"].string!, namespace: "token")
                        }
                        // update local data
                        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInMain({ contextType -> Void in
                                
                                isLogin.sid = "\(NSDate())"
                                isLogin.value = "1"
                                
                            })
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: true, namespace: "member")
                        }
                        
                        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInMain({ contextType -> Void in
                                
                                cMid.sid = "\(NSDate())"
                                cMid.value = json["data"]["member_id"].string!
                                
                                println("currentMid: \(cMid.value)")
                                
                            })
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: json["data"]["member_id"].string!, namespace: "member")
                        }
                        
                        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
                            
                            BreezeStore.saveInMain({ contextType -> Void in
                                
                                loginType.sid = "\(NSDate())"
                                loginType.value = VCAppLetor.LoginType.Token
                                
                            })
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.Token, namespace: "member")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.loadMemberInfo(cMid)
                        })
                        
                        
                    }
                    else { // Login fail
                        
                        self.hud.hide(true)
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                        CTMemCache.sharedInstance.cleanNamespace("member")
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: "0", namespace: "token")
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
            self.hud!.hide(true)
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
    
    func loadMemberInfo(mid: String) {
        
        if let member = Member.findFirst(attribute: "mid", value: mid, contextType: BreezeContextType.Main) as? Member{
            
            // setup cache & user panel interface
            CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: member.nickname, namespace: "member")
            CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: member.email, namespace: "member")
            CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: member.phone, namespace: "member")
            CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: member.iconURL, namespace: "member")
        }
        else {
            println("Can not find local data after loginWithToken")
        }
        
        self.hud.hide(true)
        
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
    
    // Bar button with icon
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        
        let button: UIButton = UIButton.newAutoLayoutView()
        
        if imageName != nil {
            button.setImage(UIImage(named: imageName!)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        if title != nil {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSizeMake(90.0, 24.0))
        button.frame = CGRectMake(0.0, 0.0, 42.0, 42.0)
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        
        if action != nil {
            button.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
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
        
        
    }
    
    func loadFoodList(indexPath:NSIndexPath? = nil) {
        
        // Check Internet connection
        self.foodListItems.removeAllObjects()
        
        let foodItems:NSArray = FoodItem.findAll(predicate: nil, sortedBy: "addDate", ascending: false, contextType: BreezeContextType.Main)
        
        
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
        
        self.tableView.stopRefreshAnimation()
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
    
    
    // MARK: - Internet Connection Notification
    override func reachabilityChanged(notification: NSNotification) {
        
        let reachability = notification.object as! Reachability
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            // Foodlist
            self.loadFoodList()
            
            // Member info
            self.initMemberStatus()
            
            // City List
            self.getCityList()
        }
        else {
            self.showInternetUnreachable()
            hud.hide(true)
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



