//
//  OrderListViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD
import SWTableViewCell
import DKChainableAnimationKit

protocol OrderListDelegate {
    func didFinishEditOrder()
}

class OrderListViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate, UIScrollViewDelegate{
    
    var parentNav: UINavigationController?
    
    let imageCache: NSCache = NSCache()
    
    var orderList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    var delegate: OrderListDelegate?
    
    var currentPage: Int = 1
    var haveMore: Bool = false
    var isLoadingOrder: Bool = false
    
    var hud: MBProgressHUD!
    
    var shouldReload: Bool = false
    
    // MARK: - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.OrderTitle
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
        self.tableView.registerClass(OrderListViewCell.self, forCellReuseIdentifier: "orderItemCell")
        
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            self.getOrderList()
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        self.getOrderList()
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldReload {
            self.tableView.triggerPullToRefresh()
        }
        
        CTMemCache.sharedInstance.set(VCAppLetor.ObjectIns.objOrderList, data: self, namespace: "object")
        
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
        return self.orderList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:OrderListViewCell = self.tableView.dequeueReusableCellWithIdentifier("orderItemCell", forIndexPath: indexPath) as! OrderListViewCell
        
        cell.orderInfo = self.orderList[indexPath.row] as! OrderInfo
        cell.parentNav = self.parentNav
        cell.imageCache = self.imageCache
        cell.index = indexPath.row
        cell.parentVC = self
        cell.setupViews()
        
        cell.updateCellConstraints()
        
        // Adjust Layout
        if cell.orderInfo.orderType! != "10" {
            
            
            cell.payButton.hidden = true
        }
        else {
            
            if cell.orderInfo.voucherPrice != "" {
                cell.discount.hidden = true
            }
            
            cell.payButton.hidden = false
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if (self.orderList.objectAtIndex(indexPath.row) as! OrderInfo).orderType == "10" ||
        (self.orderList.objectAtIndex(indexPath.row) as! OrderInfo).orderType == "22" ||
        (self.orderList.objectAtIndex(indexPath.row) as! OrderInfo).orderType == "32" ||
        (self.orderList.objectAtIndex(indexPath.row) as! OrderInfo).orderType == "51"
        { // WaitForPay
            
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VCAppLetor.ConstValue.OrderItemCellHeight
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.isLoadingOrder {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let orderDetailVC: OrderInfoViewController = OrderInfoViewController()
        orderDetailVC.orderInfo = self.orderList.objectAtIndex(indexPath.row) as! OrderInfo
        orderDetailVC.parentNav = self.parentNav
        orderDetailVC.orderListVC = self
        self.parentNav?.showViewController(orderDetailVC, sender: self)
        
    }
    
    // Override to support editing the table view
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if(self.orderList.count > 0) {
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                var type = VCheckGo.EditOrderType.delete
                
                let orderId = (self.orderList.objectAtIndex(indexPath.row) as! OrderInfo).id
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.EditOrder(memberId, orderId, type, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string! == "1" {
                            
                            self.tableView.beginUpdates()
                            self.orderList.removeObjectAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                            self.tableView.endUpdates()
                            
//                            let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
//                            let deCount: Int = ("\(memberInfo.orderCount!)" as NSString).integerValue - 1
//                            memberInfo.orderCount = "\(deCount)"
//                            
//                            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
//                            
//                            self.delegate?.didFinishEditOrder()
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                        
                    }
                    else {
                        
                        println("ERROR @ Request to edit order : \(error?.localizedDescription)")
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
        
        if self.isLoadingOrder {
            
            return
        }
        
        if (scrollView.contentOffset.y + self.view.height > scrollView.contentSize.height * 0.8) && self.haveMore {
            
            self.isLoadingOrder = true
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            let currentPageNum: Int = ("\(ceil(CGFloat(self.orderList.count / VCAppLetor.ConstValue.DefaultListItemCountPerPage)))" as NSString).integerValue
            let nextPageNum: Int = currentPageNum + 1
            
            Alamofire.request(VCheckGo.Router.GetOrderList(memberId, nextPageNum, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON({
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
                            
                            let orderList: Array = json["data"]["member_order_list"].arrayValue
                            let addedOrder: NSMutableArray = NSMutableArray()
                            
                            for item in orderList {
                                
                                let order: OrderInfo = OrderInfo(id: item["order_info"]["order_id"].string!, no: item["order_info"]["order_no"].string!)
                                
                                
                                order.title = item["order_info"]["menu_info"]["menu_name"].string!
                                order.pricePU = item["order_info"]["menu_info"]["price"]["special_price"].string!
                                order.priceUnit = item["order_info"]["menu_info"]["price"]["price_unit"].string!
                                order.totalPrice = item["order_info"]["total_price"]["special_price"].string!
                                order.originalTotalPrice = item["order_info"]["total_price"]["original_price"].string!
                                
                                order.createByMobile = item["order_info"]["mobile"].string!
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                order.createDate = dateFormatter.dateFromString(item["order_info"]["create_date"].string!)
                                
                                order.menuId = item["order_info"]["menu_info"]["menu_id"].string!
                                order.menuTitle = item["order_info"]["menu_info"]["menu_name"].string!
                                order.menuUnit = item["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                order.itemCount = item["order_info"]["menu_info"]["count"].string!
                                
                                order.orderType = item["order_info"]["order_type"].string!
                                order.typeDescription = item["order_info"]["order_type_description"].string!
                                order.orderImageURL = item["article_info"]["article_image"]["source"].string!
                                order.foodId = item["article_info"]["article_id"].string!
                                
                                
                                order.voucherId = item["order_info"]["voucher_info"]["voucher_member_id"].string!
                                order.voucherName = item["order_info"]["voucher_info"]["voucher_name"].string!
                                order.voucherPrice = item["order_info"]["voucher_info"]["discount"].string!
                                
                                order.isReturn = item["order_info"]["is_return"].string!
                                
                                if order.orderType! != "10" && order.orderType! != "51" && order.orderType! != "71" {
                                    
                                    order.exCode = item["order_info"]["consume_info"]["consume_code"].string!
                                    
                                    var dateFM = NSDateFormatter()
                                    dateFM.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                    order.exCodeExpireDate = dateFM.dateFromString(item["order_info"]["consume_info"]["exprie_date"].string!)
                                    
                                    order.exCodeUseDate = item["order_info"]["consume_info"]["consume_date"].string!
                                }
                                
                                
                                addedOrder.addObject(order)
                                
                            }
                            
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.insertRowsAtBottom(addedOrder)
                                self.isLoadingOrder = false
                                
                            })
                            
                            
                        }
                        else {
                            self.isLoadingOrder = false
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                }
                else {
                    println("ERROR @ Loading nore favorites : \(error?.localizedDescription)")
                    self.isLoadingOrder = false
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    
    
    // MARK: - Functions
    
    func getOrderList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            self.loadOrderList()
        }
        else {
            self.showInternetUnreachable()
        }
        
        self.hud.hide(true)
        
    }
    
    
    
    func loadOrderList(indexPath:NSIndexPath? = nil) {
        
        // Copy to ensure the foodlist will never lost
        let orderListCopy: NSMutableArray = NSMutableArray(array: self.orderList)
        
        // Request for favorite list
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetOrderList(memberId, self.currentPage, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON ({
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
                            
                            let orderIcon: UIImageView = UIImageView.newAutoLayoutView()
                            orderIcon.alpha = 0.1
                            orderIcon.image = UIImage(named: VCAppLetor.IconName.OrderBlack)
                            bgView.addSubview(orderIcon)
                            
                            let orderEmptyLabel: UILabel = UILabel.newAutoLayoutView()
                            orderEmptyLabel.text = VCAppLetor.StringLine.OrderEmpty
                            orderEmptyLabel.font = VCAppLetor.Font.NormalFont
                            orderEmptyLabel.textColor = UIColor.lightGrayColor()
                            orderEmptyLabel.textAlignment = .Center
                            bgView.addSubview(orderEmptyLabel)
                            
                            self.tableView.backgroundView = bgView
                            
                            orderIcon.autoAlignAxisToSuperviewAxis(.Vertical)
                            orderIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
                            orderIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
                            
                            orderEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
                            orderEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: orderIcon, withOffset: 20.0)
                            orderEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
                            
                            self.tableView.stopRefreshAnimation()
                            
                            self.tableView.animation.makeAlpha(1.0).animate(0.4)
                            
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
                        self.orderList.removeAllObjects()
                        
                        let orderList: Array = json["data"]["member_order_list"].arrayValue
                        
                        for item in orderList {
                            
                            let order: OrderInfo = OrderInfo(id: item["order_info"]["order_id"].string!, no: item["order_info"]["order_no"].string!)
                            
                            
                            order.title = item["order_info"]["menu_info"]["menu_name"].string!
                            order.pricePU = item["order_info"]["menu_info"]["price"]["special_price"].string!
                            order.priceUnit = item["order_info"]["menu_info"]["price"]["price_unit"].string!
                            order.totalPrice = item["order_info"]["total_price"]["special_price"].string!
                            order.originalTotalPrice = item["order_info"]["total_price"]["original_price"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            order.createDate = dateFormatter.dateFromString(item["order_info"]["create_date"].string!)
                            order.createByMobile = item["order_info"]["mobile"].string!
                            
                            order.menuId = item["order_info"]["menu_info"]["menu_id"].string!
                            order.menuTitle = item["order_info"]["menu_info"]["menu_name"].string!
                            order.menuUnit = item["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                            order.itemCount = item["order_info"]["menu_info"]["count"].string!
                            
                            order.orderType = item["order_info"]["order_type"].string!
                            order.typeDescription = item["order_info"]["order_type_description"].string!
                            order.orderImageURL = item["article_info"]["article_image"]["source"].string!
                            order.foodId = item["article_info"]["article_id"].string!
                            
                            order.voucherId = item["order_info"]["voucher_info"]["voucher_member_id"].string!
                            order.voucherName = item["order_info"]["voucher_info"]["voucher_name"].string!
                            order.voucherPrice = item["order_info"]["voucher_info"]["discount"].string!
                            
                            order.isReturn = item["order_info"]["is_return"].string!
                            
                            if order.orderType! != "10" && order.orderType! != "51" && order.orderType! != "71" {
                                
                                order.exCode = item["order_info"]["consume_info"]["consume_code"].string!
                                
                                var dateFM = NSDateFormatter()
                                dateFM.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                order.exCodeExpireDate = dateFM.dateFromString(item["order_info"]["consume_info"]["exprie_date"].string!)
                                
                                order.exCodeUseDate = item["order_info"]["consume_info"]["consume_date"].string!
                            }
                            
                            
                            self.orderList.addObject(order)
                            
                        }
                        
                        self.isLoadingOrder = false
                        
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
                    self.orderList = orderListCopy
                }
            }
            else {
                println("ERROR @ Get Order List Request: \(error?.localizedDescription)")
                
                // Restore FoodList
                self.orderList = orderListCopy
                
                // Restore interface
                self.hud.hide(true)
                self.tableView.stopRefreshAnimation()
                
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        })
        
        
    }
    
    func insertRowsAtBottom(newRows: NSMutableArray) {
        
        
        for order in newRows {
            
            self.tableView.beginUpdates()
            let currentOrderCount: Int = self.orderList.count
            self.orderList.addObject(order)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: currentOrderCount, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
        }
    }
    
    func showInternetUnreachable() {
        
        self.orderList.removeAllObjects()
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
