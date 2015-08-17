//
//  VCWebViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/8/13.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RKDropdownAlert
import PBWebViewController


class VCWebViewController: PBWebViewController {
    
    var parentNav: UINavigationController?
    
    // SuperClass implement
    override func load() {
        super.load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        self.showsNavigationToolbar = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // UIWebViewDelegate
    
    override func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //vcheck://?route=web&url=http%;//sasa/
        
        let url: NSURL = request.URL!
        
        if url.scheme! == "vcheck" {
            
            let query = url.query
            
            if query != "" {
                
                if ((url.query!.componentsSeparatedByString("&").count == 3)) {
                    
                    let queryArr: NSArray = url.query!.componentsSeparatedByString("&")
                    let route: String = (queryArr[0].componentsSeparatedByString("="))[1] as! String
                    let param: String = (queryArr[1].componentsSeparatedByString("="))[1] as! String
                    let pushType: String = (queryArr[2].componentsSeparatedByString("="))[1] as! String
                    
                    self.routeVCAction(route, param: param, type: pushType)
                    
                }
                else if ((url.query!.componentsSeparatedByString("&").count == 2)) {
                    
                    let queryArr: NSArray = url.query!.componentsSeparatedByString("&")
                    let route: String = (queryArr[0].componentsSeparatedByString("="))[1] as! String
                    let pushType: String = (queryArr[1].componentsSeparatedByString("="))[1] as! String
                    
                    self.routeVCAction(route, param: "", type: pushType)
                    
                }
                else if ((url.query!.componentsSeparatedByString("&").count == 1)) {
                    
                    // CAN NOT FIND INFORMATION
                    let queryArr: NSArray = url.query!.componentsSeparatedByString("&")
                    let route: String = (queryArr[0].componentsSeparatedByString("="))[1] as! String
                    
                    self.routeVCAction(route, param: "", type: "0")
                }
            }
            
            
        }
        
        return true
        
    }
    
    // MARK: - Functions
    func routeVCAction(route: String, param: String, type: String) {
        
        if route == VCAppLetor.PNRoute.web.rawValue {
            
            self.URL = NSURL(string: param)
            self.load()
            
        }
        if route == VCAppLetor.PNRoute.home.rawValue {
            
            self.parentNav?.popViewControllerAnimated(true)
        }
        if route == VCAppLetor.PNRoute.article.rawValue {
            
            let articleIdStr = param
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
                        foodViewerViewController.parentNav = self.parentNav
                        
                        if type == "1" {
                            
                            self.parentNav?.showViewController(foodViewerViewController, sender: self)
                        }
                        else {
                            self.parentNav?.popViewControllerAnimated(true)
                            self.parentNav?.showViewController(foodViewerViewController, sender: self)
                        }
                        
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
            
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.parentNav
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    self.parentNav?.showViewController(memberPanel, sender: self)
                })
            }
            
        }
        if route == VCAppLetor.PNRoute.message.rawValue {
            
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    memberPanel.showMailBox()
                })
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.parentNav?.showViewController(memberPanel, sender: self)
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        memberPanel.showMailBox()
                    })
                    
                    
                })
            }
            
        }
        if route == VCAppLetor.PNRoute.orderList.rawValue {
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                })
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.parentNav?.showViewController(memberPanel, sender: self)
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    })
                    
                })
            }
            
            
            
        }
        if route == VCAppLetor.PNRoute.orderDetail.rawValue {
            
            let orderId = param
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.2
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.parentNav?.showViewController(memberPanel, sender: self)
                })
            }
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
                
                let delayInSecond = 0.2
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    // Get OrderList
                    let orderListVC: OrderListViewController = OrderListViewController()
                    orderListVC.parentNav = self.navigationController
                    orderListVC.delegate = memberPanel
                    
                    self.parentNav?.showViewController(orderListVC, sender: self)
                    
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
                                    order.voucherPrice = json["data"]["member_order_info"]["order_info"]["voucher_info"]["discount"].string!
                                    
                                    let orderDetailVC: OrderInfoViewController = OrderInfoViewController()
                                    orderDetailVC.orderInfo = order
                                    orderDetailVC.parentNav = self.navigationController
                                    orderDetailVC.orderListVC = orderListVC
                                    self.parentNav?.showViewController(orderDetailVC, sender: self)
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
        if route == VCAppLetor.PNRoute.collectionList.rawValue {
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                })
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.parentNav?.showViewController(memberPanel, sender: self)
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                    })
                })
            }
            
            
        }
        if route == VCAppLetor.PNRoute.voucherList.rawValue {
            
            let memberPanel: UserPanelViewController = UserPanelViewController()
            memberPanel.parentNav = self.navigationController
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberInfo, namespace: "member") {
                
                memberPanel.memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as? MemberInfo
            }
            
            if type == "1" {
                
                self.parentNav?.showViewController(memberPanel, sender: self)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                    
                })
            }
            else {
                
                self.parentNav?.popViewControllerAnimated(true)
                
                let delayInSecond = 0.5
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.parentNav?.showViewController(memberPanel, sender: self)
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        
                        memberPanel.tableView.delegate?.tableView!(memberPanel.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
                        
                    })
                    
                })
            }
            
            
        }
        
    }
    
}
