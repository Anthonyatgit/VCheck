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

class UserPanelViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate, MemberLogoutDelegate {
    
    // MARK: - Make Values
    let kCellIdentifier = "UserPanelCell"
    
    // Interface datasource
    let userPanelDataSource: [String: [String]] = VCAppLetor.UserPanel.MyMenus
    let userPanelIcon: [String: [String]] = VCAppLetor.UserPanel.MyIcons
    
    var parentNav: UINavigationController?
    
    var userInfoHeaderView: UserInfoHeaderView!
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserPanelTitle
        self.view.userInteractionEnabled = true
        
        // Config tableView Style
        let userPanelTableView: UITableView = UITableView(frame: self.tableView.frame, style: UITableViewStyle.Grouped)
        self.tableView = userPanelTableView
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.registerClass(UserPanelTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        self.userInfoHeaderView = UserInfoHeaderView.newAutoLayoutView()
        self.userInfoHeaderView.userPanelViewController = self
        self.userInfoHeaderView.frame = CGRectMake(0, 0, self.tableView.bounds.width, VCAppLetor.ConstValue.UserInfoHeaderViewHeight)
        self.tableView.tableHeaderView = self.userInfoHeaderView
        
        // For header view
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "showUserInfo:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        self.tableView.tableHeaderView!.addGestureRecognizer(self.tapGesture)
        
        self.tableView.setNeedsUpdateConstraints()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.tableView.tableHeaderView!.autoSetDimensionsToSize(CGSizeMake(self.tableView.bounds.width, VCAppLetor.ConstValue.UserInfoHeaderViewHeight))
        self.tableView.tableHeaderView!.autoPinEdge(.Top, toEdge: .Top, ofView: self.tableView)
        self.tableView.tableHeaderView!.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.tableView)
        
    }
    
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userPanelDataSource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPanelDataSource.values.array[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserPanelTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserPanelCell", forIndexPath: indexPath) as! UserPanelTableViewCell
        
        let current = self.userPanelDataSource.values.array[indexPath.section][indexPath.row]
        cell.panelTitle.text = current
        
        let icon = self.userPanelIcon.values.array[indexPath.section][indexPath.row]
        cell.panelIcon.image = UIImage(named: icon)
        
        if indexPath.row > 2 || indexPath.section > 0 {
            cell.countLabel.text = ""
        }
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VCAppLetor.ConstValue.UserPanelCellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected = userPanelDataSource.values.array[indexPath.section][indexPath.row]
        println("\(selected) selected")
        
        if (indexPath.section == 0 && indexPath.row == 0) { // My Orders
            
            if (isLogined()) {
                
                // Get OrderList
            }
            else {
                
                self.presentLoginPanel() // Present user login interface
            }
            
            
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // My Favorites
            if (isLogined()) {
                
                // Get Favorites List
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
        else if (indexPath.section == 0 && indexPath.row == 3) { // Share
            if (isLogined()) {
                
                // Get Share Code
            }
            else {
                
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 0) { // Feedback
            if (isLogined()) {
                
                // Display Feedback editor
            }
            else {
                
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 1) { // About
            // Display App Info
            
        }
        else {
            return
        }
        
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return VCAppLetor.ConstValue.UserPanelCellHeaderHeight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        view.frame = CGRectMake(0, 0, tableView.bounds.width, VCAppLetor.ConstValue.UserPanelCellHeaderHeight)
        
        return view
    }
    
    
    // MARK: - Functions
    
    func showUserInfo(gesture: UITapGestureRecognizer) {
        
        
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
                cMid.value = currentMid
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update currentMid value @ loginWithToken : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: currentMid, namespace: "member")
                    }
            })
        }
        
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.PhoneReg
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update loginType value @ loginWithToken : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.PhoneReg, namespace: "member")
                    }
            })
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
                            self.userInfoHeaderView.panelIcon.alpha = 1.0
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
//                    let orderCount = json["data"]["order_info"]["order_total_count"].string!
                    // Collection Info
//                    let collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    // Coupon Info
//                    let couponCount = json["data"]["coupon_info"]["coupon_total_count"].string!
                    
                    if let member = Member.findFirst(attribute: "mid", value: midString, contextType: BreezeContextType.Main) as? Member {
                        
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
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
//                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = orderCount
//                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = collectionCount
//                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = couponCount
                        
                        Alamofire.request(.GET, iconString).validate().responseImage() {
                            (_, _, image, error) in
                            
                            if error == nil && image != nil {
                                self.userInfoHeaderView.panelIcon.image = image
                                self.userInfoHeaderView.panelIcon.alpha = 1.0
                            }
                        }
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
                        
                        // update local data
                        self.updateSettings(token, currentMid: mid)
                        
                        // setup cache & user panel interface
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                        
                        self.userInfoHeaderView.panelTitle.text = nicknameString
                        
                        Alamofire.request(.GET, iconString).validate().responseImage() {
                            (_, _, image, error) in
                            
                            if error == nil && image != nil {
                                self.userInfoHeaderView.panelIcon.image = image
                                self.userInfoHeaderView.panelIcon.alpha = 1.0
                            }
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
            
            let t = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            println("After Logout: member_id=\(mid), token=" + t)
            
            // Refresh user panel interface
            self.userInfoHeaderView.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)
            self.userInfoHeaderView.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
            self.userInfoHeaderView.alpha = 0.6
            
        } else {
            println("ERROR @ Can not find token in the local data")
        }
        
        
        
        
    }
    
    
    
    
    
}



