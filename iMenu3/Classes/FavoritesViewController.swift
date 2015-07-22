//
//  FavoritesViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/19.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD

class FavoritesViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate, UIScrollViewDelegate {
    
    var parentNav: UINavigationController?
    
    let imageCache: NSCache = NSCache()
    
    var favoritesList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    var currentPage: Int = 1
    var haveMore: Bool = false
    var isLoadingFav: Bool = false
    
    var hud: MBProgressHUD!
    
    // MARK: - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.FavoritesTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alpha = 0
        
        self.view.addSubview(self.tableView)
        
        // Register Cell View
        self.tableView.registerClass(FavoritesViewCell.self, forCellReuseIdentifier: "favoritesItemCell")
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            self.getFavoritesList()
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        self.getFavoritesList()
        
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
        return self.favoritesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FavoritesViewCell = self.tableView.dequeueReusableCellWithIdentifier("favoritesItemCell", forIndexPath: indexPath) as! FavoritesViewCell
        
        cell.favInfo = self.favoritesList[indexPath.row] as! FoodInfo
        cell.parentNav = self.parentNav
        cell.imageCache = self.imageCache
        cell.setupViews()
        
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: "checkNowAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.setNeedsUpdateConstraints()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VCAppLetor.ConstValue.FavItemCellHeight
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodInfo = self.favoritesList.objectAtIndex(indexPath.row) as! FoodInfo
        foodViewerViewController.parentNav = self.parentNav
        
        self.parentNav!.showViewController(foodViewerViewController, sender: self)
        
    }
    
    // Override to support editing the table view
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if(self.favoritesList.count > 0) {
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                var type = VCheckGo.CollectionEditType.remove
                
                let articleId = "\((self.favoritesList.objectAtIndex(indexPath.row) as! FoodInfo).id)"
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.EditMyCollection(memberId, type, articleId, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string! == "1" {
                            
                            
                            self.tableView.beginUpdates()
                            self.favoritesList.removeObjectAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                            self.tableView.endUpdates()
                            
                            //                            self.tableView.reloadData()
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                        
                    }
                    else {
                        
                        println("ERROR @ Request to edit collection : \(error?.localizedDescription)")
                        RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                    
                })
                
            }
            
        }
        else if editingStyle == .Insert {
            
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.isLoadingFav {
            
            return
        }
        
        if (scrollView.contentOffset.y + self.view.height > scrollView.contentSize.height * 0.8) && self.haveMore {
            
            self.isLoadingFav = true
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            let currentPageNum: Int = ("\(ceil(CGFloat(self.favoritesList.count / VCAppLetor.ConstValue.DefaultListItemCountPerPage)))" as NSString).integerValue
            let nextPageNum: Int = currentPageNum + 1
            
            Alamofire.request(VCheckGo.Router.GetMyCollections(memberId, nextPageNum, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON({
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
                            
                            let favList: Array = json["data"]["article_list"].arrayValue
                            let addedFood: NSMutableArray = NSMutableArray()
                            
                            for item in favList {
                                
                                let fav: FoodInfo = FoodInfo(id: (item["article_id"].string! as NSString).integerValue)
                                
                                fav.title = item["title"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                fav.addDate = dateFormatter.dateFromString(item["article_date"].string!)!
                                
                                // summary missing in the api ...
                                //fav.desc = item["summary"].string!
                                fav.subTitle = item["sub_title"].string!
                                fav.foodImage = item["article_image"]["source"].string!
                                fav.status = item["menu_info"]["menu_status"]["menu_status_id"].string!
                                fav.originalPrice = item["menu_info"]["price"]["original_price"].string!
                                fav.price = item["menu_info"]["price"]["special_price"].string!
                                fav.priceUnit = item["menu_info"]["price"]["price_unit"].string!
                                fav.unit = item["menu_info"]["menu_unit"]["menu_unit"].string!
                                fav.remainingCount = item["menu_info"]["stock"]["menu_count"].string!
                                fav.remainingCountUnit = item["menu_info"]["stock"]["menu_unit"].string!
                                fav.remainder = item["menu_info"]["remainder_time"].string!
                                fav.outOfStock = item["menu_info"]["stock"]["out_of_stock_info"].string!
                                fav.endDate = item["menu_info"]["end_date"].string!
                                fav.returnable = "1"
                                
                                fav.memberIcon = item["member_info"]["icon_image"]["thumb"].string!
                                
                                fav.menuId = item["menu_info"]["menu_id"].string!
                                fav.menuName = item["menu_info"]["menu_name"].string!
                                
                                fav.storeId = item["store_info"]["store_id"].string!
                                fav.storeName = item["store_info"]["store_name"].string!
                                fav.address = item["store_info"]["address"].string!
                                fav.longitude = (item["store_info"]["longitude_num"].string! as NSString).doubleValue
                                fav.latitude = (item["store_info"]["latitude_num"].string! as NSString).doubleValue
                                fav.tel1 = item["store_info"]["tel_1"].string!
                                fav.tel2 = item["store_info"]["tel_2"].string!
                                fav.acp = item["store_info"]["per"].string!
                                fav.icon_thumb = item["store_info"]["icon_image"]["thumb"].string!
                                fav.icon_source = item["store_info"]["icon_image"]["source"].string!
                                
                                addedFood.addObject(fav)
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.insertRowsAtBottom(addedFood)
                                self.isLoadingFav = false
                                
                                if !self.haveMore {
                                    
                                }
                            })
                            
                        }
                        else {
                            self.isLoadingFav = false
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    
                }
                else {
                    println("ERROR @ Loading nore favorites : \(error?.localizedDescription)")
                    self.isLoadingFav = false
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    
    
    // MARK: - Functions
    
    func getFavoritesList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            self.loadFavoritesList()
        }
        else {
            self.showInternetUnreachable()
        }
        
        self.hud.hide(true)
        
    }
    
    func checkNowAction(btn: UIButton) {
        
        let orderCheckViewController: VCCheckNowViewController = VCCheckNowViewController()
        orderCheckViewController.parentNav = self.parentNav
        orderCheckViewController.foodDetailVC = self
        orderCheckViewController.foodInfo = self.favoritesList.objectAtIndex(btn.tag) as! FoodInfo
        self.parentNav?.showViewController(orderCheckViewController, sender: self)
    }
    
    
    
    func loadFavoritesList(indexPath:NSIndexPath? = nil) {
        
        // Copy to ensure the foodlist will never lost
        let favoriteListCopy: NSMutableArray = NSMutableArray(array: self.favoritesList)
        
        // Request for favorite list
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetMyCollections(memberId, self.currentPage, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // Available City?
                        if json["paginated"]["total"].string! == "0" {
                            
                            // Load favorites list, if empty ..
                            let bgView: UIView = UIView()
                            bgView.frame = self.view.bounds
                            
                            let favoriteIcon: UIImageView = UIImageView.newAutoLayoutView()
                            favoriteIcon.alpha = 0.1
                            favoriteIcon.image = UIImage(named: VCAppLetor.IconName.FavoriteBlack)
                            bgView.addSubview(favoriteIcon)
                            
                            let favoriteEmptyLabel: UILabel = UILabel.newAutoLayoutView()
                            favoriteEmptyLabel.text = VCAppLetor.StringLine.FavoritesEmpty
                            favoriteEmptyLabel.font = VCAppLetor.Font.NormalFont
                            favoriteEmptyLabel.textColor = UIColor.lightGrayColor()
                            favoriteEmptyLabel.textAlignment = .Center
                            bgView.addSubview(favoriteEmptyLabel)
                            
                            self.tableView.backgroundView = bgView
                            
                            favoriteIcon.autoAlignAxisToSuperviewAxis(.Vertical)
                            favoriteIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
                            favoriteIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
                            
                            favoriteEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
                            favoriteEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: favoriteIcon, withOffset: 20.0)
                            favoriteEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
                            
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
                        
                        self.favoritesList.removeAllObjects()
                        
                        let favList: Array = json["data"]["article_list"].arrayValue
                        
                        for item in favList {
                            
                            let fav: FoodInfo = FoodInfo(id: (item["article_id"].string! as NSString).integerValue)
                            
                            fav.title = item["title"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            fav.addDate = dateFormatter.dateFromString(item["article_date"].string!)!
                            
                            // summary missing in the api ...
                            //                            fav.desc = item["summary"].string!
                            fav.subTitle = item["sub_title"].string!
                            fav.foodImage = item["article_image"]["source"].string!
                            fav.status = item["menu_info"]["menu_status"]["menu_status_id"].string!
                            fav.originalPrice = item["menu_info"]["price"]["original_price"].string!
                            fav.price = item["menu_info"]["price"]["special_price"].string!
                            fav.priceUnit = item["menu_info"]["price"]["price_unit"].string!
                            fav.unit = item["menu_info"]["menu_unit"]["menu_unit"].string!
                            fav.remainingCount = item["menu_info"]["stock"]["menu_count"].string!
                            fav.remainingCountUnit = item["menu_info"]["stock"]["menu_unit"].string!
                            fav.remainder = item["menu_info"]["remainder_time"].string!
                            fav.outOfStock = item["menu_info"]["stock"]["out_of_stock_info"].string!
                            fav.endDate = item["menu_info"]["end_date"].string!
                            fav.returnable = "1"
                            
                            fav.memberIcon = item["member_info"]["icon_image"]["thumb"].string!
                            
                            fav.menuId = item["menu_info"]["menu_id"].string!
                            fav.menuName = item["menu_info"]["menu_name"].string!
                            
                            fav.storeId = item["store_info"]["store_id"].string!
                            fav.storeName = item["store_info"]["store_name"].string!
                            fav.address = item["store_info"]["address"].string!
                            fav.longitude = (item["store_info"]["longitude_num"].string! as NSString).doubleValue
                            fav.latitude = (item["store_info"]["latitude_num"].string! as NSString).doubleValue
                            fav.tel1 = item["store_info"]["tel_1"].string!
                            fav.tel2 = item["store_info"]["tel_2"].string!
                            fav.acp = item["store_info"]["per"].string!
                            fav.icon_thumb = item["store_info"]["icon_image"]["thumb"].string!
                            fav.icon_source = item["store_info"]["icon_image"]["source"].string!
                            
                            
                            self.favoritesList.addObject(fav)
                            
                        }
                        
                        self.isLoadingFav = false
                        
                        self.hud.hide(true)
                        self.tableView.stopRefreshAnimation()
                        self.tableView.reloadData()
                        self.tableView.animation.makeAlpha(1.0).animate(0.4)
                    })
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    // Restore FoodList
                    self.favoritesList = favoriteListCopy
                }
            }
            else {
                println("ERROR @ Get Favorites List Request: \(error?.localizedDescription)")
                
                // Restore FoodList
                self.favoritesList = favoriteListCopy
                
                // Restore interface
                self.hud.hide(true)
                self.tableView.stopRefreshAnimation()
                
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        })
        
        
    }
    
    func insertRowsAtBottom(newRows: NSMutableArray) {
        
        
        self.tableView.beginUpdates()
        
        for food in newRows {
            
            let currentFoodCount: Int = self.favoritesList.count
            self.favoritesList.addObject(food)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: currentFoodCount, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        self.tableView.endUpdates()
    }
    
    func showInternetUnreachable() {
        
        self.favoritesList.removeAllObjects()
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
    
    
}
