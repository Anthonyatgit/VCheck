//
//  VCMailBoxViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/16.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD
import KINWebBrowser

class VCMailBoxViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate {
    
    var userPenalVC: UserPanelViewController?
    
    var mailsList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    var hud: MBProgressHUD!
    
    let closeButton: UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
    
    var currentPage: Int = 1
    var haveMore: Bool = false
    
    var isLoadingMsg: Bool = false
    
    // MARK - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.MailboxTitle
        
        let closeView: UIView = UIView(frame: CGRectMake(6.0, 0.0, 32.0, 32.0))
        closeView.backgroundColor = UIColor.clearColor()
        
        self.closeButton.setImage(UIImage(named: VCAppLetor.IconName.ClearIconBlack)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.closeButton.backgroundColor = UIColor.clearColor()
        self.closeButton.addTarget(self, action: "willCloseMailBox", forControlEvents: .TouchUpInside)
        closeView.addSubview(self.closeButton)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeView)
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        //        self.tableView.frame = self.view.bounds
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        
        // Register Cell View
        self.tableView.registerClass(MailBoxCell.self, forCellReuseIdentifier: "mailItemCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        self.getMailList()
        
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
        return self.mailsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MailBoxCell = self.tableView.dequeueReusableCellWithIdentifier("mailItemCell", forIndexPath: indexPath) as! MailBoxCell
        
        cell.msgInfo = self.mailsList.objectAtIndex(indexPath.row) as! MessageInfo
        cell.setupViews()
        
        return cell
        
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.mailsList.objectAtIndex(indexPath.row) as! MessageInfo).route != "" {
            
            self.showIndexCall(indexPath)
        }
        
    }
    
    // Override to support editing the table view
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if(self.mailsList.count > 0) {
                
                
                let foodItem:FoodItem = self.mailsList.objectAtIndex(indexPath.row) as! FoodItem
                
                if let foodToDelete = FoodItem.findFirst(attribute: "identifier", value: foodItem.identifier, contextType: BreezeContextType.Main) as? FoodItem {
                    foodToDelete.deleteInContextOfType(BreezeContextType.Background)
                }
                
//                BreezeStore.saveInBackground({ contextType -> Void in
//                    
//                }, completion: { (error) -> Void in
//                    self.mailsList(indexPath: indexPath)
//                })
                
                
            }
            
        }
        else if editingStyle == .Insert {
            
        }
    }
    
    // MARK: - Functions
    
    func willCloseMailBox() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getMailList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            
            self.showMailList()
//            self.setupRefresh()
        }
        else {
            self.showInternetUnreachable()
        }
        
        self.hud.hide(true)
        
    }
    
    func setupRefresh() {
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
    }
    
    func showMailList() {
        
        
        // Copy to ensure the foodlist will never lost
        let mailListCopy: NSMutableArray = NSMutableArray(array: self.mailsList)
        
        // Request for favorite list
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetMyMessages(memberId, self.currentPage, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // Available Messages?
                        if json["paginated"]["total"].string! == "0" {
                            
                            // Load favorites list, if empty ..
                            let bgView: UIView = UIView()
                            bgView.frame = self.view.frame
                            
                            let favoriteIcon: UIImageView = UIImageView.newAutoLayoutView()
                            favoriteIcon.alpha = 0.1
                            favoriteIcon.image = UIImage(named: VCAppLetor.IconName.MailBlack)
                            bgView.addSubview(favoriteIcon)
                            
                            let favoriteEmptyLabel: UILabel = UILabel.newAutoLayoutView()
                            favoriteEmptyLabel.text = VCAppLetor.StringLine.MailboxEmpty
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
                        
                        self.mailsList.removeAllObjects()
                        
                        let msgList: Array = json["data"]["message_list"].arrayValue
                        
                        for item in msgList {
                            
                            let msg: MessageInfo = MessageInfo(msgId: item["message_id"].string!)
                            
                            msg.content = item["title"].string!
                            
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                            msg.addDate = dateFormatter.dateFromString(item["message_date"].string!)!
                            
                            msg.type = item["message_type_id"].string!
                            msg.route = item["link_info"]["link_route"].string!
                            msg.param = item["link_info"]["link_value"].string!
                            msg.is_open = item["is_open"].string!
                            
                            self.mailsList.addObject(msg)
                            
                        }
                        
                        self.isLoadingMsg = false
                        
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
                    self.mailsList = mailListCopy
                }
            }
            else {
                println("ERROR @ Get Message List Request: \(error?.localizedDescription)")
                
                // Restore FoodList
                self.mailsList = mailListCopy
                
                // Restore interface
                self.hud.hide(true)
                self.tableView.stopRefreshAnimation()
                
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        })
        
    }
    
    func showIndexCall(indexPath: NSIndexPath) {
        
        
        let route = (self.mailsList.objectAtIndex(indexPath.row) as! MessageInfo).route!
        let param = (self.mailsList.objectAtIndex(indexPath.row) as! MessageInfo).param!
        
        if route == VCAppLetor.PNRoute.web.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                let webPage: KINWebBrowserViewController = KINWebBrowserViewController.webBrowser()
                self.userPenalVC?.showViewController(webPage, sender: self)
                webPage.loadURLString(param)
                webPage.tintColor = UIColor.whiteColor()
                webPage.actionButtonHidden = true
            })
            
        }
        if route == VCAppLetor.PNRoute.home.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        if route == VCAppLetor.PNRoute.article.rawValue {
            
            let aidStr = param.componentsSeparatedByString("=")[1] as String
            let articleId = (aidStr as NSString).integerValue
            
            Alamofire.request(VCheckGo.Router.GetProductDetail(articleId)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            
                            self.userPenalVC?.parentNav?.popViewControllerAnimated(true)
                            
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
                            
                            let homeVC = CTMemCache.sharedInstance.get(VCAppLetor.ObjectIns.objHome, namespace: "object")?.data as! FoodListController
                            homeVC.navigationController?.showViewController(foodViewerViewController, sender: self)
                            
                        })
                        
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
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        if route == VCAppLetor.PNRoute.message.rawValue {
            
            
        }
        if route == VCAppLetor.PNRoute.orderList.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                self.userPenalVC!.tableView.delegate?.tableView!(self.userPenalVC!.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                
            })
            
        }
        if route == VCAppLetor.PNRoute.orderDetail.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                
                self.userPenalVC!.tableView.delegate?.tableView!(self.userPenalVC!.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                
                
                let delayInSecond = 0.2
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                    let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                    
                    let orderId = param.componentsSeparatedByString("=")[1] as String
                    
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
                                
                                let orderIns = CTMemCache.sharedInstance.get(VCAppLetor.ObjectIns.objOrderList, namespace: "object")?.data as! OrderListViewController
                                orderDetailVC.orderListVC = orderIns
                                orderIns.parentNav?.showViewController(orderDetailVC, sender: self)
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
        if route == VCAppLetor.PNRoute.collectionList.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                self.userPenalVC!.tableView.delegate?.tableView!(self.userPenalVC!.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                
            })
        }
        if route == VCAppLetor.PNRoute.voucherList.rawValue {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                self.userPenalVC!.tableView.delegate?.tableView!(self.userPenalVC!.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                
            })
        }
    }
    
    func showInternetUnreachable() {
        
        self.mailsList.removeAllObjects()
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



