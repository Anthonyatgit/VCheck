//
//  UserPanelViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/4.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert

class UserPanelViewController: VCBaseViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate, MemberLogoutDelegate, UIScrollViewDelegate {
    
    // MARK: - Make Values
    let kCellIdentifier = "UserPanelCell"
    
    var tableView: UITableView!
    
    var bView: UIView!
    
    // Interface datasource
    let userPanelDataSource: [String: [String]] = VCAppLetor.UserPanel.MyMenus
    let userPanelIcon: [String: [String]] = VCAppLetor.UserPanel.MyIcons
    
    let settings: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 26.0, 26.0))
    
    var parentNav: UINavigationController?
    
    var userInfoHeaderView: UserInfoHeaderView!
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserPanelTitle
        self.view.userInteractionEnabled = true
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        self.settings.setImage(UIImage(named: VCAppLetor.IconName.SettingsBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        self.settings.tintColor = UIColor.whiteColor()
        //        self.settings.addTarget(self, action: "showMailBox", forControlEvents: .TouchUpInside)
        self.settings.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settings)
        
        let tableBG: UIImageView = UIImageView(frame: self.view.frame)
        tableBG.image = UIImage(named: "user_nep.jpg")
        self.view.addSubview(tableBG)
        
        
        // Config tableView Style
        self.tableView = UITableView(frame: CGRectMake(0, 62, self.view.width, self.view.height-62), style: UITableViewStyle.Grouped)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.tableView.registerClass(UserPanelTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        self.userInfoHeaderView = UserInfoHeaderView(frame: CGRectMake(0, 0, self.view.width, self.view.width*0.6))
        self.userInfoHeaderView.userPanelViewController = self
        self.userInfoHeaderView.setupViews()
        self.userInfoHeaderView.mailBoxButton.addTarget(self, action: "showMailBox", forControlEvents: .TouchUpInside)
        self.tableView.tableHeaderView = self.userInfoHeaderView
        
        self.userInfoHeaderView.setNeedsLayout()
        self.userInfoHeaderView.layoutIfNeeded()
        
        let tbBGView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height-62))
        tbBGView.backgroundColor = UIColor.clearColor()
        
        self.bView = UIView(frame: CGRectMake(0, self.view.width*0.6, self.view.width, 800))
        self.bView.backgroundColor = UIColor.whiteColor()
        tbBGView.addSubview(self.bView)
        
        self.tableView.backgroundView = tbBGView
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        // For header view
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "showUserInfo:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        self.tableView.tableHeaderView!.addGestureRecognizer(self.tapGesture)
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - UIScrollViewDelegate
    
    var thisY: CGFloat = 0.0
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.bView.originY = self.view.width*0.6 - scrollView.contentOffset.y
        
    }
    
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userPanelDataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPanelDataSource.values.array[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserPanelTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserPanelCell", forIndexPath: indexPath) as! UserPanelTableViewCell
        
        let current = self.userPanelDataSource.values.array[indexPath.section][indexPath.row]
        cell.panelTitle.text = current
        
        let icon = self.userPanelIcon.values.array[indexPath.section][indexPath.row]
        cell.panelIcon.image = UIImage(named: icon)
        
        //        if indexPath.row > 2 || indexPath.section > 0 {
        //            cell.countLabel.text = ""
        //        }
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return VCAppLetor.ConstValue.UserPanelCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected = userPanelDataSource.values.array[indexPath.section][indexPath.row]
        
        if (indexPath.section == 0 && indexPath.row == 0) { // My Orders
            
            if (isLogined()) {
                
                // Get OrderList
                let orderListVC: OrderListViewController = OrderListViewController()
                orderListVC.parentNav = self.parentNav
                self.parentNav?.showViewController(orderListVC, sender: self)
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // My Favorites
            if (isLogined()) {
                
                // Get Favorites List
                let favoritesVC: FavoritesViewController = FavoritesViewController()
                favoritesVC.parentNav = self.parentNav
                self.parentNav?.showViewController(favoritesVC, sender: self)
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 2) { // Gift Card
            if (isLogined()) {
                
                // Get Gift Card
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 3) { // Feedback
            if (isLogined()) {
                
                // Display Feedback editor
                let feedbackVC: FeedbackViewController = FeedbackViewController()
                feedbackVC.parentNav = self.parentNav
                self.parentNav?.showViewController(feedbackVC, sender: self)
                
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 4) { // About
            // Display App Info
            let aboutVC: VCAboutViewController = VCAboutViewController()
            self.parentNav?.showViewController(aboutVC, sender: self)
        }
        else {
            return
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 0
        }
        else {
            
            return VCAppLetor.ConstValue.UserPanelCellHeaderHeight
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section >= 0 {
            
            let view: UIView = UIView(frame: CGRectZero)
            view.backgroundColor = UIColor.whiteColor()
            
            return view
        }
        else {
            
            let bView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 5.0))
            bView.backgroundColor = UIColor.whiteColor()
            
            let view: CustomDrawView = CustomDrawView(frame: CGRectMake(20.0, 0, self.view.width-40.0, 5.0))
            view.backgroundColor = UIColor.whiteColor()
            view.drawType = "DoubleLine"
            bView.addSubview(view)
            
            return bView
        }
        
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRectZero)
        
        //        if section == 1 {
        //
        //            let v: UITableViewHeaderFooterView = UITableViewHeaderFooterView.newAutoLayoutView()
        //            v.frame = CGRectMake(0, 0, self.view.width, VCAppLetor.ConstValue.UserPanelFooterViewHeight)
        //            v.contentView.backgroundColor = UIColor.whiteColor()
        //
        //            let logoutButton: UIButton = UIButton.newAutoLayoutView()
        //            logoutButton.setTitle(VCAppLetor.StringLine.ServiceTel, forState: .Normal)
        //            logoutButton.titleLabel?.font = VCAppLetor.Font.BigFont
        //            logoutButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        //            logoutButton.backgroundColor = UIColor.turquoiseColor().colorWithAlphaComponent(0.8)
        //            logoutButton.addTarget(self, action: "Logout", forControlEvents: .TouchUpInside)
        //            logoutButton.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        //            v.contentView.addSubview(logoutButton)
        //
        //            logoutButton.autoCenterInSuperview()
        //            logoutButton.autoPinEdgeToSuperviewEdge(.Leading, withInset: 30.0)
        //            logoutButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 30.0)
        //            logoutButton.autoSetDimension(.Height, toSize: 42.0)
        //
        //            v.setNeedsUpdateConstraints()
        //            return v
        //        }
        //        else {
        //            return UIView(frame: CGRectZero)
        //        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    // MARK: - Functions
    
    func showUserInfo(tapGesture: UITapGestureRecognizer) {
        
        if (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String != "0") {
            
            let userInfoViewController: UserInfoViewController = UserInfoViewController()
            userInfoViewController.parentNav = self.parentNav
            userInfoViewController.delegate = self
            self.parentNav?.showViewController(userInfoViewController, sender: self)
        }
        else {
            
            self.presentLoginPanel() // Present user login interface
        }
    }
    
    func showMailBox() {
        
        let mailBoxVC: VCMailBoxViewController = VCMailBoxViewController()
        mailBoxVC.modalPresentationStyle = .Popover
        mailBoxVC.modalTransitionStyle = .CoverVertical
        mailBoxVC.popoverPresentationController?.delegate = self
        presentViewController(mailBoxVC, animated: true, completion: nil)
        
        
    }
    
    func getMemberInfo() {
        
    }
    
    
    // IF the current user is Login to the app
    func isLogined() -> Bool {
        
        return CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String != "0"
    }
    
    func presentLoginPanel() {
        
        let userLoginController: VCMemberLoginViewController = VCMemberLoginViewController()
        userLoginController.modalPresentationStyle = .Popover
        userLoginController.modalTransitionStyle = .CoverVertical
        userLoginController.popoverPresentationController?.delegate = self
        userLoginController.delegate = self
        userLoginController.userPanelController = self
        presentViewController(userLoginController, animated: true, completion: nil)
    }
    
    func updateSettings(tokenStr: String, currentMid: String) {
        
        // Cache token
        
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = tokenStr
                
                println("update token after login \(token.value)")
                
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
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    
    
    
    // MARK: - Member register delegate
    
    func memberDidFinishRegister(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    // Member info
                    let midString = json["data"]["member_info"]["member_id"].string!
                    let emailString = json["data"]["member_info"]["email"].string!
                    let mobileString = json["data"]["member_info"]["mobile"].string!
                    let nicknameString = json["data"]["member_info"]["member_name"].string!
                    let iconString = json["data"]["member_info"]["icon_image"]["thumb"].string!
                    
                    // Listing Info
                    //                    let orderCount = json["data"]["order_info"]["order_total_count"].string!
                    // Collection Info
                    //                    let collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    // Coupon Info
                    //                    let couponCount = json["data"]["coupon_info"]["coupon_total_count"].string!
                    
                    // Get member info and refresh userinterface
                    BreezeStore.saveInMain({ (contextType) -> Void in
                        
                        let member = Member.createInContextOfType(contextType) as! Member
                        
                        member.mid = midString
                        member.email = emailString
                        member.phone = mobileString
                        member.nickname = nicknameString
                        member.iconURL = iconString
                        member.lastLog = NSDate()
                        member.token = token
                        
                    })
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                    
                    self.userInfoHeaderView.panelTitle.text = nicknameString
                    
                    //                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = orderCount
                    //                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = collectionCount
                    //                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = couponCount
                    
                    Alamofire.request(.GET, iconString).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            self.userInfoHeaderView.panelIcon.image = image
                            self.userInfoHeaderView.panelIcon.layer.cornerRadius = self.userInfoHeaderView.panelIcon.width/2.0
                        }
                    }
                    
                    // Push user device token
                    let deviceToken = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optDeviceToken, namespace: "token")?.data as! String
                    pushDeviceToken(deviceToken, VCheckGo.PushDeviceType.add)
                    
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
    
    
    // MARK: - Member Signin Delegate
    
    func memberDidSigninSuccess(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let midString = json["data"]["member_info"]["member_id"].string!
                    let emailString = json["data"]["member_info"]["email"].string!
                    let mobileString = json["data"]["member_info"]["mobile"].string!
                    let nicknameString = json["data"]["member_info"]["member_name"].string!
                    let iconString = json["data"]["member_info"]["icon_image"]["thumb"].string!
                    
                    // Listing Info
                    //let orderCount = json["data"]["order_info"]["order_total_count"].string!
                    // Collection Info
                    //let collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    // Coupon Info
                    //let couponCount = json["data"]["coupon_info"]["coupon_total_count"].string!
                    
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    if let member = Member.findFirst(attribute: "mid", value: midString, contextType: BreezeContextType.Main) as? Member {
                        
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            member.email = emailString
                            member.phone = mobileString
                            member.nickname = nicknameString
                            member.iconURL = iconString
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                    }
                    else { // Member login for the first time without register on the device
                        // Get member info and refresh userinterface
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            let member = Member.createInContextOfType(contextType) as! Member
                            
                            member.mid = midString
                            member.email = emailString
                            member.phone = mobileString
                            member.nickname = nicknameString
                            member.iconURL = iconString
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                        
                        // Push user device token
                        let deviceToken = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optDeviceToken, namespace: "token")?.data as! String
                        pushDeviceToken(deviceToken, VCheckGo.PushDeviceType.add)
                    }
                    
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                    
                    self.userInfoHeaderView.panelTitle.text = nicknameString
                    //(self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = orderCount
                    //(self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = collectionCount
                    //(self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = couponCount
                    
                    Alamofire.request(.GET, iconString).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            self.userInfoHeaderView.panelIcon.image = image
                        }
                    }
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
    
    // MARK: - Member Logout Delegate
    
    func memberDidLogoutSuccess(mid: String) {
        
        
        // Clear Cache & token data
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = "0"
                
            })
            
            CTMemCache.sharedInstance.cleanNamespace("member")
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: "0", namespace: "token")
            
            
            // Refresh user panel interface
            self.userInfoHeaderView.panelIcon.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
            self.userInfoHeaderView.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.userInfoHeaderView.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
            
        } else {
            println("ERROR @ Can not find token in the local data")
        }
        
    }
    
}



