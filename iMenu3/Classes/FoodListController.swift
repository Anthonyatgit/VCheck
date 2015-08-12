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
import PBWebViewController

class FoodListController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, RKDropdownAlertDelegate, UIViewControllerTransitioningDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate {
    
    var foodListItems: NSMutableArray = NSMutableArray()
    var cityList: NSMutableArray = NSMutableArray()
    
    var parentNavigationController : UINavigationController?
    
    var tableView: UITableView!
    
    var currentPage: Int = 1
    var haveMore: Bool?
    
    var isLoadingFood: Bool = false
    
    let foodImageCache = NSCache()
    
    var hud: MBProgressHUD!
    
    var cityListView: UIView!
    var cityListAnimatedView: MGFashionMenuView!
    
    //    let cityButton: UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 28.0, 28.0))
    var cityButton: HamburgerButton! = nil
    let selectedCityName: UIButton = UIButton(frame: CGRectMake(30.0, 0.0, 50.0, 28.0))
    let memberButton: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 26.0, 26.0))
    
    
    // City listing
    var serviceCityTitle: UILabel!
    var serviceCityTitleUnderline: CustomDrawView!
    
    var serviceCityNote: UILabel!
    
    var cityNamesView: UIView!
    
    var tapGuesture: UITapGestureRecognizer!
    
    var locationService: BMKLocationService!
    var locationSearcher: BMKGeoCodeSearch!
    var cityCode: Int = 0
    
    var isRefreshAction: Bool = false
    
    var didMemberInit: Bool = false
    
    // MARK: - LifetimeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appIntroVC: VCAppViewController = VCAppViewController()
        
        UIApplication.sharedApplication().keyWindow?.addSubview(appIntroVC.view)
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.AppName
        
        let cityView: UIView = UIView(frame: CGRectMake(6.0, 0.0, 86.0, 32.0))
        cityView.backgroundColor = UIColor.clearColor()
        
        self.cityButton = HamburgerButton(frame: CGRectMake(0, 0, 60, 60))
        self.cityButton.addTarget(self, action: "willSwitchCity", forControlEvents: .TouchUpInside)
        
        let newTransform: CGAffineTransform = CGAffineTransformScale(self.cityButton.transform, 0.52, 0.52)
        self.cityButton.transform = newTransform
        self.cityButton.center = CGPointMake(14, 16)
        
        cityView.addSubview(self.cityButton)
        
        self.selectedCityName.setTitle(VCAppLetor.StringLine.Locating, forState: .Normal)
        self.selectedCityName.titleLabel?.font = VCAppLetor.Font.BigFont
        self.selectedCityName.titleLabel?.textAlignment = .Left
        self.selectedCityName.titleLabel?.textColor = UIColor.whiteColor()
        self.selectedCityName.backgroundColor = UIColor.clearColor()
        self.selectedCityName.addTarget(self, action: "willSwitchCity", forControlEvents: .TouchUpInside)
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
        
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            self.initAppInfo()
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
        
        self.view.addSubview(self.tableView)
        // Register Cell View
        self.tableView.registerClass(FoodListTableViewCell.self, forCellReuseIdentifier: "foodItemCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = VCAppLetor.ConstValue.FoodItemCellHeight
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        // Image disk dir
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
        directoryURL!.URLByAppendingPathComponent("product")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(directoryURL!.path!) {
            
            NSFileManager.defaultManager().createDirectoryAtPath(directoryURL!.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        // Init App Info -
        // Loading foodlist & init member info
        self.getSavedCity()
        self.setupCityView()
        self.initAppInfo()
        
        self.initMemberStatus()
        
        self.startLocationService()
        
        self.view.setNeedsUpdateConstraints()
        
        self.isAllowedNotification()
        
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Cache Navigation Controller Instance
        CTMemCache.sharedInstance.set(VCAppLetor.ObjectIns.objNavigation, data: self.navigationController, namespace: "object")
        CTMemCache.sharedInstance.set(VCAppLetor.ObjectIns.objHome, data: self, namespace: "object")
        
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
        let foodInfo: FoodInfo = self.foodListItems.objectAtIndex(indexPath.row) as! FoodInfo
        
        cell.foodInfo = foodInfo
        cell.imageCache = self.foodImageCache
        cell.setupViews()
        
        cell.setNeedsUpdateConstraints()
        
        let delayInSeconds: UInt64 = 1
        let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            
            
        }
        
        return cell
        
    }
    
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 390
    //    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodInfo = self.foodListItems[indexPath.row] as? FoodInfo
        foodViewerViewController.parentNav = self.navigationController
        
        self.navigationController!.showViewController(foodViewerViewController, sender: self)
        
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.isLoadingFood || self.foodListItems.count < 1 {
            
            return
        }
        
        if !self.reachability.isReachable() {
            
            self.tableView.stopRefreshAnimation()
            
            return
            
        }
        
        if (scrollView.contentOffset.y + self.view.height > scrollView.contentSize.height * 0.8) && self.haveMore != nil && self.haveMore! && self.foodListItems.count > 0 {
            
            self.isLoadingFood = true
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let currentPageNum: Int = ("\(ceil(CGFloat(self.foodListItems.count / VCAppLetor.ConstValue.DefaultItemCountPerPage)))" as NSString).integerValue
            let nextPageNum: Int = currentPageNum + 1
            Alamofire.request(VCheckGo.Router.GetProductList(self.cityCode, nextPageNum)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string! == "1" {
                            
                            // Deal with paging
                            if json["paginated"]["more"].string! == "1" {
                                self.haveMore = true
                            }
                            else {
                                self.haveMore = false
                            }
                            
                            // Deal with the listing
                            
                            let productList: Array = json["data"]["article_list"].arrayValue
                            let addedFood: NSMutableArray = NSMutableArray()
                            
                            for item in productList {
                                
                                let product: FoodInfo = FoodInfo(id: (item["article_id"].string! as NSString).integerValue)
                                
                                product.title = item["title"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                product.addDate = dateFormatter.dateFromString(item["article_date"].string!)!
                                
                                product.desc = item["summary"].string!
                                product.subTitle = item["sub_title"].string!
                                product.foodImage = item["article_image"]["source"].string!
                                product.status = item["menu_info"]["menu_status"]["menu_status_id"].string!
                                product.originalPrice = item["menu_info"]["price"]["original_price"].string!
                                product.price = item["menu_info"]["price"]["special_price"].string!
                                product.priceUnit = item["menu_info"]["price"]["price_unit"].string!
                                product.unit = item["menu_info"]["menu_unit"]["menu_unit"].string!
                                product.remainingCount = item["menu_info"]["stock"]["menu_count"].string!
                                product.remainingCountUnit = item["menu_info"]["stock"]["menu_unit"].string!
                                product.remainder = item["menu_info"]["remainder_time"].string!
                                product.outOfStock = item["menu_info"]["stock"]["out_of_stock_info"].string!
                                product.endDate = item["menu_info"]["end_date"].string!
                                product.returnable = "1"
                                product.memberIcon = item["member_info"]["icon_image"]["thumb"].string!
                                product.memberName = item["member_info"]["member_name"].string!
                                
                                product.menuId = item["menu_info"]["menu_id"].string!
                                product.menuName = item["menu_info"]["menu_name"].string!
                                
                                product.storeId = item["store_info"]["store_id"].string!
                                product.storeName = item["store_info"]["store_name"].string!
                                product.address = item["store_info"]["address"].string!
                                product.longitude = (item["store_info"]["longitude_num"].string! as NSString).doubleValue
                                product.latitude = (item["store_info"]["latitude_num"].string! as NSString).doubleValue
                                product.tel1 = item["store_info"]["tel_1"].string!
                                product.tel2 = item["store_info"]["tel_2"].string!
                                product.acp = item["store_info"]["per"].string!
                                product.icon_thumb = item["store_info"]["icon_image"]["thumb"].string!
                                product.icon_source = item["store_info"]["icon_image"]["source"].string!
                                
                                
                                addedFood.addObject(product)
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.insertRowsAtBottom(addedFood)
                                self.isLoadingFood = false
                                
                                if !self.haveMore! {
                                    
                                }
                            })
                        }
                        else {
                            self.isLoadingFood = false
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    
                }
                else {
                    println("ERROR @ Loading more food : \(error?.localizedDescription)")
                    self.isLoadingFood = false
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    // MARK: - Location Service & BMKLocationService Delegate
    
    func startLocationService() {
        
        BMKLocationService.setLocationDesiredAccuracy(kCLLocationAccuracyBest)
        BMKLocationService.setLocationDistanceFilter(VCAppLetor.ConstValue.LocationServiceDistanceFilter)
        
        self.locationService = BMKLocationService()
        self.locationService.delegate = self
        
        self.locationService.startUserLocationService()
    }
    
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        //        println("[LOCATION]: Heading - \(userLocation.heading)")
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.LocLong, data: userLocation.location.coordinate.longitude, namespace: "location")
        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.LocLat, data: userLocation.location.coordinate.latitude, namespace: "location")
        
        self.locationSearcher = BMKGeoCodeSearch()
        self.locationSearcher.delegate = self
        
        let pt: CLLocationCoordinate2D = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)
        let reverseGeoCodeSearchOption: BMKReverseGeoCodeOption = BMKReverseGeoCodeOption()
        reverseGeoCodeSearchOption.reverseGeoPoint = pt
        
        self.locationSearcher.reverseGeoCode(reverseGeoCodeSearchOption)
        
    }
    
    func didFailToLocateUserWithError(error: NSError!) {
        
        //RKDropdownAlert.title(VCAppLetor.StringLine.LocationUserFail, message: error.localizedDescription, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        
        if !CLLocationManager.locationServicesEnabled() {
            
            let alert: UIAlertView = UIAlertView(title: VCAppLetor.StringLine.LocationServiceDisabled, message: VCAppLetor.StringLine.EnableLS, delegate: nil, cancelButtonTitle: VCAppLetor.StringLine.Done)
            alert.show()
        }
        else {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                
                let alert: UIAlertView = UIAlertView(title: VCAppLetor.StringLine.LocationServiceNotAuth, message: VCAppLetor.StringLine.EnableLSForApp, delegate: nil, cancelButtonTitle: VCAppLetor.StringLine.Done)
                alert.show()
            }
        }
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
        if error.value == BMK_SEARCH_NO_ERROR.value {
            
            self.selectedCityName.setTitle(result.addressDetail.city!.stringByReplacingOccurrencesOfString("市", withString: ""), forState: .Normal)
            
            if result.addressDetail.city! == VCAppLetor.City.Xian.rawValue {
                
                // Load food available in Xi'an
                self.cityCode = 29
            }
            else {
                self.cityCode = 9999
            }
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optSelectedCity, data: self.cityCode, namespace: "location")
            
            if let selectedCity = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optSelectedCity, contextType: BreezeContextType.Main) as? Settings { // Get current app version
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    selectedCity.value = "\(self.cityCode)"
                })
            }
            else { // App version DO NOT exist, create one with version "1.0"
                
                BreezeStore.saveInMain({ contextType -> Void in
                    
                    let versionToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                    
                    versionToBeCreate.sid = "\(NSDate())"
                    versionToBeCreate.name = VCAppLetor.SettingName.optSelectedCity
                    versionToBeCreate.value = "\(self.cityCode)"
                    versionToBeCreate.type = VCAppLetor.SettingType.AppConfig
                    versionToBeCreate.data = ""
                    
                })
            }
            
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.LocationUserFail, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
    }
    
    
    
    // MARK: - Functions
    
    func getSavedCity() {
        
        if let selectedCity = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optSelectedCity, contextType: BreezeContextType.Main) as? Settings { // Get current app version
            
            if selectedCity.value != "29" {
                RKDropdownAlert.title(VCAppLetor.StringLine.YourCityNotInService, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
            self.cityCode = VCAppLetor.ConstValue.DefaultCityCode
        }
        else {
            self.cityCode = VCAppLetor.ConstValue.DefaultCityCode
        }
    }
    
    func setupCityView() {
        
        // Setup city list views
        self.cityListView = UIView(frame: CGRectMake(0, 64, self.view.width, self.view.height-64))
        self.cityListView.tag = 1
        self.cityListView.backgroundColor = UIColor.darkBlack()
        
        let bgImageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.width, self.view.height-64))
        bgImageView.image = UIImage(named: "user_nep.jpg")
        self.cityListView.addSubview(bgImageView)
        
        self.tapGuesture = UITapGestureRecognizer(target: self, action: "cityViewDidTap:")
        self.tapGuesture.numberOfTapsRequired = 1
        self.tapGuesture.numberOfTouchesRequired = 1
        
        self.cityListView.addGestureRecognizer(self.tapGuesture)
        self.cityListAnimatedView = MGFashionMenuView(menuView: self.cityListView, animationType: MGAnimationType.SoftBounce)
        
        self.view.addSubview(self.cityListAnimatedView)
    }
    
    func willSwitchCity() {
        
        self.cityButton.showsMenu = !self.cityButton.showsMenu
        
        if (!self.cityListAnimatedView.isShown) {
            self.cityListAnimatedView.show()
        }
        else {
            self.cityListAnimatedView.hide()
        }
        
    }
    
    func userPanel() {
        
        if self.didMemberInit {
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                
                println("member: \(memberPanel.memberInfo!.bindWechat!)")
            }
            self.navigationController?.showViewController(memberPanel, sender: self)
        }
        
    }
    
    func initAppInfo() {
        
        if !self.isRefreshAction {
            
            // Show hud
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.hud.mode = MBProgressHUDMode.Indeterminate
            self.hud.labelText = VCAppLetor.StringLine.isLoading
        }
        
        
        if reachability.isReachable() {
            
            // Foodlist
            self.loadFoodList()
        }
        else {
            self.hud.hide(true)
            self.showInternetUnreachable()
        }
        
        self.isRefreshAction = true
        
    }
    
    func loadFoodList() {
        
        // Copy to ensure the foodlist lost
        let foodListCopy: NSMutableArray = NSMutableArray(array: self.foodListItems)
        
        // Request for product list
        
        Alamofire.request(VCheckGo.Router.GetProductList(self.cityCode, self.currentPage)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // Available City?
                        if json["paginated"]["total"].string! == "0" {
                            
                            self.cityCode = 29
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.YourCityNotInService, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            self.hud.hide(true)
                            self.tableView.stopRefreshAnimation()
                            return
                        }
                        
                        // Deal with paging
                        if json["paginated"]["more"].string! == "1" {
                            self.haveMore = true
                        }
                        else {
                            self.haveMore = false
                        }
                        
                        // Deal with the current page listing
                        
                        self.foodListItems.removeAllObjects()
                        let productList: Array = json["data"]["article_list"].arrayValue
                        
                        for item in productList {
                            
                            let product: FoodInfo = FoodInfo(id: (item["article_id"].string! as NSString).integerValue)
                            
                            product.title = item["title"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            product.addDate = dateFormatter.dateFromString(item["article_date"].string!)!
                            
                            product.desc = item["summary"].string!
                            product.subTitle = item["sub_title"].string!
                            product.foodImage = item["article_image"]["source"].string!
                            product.status = item["menu_info"]["menu_status"]["menu_status_id"].string!
                            product.originalPrice = item["menu_info"]["price"]["original_price"].string!
                            product.price = item["menu_info"]["price"]["special_price"].string!
                            product.priceUnit = item["menu_info"]["price"]["price_unit"].string!
                            product.unit = item["menu_info"]["menu_unit"]["menu_unit"].string!
                            product.remainingCount = item["menu_info"]["stock"]["menu_count"].string!
                            product.remainingCountUnit = item["menu_info"]["stock"]["menu_unit"].string!
                            product.remainder = item["menu_info"]["remainder_time"].string!
                            product.outOfStock = item["menu_info"]["stock"]["out_of_stock_info"].string!
                            product.endDate = item["menu_info"]["end_date"].string!
                            product.returnable = "1"
                            
                            product.memberIcon = item["member_info"]["icon_image"]["thumb"].string!
                            product.memberName = item["member_info"]["member_name"].string!
                            
                            product.menuId = item["menu_info"]["menu_id"].string!
                            product.menuName = item["menu_info"]["menu_name"].string!
                            
                            product.storeId = item["store_info"]["store_id"].string!
                            product.storeName = item["store_info"]["store_name"].string!
                            product.address = item["store_info"]["address"].string!
                            product.longitude = (item["store_info"]["longitude_num"].string! as NSString).doubleValue
                            product.latitude = (item["store_info"]["latitude_num"].string! as NSString).doubleValue
                            product.tel1 = item["store_info"]["tel_1"].string!
                            product.tel2 = item["store_info"]["tel_2"].string!
                            product.acp = item["store_info"]["per"].string!
                            product.icon_thumb = item["store_info"]["icon_image"]["thumb"].string!
                            product.icon_source = item["store_info"]["icon_image"]["source"].string!
                            
                            
                            self.foodListItems.addObject(product)
                        }
                        
                        let bView: UIView = UIView(frame: self.view.bounds)
                        bView.backgroundColor = UIColor.whiteColor()
                        
                        self.tableView.backgroundView = bView
                        
                        
                        self.getCityList()
                    })
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    
                    // Restore FoodList
                    self.foodListItems = foodListCopy
                }
            }
            else {
                println("ERROR @ Get Product List Request: \(error?.localizedDescription)")
                
                // Restore FoodList
                self.foodListItems = foodListCopy
                
                // Restore interface
                self.hud.hide(true)
                self.tableView.stopRefreshAnimation()
                
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                
                self.showInternetUnreachable()
            }
            
        })
        
        
    }
    
    func getCityList() {
        
        self.cityList.removeAllObjects()
        
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
                        city.open_status = item["is_open"].string!
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
                    
                    
                    if self.serviceCityTitle != nil {
                        self.serviceCityTitle.removeFromSuperview()
                        self.serviceCityTitleUnderline.removeFromSuperview()
                        self.serviceCityNote.removeFromSuperview()
                        self.cityNamesView.removeFromSuperview()
                    }
                    
                    
                    
                    self.serviceCityTitle = UILabel(frame: CGRectMake(60, 60, self.view.width-120, 30))
                    self.serviceCityTitle.text = VCAppLetor.StringLine.ServiceCityTitle
                    self.serviceCityTitle.font = VCAppLetor.Font.NormalFont
                    self.serviceCityTitle.textAlignment = .Left
                    self.serviceCityTitle.textColor = UIColor.whiteColor()
                    self.cityListView.addSubview(self.serviceCityTitle)
                    
                    self.serviceCityTitleUnderline = CustomDrawView(frame: CGRectMake(60, 95, self.view.width-120, 5))
                    self.serviceCityTitleUnderline.drawType = "DoubleLine"
                    self.serviceCityTitleUnderline.lineColor = UIColor.whiteColor()
                    self.cityListView.addSubview(self.serviceCityTitleUnderline)
                    
                    self.serviceCityNote = UILabel(frame: CGRectMake(30, self.cityListView.height-50, self.view.width-60, 20))
                    self.serviceCityNote.text = VCAppLetor.StringLine.ServiceCityNote
                    self.serviceCityNote.font = VCAppLetor.Font.SmallFont
                    self.serviceCityNote.textAlignment = .Center
                    self.serviceCityNote.textColor = UIColor.lightGrayColor()
                    self.cityListView.addSubview(self.serviceCityNote)
                    
                    let vHeight: CGFloat = CGFloat(("\(self.cityList.count)" as NSString).floatValue * 50.0)
                    self.cityNamesView = UIView(frame: CGRectMake(60, 100, self.view.width-120, vHeight))
                    
                    if self.cityList.count > 0 {
                        
                        for (var i=0; i<self.cityList.count; i++) {
                            
                            let ins: CGFloat = CGFloat(i)
                            
                            var cityItem: CityInfo = self.cityList.objectAtIndex(i) as! CityInfo
                            
                            let cityName: UIButton = UIButton(frame: CGRectMake(0.0, 50.0*ins+10.0, self.view.width-120, 40.0))
                            cityName.setTitle(cityItem.city_name, forState: .Normal)
                            cityName.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                            cityName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                            cityName.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
                            cityName.titleLabel?.textAlignment = .Left
                            cityName.titleLabel?.font = VCAppLetor.Font.XXXLarge
                            cityName.tag = (cityItem.city_id as NSString).integerValue
                            cityName.addTarget(self, action: "didCityTap:", forControlEvents: .TouchUpInside)
                            
                            self.cityNamesView.addSubview(cityName)
                            
                            if cityItem.open_status == "2" {
                                
                                cityName.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.4), forState: .Normal)
                                cityName.enabled = false
                                
                                let opensoon: UILabel = UILabel(frame: CGRectMake(80.0, 50.0*ins+22.0, 100.0, 20.0))
                                opensoon.text = VCAppLetor.StringLine.OpenSoon
                                opensoon.textAlignment = .Left
                                opensoon.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
                                opensoon.font = VCAppLetor.Font.BigFont
                                self.cityNamesView.addSubview(opensoon)
                            }
                        }
                    }
                    
                    self.cityListView.addSubview(self.cityNamesView)
                    
                    self.isLoadingFood = false
                    
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    self.tableView.reloadData()
                    
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                }
            }
            else {
                println("ERROR @ Request for city list : \(error?.localizedDescription)")
                
                // Restore interface
                self.hud.hide(true)
                self.tableView.stopRefreshAnimation()
                
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        })
    }
    
    func showOutCall() {
        
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.LINKS.route, namespace: "Links") {
            
            let route = CTMemCache.sharedInstance.get(VCAppLetor.LINKS.route, namespace: "Links")?.data as! String
            
            if route == VCAppLetor.PNRoute.web.rawValue {
                let url = CTMemCache.sharedInstance.get(VCAppLetor.LINKS.param, namespace: "Links")?.data as! String
                
                let webVC: PBWebViewController = PBWebViewController()
                webVC.URL = NSURL(string: url)
                
                let activity: PBSafariActivity = PBSafariActivity()
                webVC.applicationActivities = [activity]
                
                self.navigationController?.showViewController(webVC, sender: self)
                
            }
            if route == VCAppLetor.PNRoute.home.rawValue {
                
            }
            if route == VCAppLetor.PNRoute.article.rawValue {
                
                let articleIdStr = CTMemCache.sharedInstance.get(VCAppLetor.LINKS.param, namespace: "Links")?.data as! String
                let articleId = (articleIdStr as NSString).integerValue
                
                Alamofire.request(VCheckGo.Router.GetProductDetail(articleId)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
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
                            
                            let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
                            foodViewerViewController.foodInfo = product
                            foodViewerViewController.parentNav = self.navigationController
                            
                            self.navigationController?.showViewController(foodViewerViewController, sender: self)
                            
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                        
                    }
                    else {
                        println("ERROR @ Request for product detail with push: \(error?.localizedDescription)")
                    }
                    
                })
                
                
            }
            if route == VCAppLetor.PNRoute.member.rawValue {
                
                self.userPanel()
            }
            if route == VCAppLetor.PNRoute.message.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.showMailBox()
                    })
                }
                
            }
            if route == VCAppLetor.PNRoute.orderList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        //memberPanel.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    })
                    
                }
                
            }
            if route == VCAppLetor.PNRoute.orderDetail.rawValue {
                
                let orderId = CTMemCache.sharedInstance.get(VCAppLetor.LINKS.param, namespace: "Links")?.data as! String
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
                        
                        let delayInSecond = 0.2
                        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                            
                            // Get OrderList
                            let orderListVC: OrderListViewController = OrderListViewController()
                            orderListVC.parentNav = self.navigationController
                            orderListVC.delegate = memberPanel
                            self.navigationController?.showViewController(orderListVC, sender: self)
                            
                            let delayInSecond = 0.2
                            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                                
                                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                                
                                Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, orderId, token)).validate().responseSwiftyJSON({
                                    (_, _, JSON, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        let json = JSON
                                        
                                        if json["status"]["succeed"].string! == "1" {
                                            
                                            let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!) as OrderInfo
                                            
                                            
                                            order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                                            order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                                            order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                                            order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                                            
                                            var dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                            order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                                            order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                                            
                                            order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                                            order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                            order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                                            
                                            order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                                            order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                                            order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                                            order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                                            
                                            order.voucherId = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_member_id"].string!
                                            order.voucherName = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_name"].string!
                                            
                                            
                                            let orderDetailVC: OrderInfoViewController = OrderInfoViewController()
                                            orderDetailVC.orderInfo = order
                                            orderDetailVC.parentNav = self.navigationController
                                            orderDetailVC.orderListVC = orderListVC
                                            self.navigationController?.showViewController(orderDetailVC, sender: self)
                                        }
                                        else {
                                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                        }
                                        
                                    }
                                    else {
                                        println("ERROR @ Request for order detail with push: \(error?.localizedDescription)")
                                    }
                                })
                            })
                        })
                    }
                    else {
                        
                        memberPanel.presentLoginPanel()
                    }
                }
                
            }
            if route == VCAppLetor.PNRoute.collectionList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                    })
                    
                }
            }
            if route == VCAppLetor.PNRoute.voucherList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                    })
                    
                }
            }
            
            CTMemCache.sharedInstance.cleanNamespace("Links")
            
            
        }
        else {
            //println("no query")
        }
    }
    
    func showIndexCall() {
        
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.INDEX.route, namespace: "indexPage") {
            
            let route = CTMemCache.sharedInstance.get(VCAppLetor.INDEX.route, namespace: "indexPage")?.data as! String
            
            if route == VCAppLetor.PNRoute.web.rawValue {
                let url = CTMemCache.sharedInstance.get(VCAppLetor.INDEX.param, namespace: "indexPage")?.data as! String
                
                let webVC: PBWebViewController = PBWebViewController()
                webVC.URL = NSURL(string: url)
                
                let activity: PBSafariActivity = PBSafariActivity()
                webVC.applicationActivities = [activity]
                
                self.navigationController?.showViewController(webVC, sender: self)
                
            }
            if route == VCAppLetor.PNRoute.home.rawValue {
                
            }
            if route == VCAppLetor.PNRoute.article.rawValue {
                
                let articleIdStr = CTMemCache.sharedInstance.get(VCAppLetor.INDEX.param, namespace: "indexPage")?.data as! String
                let articleId = (articleIdStr as NSString).integerValue
                
                Alamofire.request(VCheckGo.Router.GetProductDetail(articleId)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
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
                            
                            let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
                            foodViewerViewController.foodInfo = product
                            foodViewerViewController.parentNav = self.navigationController
                            
                            self.navigationController?.showViewController(foodViewerViewController, sender: self)
                            
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                        
                    }
                    else {
                        println("ERROR @ Request for product detail with push: \(error?.localizedDescription)")
                    }
                    
                })
                
                
            }
            if route == VCAppLetor.PNRoute.member.rawValue {
                
                self.userPanel()
            }
            if route == VCAppLetor.PNRoute.message.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.showMailBox()
                    })
                }
                
            }
            if route == VCAppLetor.PNRoute.orderList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        //memberPanel.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    })
                    
                }
                
            }
            if route == VCAppLetor.PNRoute.orderDetail.rawValue {
                
                let orderId = CTMemCache.sharedInstance.get(VCAppLetor.INDEX.param, namespace: "indexPage")?.data as! String
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
                        
                        let delayInSecond = 0.2
                        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                            
                            // Get OrderList
                            let orderListVC: OrderListViewController = OrderListViewController()
                            orderListVC.parentNav = self.navigationController
                            orderListVC.delegate = memberPanel
                            self.navigationController?.showViewController(orderListVC, sender: self)
                            
                            let delayInSecond = 0.2
                            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                                
                                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                                
                                Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, orderId, token)).validate().responseSwiftyJSON({
                                    (_, _, JSON, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        let json = JSON
                                        
                                        if json["status"]["succeed"].string! == "1" {
                                            
                                            let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!) as OrderInfo
                                            
                                            
                                            order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                                            order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                                            order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                                            order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                                            
                                            var dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                            order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                                            order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                                            
                                            order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                                            order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                            order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                                            
                                            order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                                            order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                                            order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                                            order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                                            
                                            order.voucherId = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_member_id"].string!
                                            order.voucherName = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_name"].string!
                                            
                                            
                                            let orderDetailVC: OrderInfoViewController = OrderInfoViewController()
                                            orderDetailVC.orderInfo = order
                                            orderDetailVC.parentNav = self.navigationController
                                            orderDetailVC.orderListVC = orderListVC
                                            self.navigationController?.showViewController(orderDetailVC, sender: self)
                                        }
                                        else {
                                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                        }
                                        
                                    }
                                    else {
                                        println("ERROR @ Request for order detail with push: \(error?.localizedDescription)")
                                    }
                                })
                            })
                        })
                    }
                    else {
                        
                        memberPanel.presentLoginPanel()
                    }
                }
                
            }
            if route == VCAppLetor.PNRoute.collectionList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                    })
                    
                }
            }
            if route == VCAppLetor.PNRoute.voucherList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.5
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                    })
                    
                }
            }
            
            CTMemCache.sharedInstance.cleanNamespace("indexPage")
            
            
        }
        else {
            //println("no query")
        }
    }
    
    func cityViewDidTap(gesture: UITapGestureRecognizer) {
        
        self.cityListAnimatedView.hide()
        
        self.cityButton.showsMenu = !self.cityButton.showsMenu
    }
    
    func didCityTap(cityName: UIButton) {
        
        println("cityid: \(cityName.tag)")
        self.cityListAnimatedView.hide()
        
        self.cityButton.showsMenu = !self.cityButton.showsMenu
        
        self.cityCode = cityName.tag
        self.currentPage = 1
        
        self.tableView.triggerPullToRefresh()
        
        
        
    }
    
    
    func isAllowedLocationService() -> Bool {
        
        
        if !CLLocationManager.locationServicesEnabled() {
            
            let alert: UIAlertView = UIAlertView(title: VCAppLetor.StringLine.LocationServiceDisabled, message: VCAppLetor.StringLine.EnableLS, delegate: nil, cancelButtonTitle: VCAppLetor.StringLine.Done)
            alert.show()
            return false
        }
        else {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                
                let alert: UIAlertView = UIAlertView(title: VCAppLetor.StringLine.LocationServiceNotAuth, message: VCAppLetor.StringLine.EnableLSForApp, delegate: nil, cancelButtonTitle: VCAppLetor.StringLine.Done)
                alert.show()
                return false
            }
        }
        
        return true
    }
    
    func isAllowedNotification() -> Bool {
        
        let setting: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if setting.types != UIUserNotificationType.None {
            return true
        }
        
        XGPush.setTag(VCAppLetor.XGPush.pushClose)
        
        return false
    }
    
    
    func pushHandler() {
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.PN.route, namespace: "push") {
            
            let route = CTMemCache.sharedInstance.get(VCAppLetor.PN.route, namespace: "push")?.data as! String
            
            
            if route == VCAppLetor.PNRoute.web.rawValue {
                let url = CTMemCache.sharedInstance.get(VCAppLetor.PN.param, namespace: "push")?.data as! String
                
                
                let webVC: PBWebViewController = PBWebViewController()
                webVC.URL = NSURL(string: url)
                
                let activity: PBSafariActivity = PBSafariActivity()
                webVC.applicationActivities = [activity]
                
                self.navigationController?.showViewController(webVC, sender: self)
                
                
            }
            if route == VCAppLetor.PNRoute.home.rawValue {
                
            }
            if route == VCAppLetor.PNRoute.article.rawValue {
                
                let articleIdStr = CTMemCache.sharedInstance.get(VCAppLetor.PN.param, namespace: "push")?.data as! String
                
                let articleIdArr = articleIdStr.componentsSeparatedByString("=")
                
                let articleId = (articleIdArr[1] as NSString).integerValue
                
                Alamofire.request(VCheckGo.Router.GetProductDetail(articleId)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
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
                            
                            let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
                            foodViewerViewController.foodInfo = product
                            foodViewerViewController.parentNav = self.navigationController
                            
                            self.navigationController?.showViewController(foodViewerViewController, sender: self)
                            
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                        
                    }
                    else {
                        println("ERROR @ Request for product detail with push: \(error?.localizedDescription)")
                    }
                    
                })
                
                
            }
            if route == VCAppLetor.PNRoute.member.rawValue {
                
                self.userPanel()
            }
            if route == VCAppLetor.PNRoute.message.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    
                    
                    let delayInSecond = 0.2
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.showMailBox()
                    })
                }
                
            }
            if route == VCAppLetor.PNRoute.orderList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.2
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        //memberPanel.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    })
                    
                }
                
            }
            if route == VCAppLetor.PNRoute.orderDetail.rawValue {
                
                let orderIdStr = CTMemCache.sharedInstance.get(VCAppLetor.PN.param, namespace: "push")?.data as! String
                
                let orderIdArr = orderIdStr.componentsSeparatedByString("=")
                
                let orderId = orderIdArr[1] as String
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
                        
                        let delayInSecond = 0.2
                        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                            
                            // Get OrderList
                            let orderListVC: OrderListViewController = OrderListViewController()
                            orderListVC.parentNav = self.navigationController
                            orderListVC.delegate = memberPanel
                            self.navigationController?.showViewController(orderListVC, sender: self)
                            
                            let delayInSecond = 0.2
                            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                                
                                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                                
                                Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, orderId, token)).validate().responseSwiftyJSON({
                                    (_, _, JSON, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        let json = JSON
                                        
                                        if json["status"]["succeed"].string! == "1" {
                                            
                                            let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!) as OrderInfo
                                            
                                            
                                            order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                                            order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                                            order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                                            order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                                            
                                            var dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                            order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                                            order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                                            
                                            order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                                            order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                                            order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                            order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                                            
                                            order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                                            order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                                            order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                                            order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                                            
                                            order.voucherId = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_member_id"].string!
                                            order.voucherName = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_name"].string!
                                            
                                            
                                            let orderDetailVC: OrderInfoViewController = OrderInfoViewController()
                                            orderDetailVC.orderInfo = order
                                            orderDetailVC.parentNav = self.navigationController
                                            orderDetailVC.orderListVC = orderListVC
                                            self.navigationController?.showViewController(orderDetailVC, sender: self)
                                        }
                                        else {
                                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                        }
                                        
                                    }
                                    else {
                                        println("ERROR @ Request for order detail with push: \(error?.localizedDescription)")
                                    }
                                })
                            })
                        })
                    }
                    else {
                        
                        memberPanel.presentLoginPanel()
                    }
                }
                
            }
            if route == VCAppLetor.PNRoute.collectionList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.2
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                    })
                    
                }
            }
            if route == VCAppLetor.PNRoute.voucherList.rawValue {
                
                if self.didMemberInit {
                    
                    let memberPanel: UserPanelViewController = UserPanelViewController()
                    memberPanel.parentNav = self.navigationController
                    
                    if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                        
                        memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
                    }
                    self.navigationController?.showViewController(memberPanel, sender: self)
                    
                    let delayInSecond = 0.2
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                    })
                    
                }
            }
            
            CTMemCache.sharedInstance.cleanNamespace("push")
            
        }
        
        
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
        println("Token[Local]: \(tokenString), mid: \(cMid)")
        
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
                                
                                println("LoginWithToken[Done] (LocalTokenChanged): \(token.value)")
                                
                            })
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken as String, data: json["data"]["token"].string!, namespace: "token")
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
                        
                        self.loadMemberInfo(cMid)
                        
                        self.getPayProcess()
                        
                    }
                    else { // Login fail
                        
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                        CTMemCache.sharedInstance.cleanNamespace("member")
                        self.clearLocalToken()
                        
                        
                        self.didMemberInit = true
                        
                        // Push Notification message handler
                        self.pushHandler()
                        self.showOutCall()
                        self.showIndexCall()
                    }
                    
                    self.didMemberInit = true
                    
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    
                }
                else {
                    println("ERROR @ Request for LoginWithToken: \(error?.localizedDescription)")
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                    self.cleanLocalMemberStatus()
                }
                
            })
            
        }
        else {
            
            // Clean up local cache with member status to ensure true
            self.cleanLocalMemberStatus()
        }
    }
    
    func getPayProcess() {
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.payWechatTag, namespace: "pay") {
            
            let succeed = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.payWechatTag, namespace: "pay")?.data as! Bool
            
            CTMemCache.sharedInstance.cleanNamespace("pay")
            
            if succeed {
                
                var oId: String = ""
                
                if let orderId = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.payOrderId, contextType: BreezeContextType.Main) as? Settings {
                    
                    oId = orderId.value
                    orderId.deleteInContextOfType(BreezeContextType.Main)
                }
                
                Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, oId, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string! == "1" {
                            
                            let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!)
                            
                            
                            order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                            order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                            order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                            order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                            order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                            order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                            
                            order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                            order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                            order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                            order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                            
                            order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                            order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                            order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                            order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                            
                            
                            // Show success view
                            let paySuccessVC: VCPaySuccessViewController = VCPaySuccessViewController()
                            paySuccessVC.parentNav = self.navigationController!
                            paySuccessVC.foodDetailVC = self
                            paySuccessVC.orderInfo = order
                            self.navigationController!.showViewController(paySuccessVC, sender: self)
                            
                        }
                        else {
                            let err = json["status"]["error_desc"].string!
                            println("@ SERVER: \(err)")
                        }
                        
                    }
                    else {
                        
                        println("ERROR @ Request for order detail for wechat pay resp : \(error?.localizedDescription)")
                    }
                    
                })
            }
            else {
                
                CTMemCache.sharedInstance.cleanNamespace("pay")
                
                RKDropdownAlert.title(VCAppLetor.StringLine.UnFinishOrder, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        }
        
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.payAlipayTag, namespace: "pay") {
            
            
            let succeed = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.payAlipayTag, namespace: "pay")?.data as! Bool
            
            if succeed {
                
                
                var oId: String = ""
                
                if let orderId = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.payOrderId, contextType: BreezeContextType.Main) as? Settings {
                    
                    oId = orderId.value
                    orderId.deleteInContextOfType(BreezeContextType.Main)
                }
                
                Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, oId, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string! == "1" {
                            
                            let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!)
                            
                            
                            order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                            order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                            order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                            order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                            order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                            order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                            
                            order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                            order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                            order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                            order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                            
                            order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                            order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                            order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                            order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                            
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                let resultString = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.payAlipayResultString, namespace: "pay")?.data as! String
                                
                                CTMemCache.sharedInstance.cleanNamespace("pay")
                                
                                // Async Alipay
                                Alamofire.request(VCheckGo.Router.AsyncPayment(memberId, oId, resultString, token)).validate().responseSwiftyJSON({
                                    (_, _, JSON, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        let json = JSON
                                        
                                        if json["status"]["succeed"].string! == "1" {
                                            
                                            // Show success view
                                            let paySuccessVC: VCPaySuccessViewController = VCPaySuccessViewController()
                                            paySuccessVC.parentNav = self.navigationController!
                                            paySuccessVC.foodDetailVC = self
                                            paySuccessVC.orderInfo = order
                                            self.navigationController!.showViewController(paySuccessVC, sender: self)
                                            
                                        }
                                        else {
                                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                        }
                                    }
                                    else {
                                        println("ERROR @ Request for async payment result : \(error?.localizedDescription)")
                                    }
                                })
                                
                            })
                            
                        }
                        else {
                            let err = json["status"]["error_desc"].string!
                            println("@ SERVER: \(err)")
                        }
                        
                    }
                    else {
                        
                        println("ERROR @ Request for order detail for alipay resp : \(error?.localizedDescription)")
                    }
                    
                })
                
            }
            else {
                
                let payStatus = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.payAlipayResultStatus, namespace: "pay")?.data as! String
                
                CTMemCache.sharedInstance.cleanNamespace("pay")
                
                if payStatus == "6001" {
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.UserCanclePayment, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
                }
                else if payStatus == "6002" {
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.PaymentNetworkError, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                else if payStatus == "4000" {
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.PaymentFailed, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            }
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
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                    
                    
                    memberInfo.email = json["data"]["member_info"]["email"].string!
                    memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                    memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                    memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                    
                    // Listing Info
                    memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                    memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                    memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                    memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                    
                    // Share Info
                    memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                    memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                    memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                    memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                    
                    memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                    memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                    memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                    memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                    
                    memberInfo.bindWechat = json["data"]["thirdpart_info"]["weixin_bind"].string!
                    memberInfo.bindWeibo = json["data"]["thirdpart_info"]["weibo_bind"].string!
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    if let member = Member.findFirst(attribute: "mid", value: memberInfo.memberId, contextType: BreezeContextType.Main) as? Member {
                        
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            member.email = memberInfo.email!
                            member.phone = memberInfo.mobile!
                            member.nickname = memberInfo.nickname!
                            member.iconURL = memberInfo.icon!
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                    }
                    else { // Member login for the first time without register on the device
                        // Get member info and refresh userinterface
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            let member = Member.createInContextOfType(contextType) as! Member
                            
                            member.mid = memberInfo.memberId
                            member.email = memberInfo.email!
                            member.phone = memberInfo.mobile!
                            member.nickname = memberInfo.nickname!
                            member.iconURL = memberInfo.icon!
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                    }
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                    
                    self.didMemberInit = true
                    
                    // Push Notification message handler
                    self.pushHandler()
                    self.showOutCall()
                    self.showIndexCall()
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                println("ERROR @ Request for member info : \(error?.localizedDescription)")
            }
        })
        
    }
    
    func updateSettings(tokenStr: String, currentMid: String) {
        
        // Cache token
        
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = tokenStr
                
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: tokenStr, namespace: "token")
            
            let t = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            println("After Login: token=" + t)
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
                cMid.value = currentMid
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: currentMid, namespace: "member")
        }
        
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.PhoneReg
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.PhoneReg, namespace: "member")
        }
    }
    
    // Clear expired local token
    func clearLocalToken() {
        
        if let localToken = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                localToken.sid = "\(NSDate())"
                localToken.value = "0"
            })
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let localTokenToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                localTokenToBeCreate.sid = "\(NSDate())"
                localTokenToBeCreate.name = VCAppLetor.SettingName.optToken
                localTokenToBeCreate.value = "0"
                localTokenToBeCreate.type = VCAppLetor.SettingType.AppConfig
                localTokenToBeCreate.data = ""
                
            })
            
        }
        
        CTMemCache.sharedInstance.cleanNamespace("token")
    }
    
    // Clean local cache and local data
    func cleanLocalMemberStatus() {
        
        CTMemCache.sharedInstance.cleanNamespace("member")
        CTMemCache.sharedInstance.cleanNamespace("token")
        
        // ========== ISLOGIN ===========
        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                isLogin.sid = "\(NSDate())"
                isLogin.value = "0"
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: false, namespace: "member")
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let isLoginToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                isLoginToBeCreate.sid = "\(NSDate())"
                isLoginToBeCreate.name = VCAppLetor.SettingName.optNameIsLogin
                isLoginToBeCreate.value = "0"
                isLoginToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                isLoginToBeCreate.data = ""
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: false, namespace: "member")
        }
        // ====== LOGINTYPE ========
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.None
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.None, namespace: "member")
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let loginTypeToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                loginTypeToBeCreate.sid = "\(NSDate())"
                loginTypeToBeCreate.name = VCAppLetor.SettingName.optNameLoginType
                loginTypeToBeCreate.value = VCAppLetor.LoginType.None
                loginTypeToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                loginTypeToBeCreate.data = ""
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.None, namespace: "member")
        }
        
        // ======== CURRENT MID ============
        if let currentMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                currentMid.sid = "\(NSDate())"
                currentMid.value = "0"
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: "0", namespace: "member")
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let cMidToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                cMidToBeCreate.sid = "\(NSDate())"
                cMidToBeCreate.name = VCAppLetor.SettingName.optNameCurrentMid
                cMidToBeCreate.value = "0"
                cMidToBeCreate.type = VCAppLetor.SettingType.MemberInfo
                cMidToBeCreate.data = ""
                
            })
            
            //            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: "0", namespace: "member")
        }
        
        self.didMemberInit = true
        
        // Push Notification message handler
        self.pushHandler()
        self.showOutCall()
        self.showIndexCall()
        
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
    
    func insertRowsAtBottom(newRows: NSMutableArray) {
        
        
        self.tableView.beginUpdates()
        
        for food in newRows {
            
            let currentFoodCount: Int = self.foodListItems.count
            self.foodListItems.addObject(food)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: currentFoodCount, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        self.tableView.endUpdates()
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
        
        if reachability.isReachable() {
            
            let bgView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
            bgView.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundView = bgView
        }
        else {
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



