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

class UserPanelViewController: VCBaseViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate, MemberLogoutDelegate, UIScrollViewDelegate, FavoriteDelegate, OrderListDelegate, VoucherDelegate, MemberAuthDelegate {
    
    // MARK: - Make Values
    let kCellIdentifier = "UserPanelCell"
    
    var tableView: UITableView!
    
    var bView: UIView!
    
    var memberInfo: MemberInfo?
    
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
        self.settings.addTarget(self, action: "showSettings", forControlEvents: .TouchUpInside)
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
        
        let headerViewHeight = 30+self.view.width/5.0+140
        
        self.userInfoHeaderView = UserInfoHeaderView(frame: CGRectMake(0, 0, self.view.width, headerViewHeight))
        self.userInfoHeaderView.userPanelViewController = self
        self.userInfoHeaderView.memberInfo = self.memberInfo
        self.userInfoHeaderView.setupViews()
        self.userInfoHeaderView.mailBoxButton.addTarget(self, action: "showMailBox", forControlEvents: .TouchUpInside)
        self.tableView.tableHeaderView = self.userInfoHeaderView
        
        self.userInfoHeaderView.setNeedsLayout()
        self.userInfoHeaderView.layoutIfNeeded()
        
        let tbBGView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height-62))
        tbBGView.backgroundColor = UIColor.clearColor()
        
        self.bView = UIView(frame: CGRectMake(0, headerViewHeight, self.view.width, 800))
        self.bView.backgroundColor = UIColor.whiteColor()
        tbBGView.addSubview(self.bView)
        
        self.tableView.backgroundView = tbBGView
        
        let userpanelFooterView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 120))
        
        let serviceBtn: UIButton = UIButton(frame: CGRectMake(30, 20, self.view.width - 60, 40))
        serviceBtn.setTitle(VCAppLetor.StringLine.ServiceTel, forState: .Normal)
        serviceBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        serviceBtn.titleLabel?.font = VCAppLetor.Font.BigFont
        serviceBtn.backgroundColor = UIColor.turquoiseColor()
        serviceBtn.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        serviceBtn.addTarget(self, action: "freeServiceCall", forControlEvents: .TouchUpInside)
        userpanelFooterView.addSubview(serviceBtn)
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 60, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        userpanelFooterView.addSubview(noMoreView)
        
        self.tableView.tableFooterView = userpanelFooterView
        
        // For header view
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "showUserInfo:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        self.tableView.tableHeaderView!.addGestureRecognizer(self.tapGesture)
        
        self.view.setNeedsUpdateConstraints()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberIcon, namespace: "member") {
            
            self.userInfoHeaderView.panelIcon.image = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberIcon, namespace: "member")?.data as? UIImage
            self.userInfoHeaderView.panelTitle.text = self.memberInfo!.nickname!
        }
        
        self.refreshUserInfo()
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
        
        self.bView.originY = 30+self.view.width/5.0+140 - scrollView.contentOffset.y
        
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
        cell.panelIcon.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        cell.panelIcon.image = UIImage(named: icon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if self.isLogined() {
            
            if indexPath.row == 0  && indexPath.section == 0 {
                cell.countLabel.text = self.memberInfo?.orderCount!
            }
            else if indexPath.row == 1  && indexPath.section == 0 {
                cell.countLabel.text = self.memberInfo?.collectionCount!
            }
            else if indexPath.row == 2  && indexPath.section == 0 {
                cell.countLabel.text = self.memberInfo?.voucherValid!
            }
        }
        
        
        
        
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
                orderListVC.delegate = self
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
                favoritesVC.delegate = self
                self.parentNav?.showViewController(favoritesVC, sender: self)
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 2) { // Gift Card
            if (isLogined()) {
                
                // Get Gift Card
                let voucherVC: VoucherViewController = VoucherViewController()
                voucherVC.parentNav = self.parentNav
                self.parentNav?.showViewController(voucherVC, sender: self)
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
        
        if (CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token")) {
            
            let userInfoViewController: UserInfoViewController = UserInfoViewController()
            userInfoViewController.parentNav = self.parentNav
            userInfoViewController.memberInfo = self.memberInfo!
            userInfoViewController.delegate = self
            self.parentNav?.showViewController(userInfoViewController, sender: self)
        }
        else {
            
            self.presentLoginPanel() // Present user login interface
        }
    }
    
    func loadUserData() {
        
        if self.isLogined() {
            
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            self.memberDidSigninSuccess(mid, token: token)
        }
    }
    
    func showMailBox() {
        
        if self.isLogined() {
            
            let mailBoxVC: VCMailBoxViewController = VCMailBoxViewController()
            mailBoxVC.modalPresentationStyle = .Popover
            mailBoxVC.modalTransitionStyle = .CoverVertical
            mailBoxVC.popoverPresentationController?.delegate = self
            mailBoxVC.userPenalVC = self
            presentViewController(mailBoxVC, animated: true, completion: nil)
        }
        else {
            
            self.presentLoginPanel()
        }
        
        
        
    }
    
    func getMemberInfo() {
        
    }
    
    
    // IF the current user is Login to the app
    func isLogined() -> Bool {
        
        return CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token")
    }
    
    func presentLoginPanel() {
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.LoginType.WeChat, namespace: "Sign") {
            
            let editMemberInfoViewController: EditUserInfoViewController = EditUserInfoViewController()
            editMemberInfoViewController.parentNav = self.parentNav
            editMemberInfoViewController.mobileDelegate = self
            editMemberInfoViewController.memberInfo = nil
            editMemberInfoViewController.editType = VCAppLetor.EditType.Mobile
            
            self.parentNav?.showViewController(editMemberInfoViewController, sender: self)
        }
        else {
            
            let userLoginController: VCMemberLoginViewController = VCMemberLoginViewController()
            userLoginController.modalPresentationStyle = .Popover
            userLoginController.modalTransitionStyle = .CoverVertical
            userLoginController.popoverPresentationController?.delegate = self
            userLoginController.delegate = self
            userLoginController.userPanelController = self
            presentViewController(userLoginController, animated: true, completion: nil)
        }
        
        
    }
    
    func updateSettings(tokenStr: String, currentMid: String) {
        
        // Cache token
        
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = tokenStr
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: tokenStr, namespace: "token")
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
    
    func freeServiceCall() {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://4008369917")!)
    }
    
    func showSettings() {
        
        let settingsVC: VCSettingsViewController = VCSettingsViewController()
        settingsVC.parentNav = self.parentNav
        settingsVC.userPanelVC = self
        self.parentNav?.showViewController(settingsVC, sender: self)
        
    }
    
    func refreshUserInfo() {
        
        if self.isLogined() {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            // Get member info which just finish register
            Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
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
                        self.memberInfo = memberInfo
                        
                        
                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.orderCount!
                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.collectionCount!
                        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.voucherValid!
                        
                        
                        self.userInfoHeaderView.panelTitle.text = memberInfo.nickname!
                        // If local file do not exist, download and save in local directory
                        Alamofire.request(.GET, memberInfo.icon!).validate().responseImage() {
                            (_, _, image, error) in
                            
                            if error == nil && image != nil {
                                self.userInfoHeaderView.panelIcon.image = image
                                
                                //Cache avatar image to path
                                let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                                    (temporaryURL, response) in
                                    
                                    if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                                        
                                        let dURL = directoryURL.URLByAppendingPathComponent("avatar/\(memberInfo.memberId)")
                                        return dURL
                                    }
                                    
                                    return temporaryURL
                                }
                                
                                let docDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
                                let dirToCreate = docDir?.URLByAppendingPathComponent("avatar")
                                
                                var err: NSError?
                                
                                if !NSFileManager.defaultManager().fileExistsAtPath(dirToCreate!.path!) {
                                    NSFileManager.defaultManager().createDirectoryAtURL(dirToCreate!, withIntermediateDirectories: false, attributes: nil, error: &err)
                                }
                                
                                if err == nil {
                                    
                                    Alamofire.download(.GET, memberInfo.icon!, destination).progress {
                                        (_, totalBytesRead, totalBytesExpectedToRead) in
                                        
                                        // Any activity in progress
                                    }
                                }
                                else {
                                    println("\(err?.localizedDescription)")
                                }
                                
                            }
                        }
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                }
                else {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    println("ERROR @ Request for member info : \(error?.localizedDescription)")
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
    
    // MARK: - OrderList Delegate
    func didFinishEditOrder() {
        
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! UserPanelTableViewCell
        
        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
        
        cell.countLabel.text = "\(memberInfo.orderCount)"
    }
    
    // MARK: - Favorite Delegate
    func didFinishEditRow() {
        
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! UserPanelTableViewCell
        
        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
        
        cell.countLabel.text = "\(memberInfo.collectionCount!)"
    }
    
    // MARK: - Voucher Delegate
    func didFinishExchangeVoucher() {
        
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! UserPanelTableViewCell
        
        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
        
        cell.countLabel.text = "\(memberInfo.voucherValid!)"
    }
    
    
    
    // MARK: - Member register delegate
    
    func memberDidFinishRegister(mid: String, token: String) {
        
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
                    
                    
                    // Push user device token
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    self.memberInfo = memberInfo
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                    self.userInfoHeaderView.panelTitle.text = memberInfo.nickname!
                    
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    
                    Alamofire.request(.GET, memberInfo.icon!).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            self.userInfoHeaderView.panelIcon.image = image
                            self.userInfoHeaderView.panelIcon.layer.cornerRadius = self.userInfoHeaderView.panelIcon.width/2.0
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
    
    
    // MARK: - Member Auth delegate
    
    func didMemberFinishAuthMobile(mid: String, token: String) {
        
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
                    
                    
                    // Push user device token
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    self.memberInfo = memberInfo
                    
                    
                    self.userInfoHeaderView.panelTitle.text = memberInfo.nickname!
                    
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = "0"
                    
                    Alamofire.request(.GET, memberInfo.icon!).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            self.userInfoHeaderView.panelIcon.image = image
                            self.userInfoHeaderView.panelIcon.layer.cornerRadius = self.userInfoHeaderView.panelIcon.width/2.0
                            
                            CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: image, namespace: "member")
                        }
                    }
                    
                    CTMemCache.sharedInstance.cleanNamespace("Sign")
                    CTMemCache.sharedInstance.cleanNamespace("LoginStatus")
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
                    println("LoginToken: \(token)")
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
                    
                    // Push user device token
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    self.memberInfo = memberInfo
                    
                    
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.orderCount!
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.collectionCount!
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = memberInfo.voucherValid!
                    
                    
                    self.userInfoHeaderView.panelTitle.text = memberInfo.nickname!
                    // If local file do not exist, download and save in local directory
                    Alamofire.request(.GET, memberInfo.icon!).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            self.userInfoHeaderView.panelIcon.image = image
                            
                            //Cache avatar image to path
                            let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                                (temporaryURL, response) in
                                
                                if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                                    
                                    let dURL = directoryURL.URLByAppendingPathComponent("avatar/\(memberInfo.memberId)")
                                    return dURL
                                }
                                
                                return temporaryURL
                            }
                            
                            let docDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
                            let dirToCreate = docDir?.URLByAppendingPathComponent("avatar")
                            
                            var err: NSError?
                            
                            if !NSFileManager.defaultManager().fileExistsAtPath(dirToCreate!.path!) {
                                NSFileManager.defaultManager().createDirectoryAtURL(dirToCreate!, withIntermediateDirectories: false, attributes: nil, error: &err)
                            }
                            
                            if err == nil {
                                
                                Alamofire.download(.GET, memberInfo.icon!, destination).progress {
                                    (_, totalBytesRead, totalBytesExpectedToRead) in
                                    
                                    // Any activity in progress
                                }
                            }
                            else {
                                println("\(err?.localizedDescription)")
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
    
    func memberDidSigninWithWechatSuccess(mid: String, token: String) {
        
        let avatar = CTMemCache.sharedInstance.get(VCAppLetor.LoginStatus.WechatAvatar, namespace: "LoginStatus")?.data as! String
        let nickname = CTMemCache.sharedInstance.get(VCAppLetor.LoginStatus.WechatNickname, namespace: "LoginStatus")?.data as! String
        
        self.userInfoHeaderView.panelTitle.text = nickname
        // If local file do not exist, download and save in local directory
        Alamofire.request(.GET, avatar).validate().responseImage() {
            (_, _, image, error) in
            
            if error == nil && image != nil {
                
                self.userInfoHeaderView.panelIcon.image = image
                
                let editMemberInfoViewController: EditUserInfoViewController = EditUserInfoViewController()
                editMemberInfoViewController.parentNav = self.parentNav
                editMemberInfoViewController.mobileDelegate = self
                editMemberInfoViewController.memberInfo = nil
                editMemberInfoViewController.editType = VCAppLetor.EditType.Mobile
                
                self.parentNav?.showViewController(editMemberInfoViewController, sender: self)
                
            }
        }
        
    }
    
    // MARK: - Member Logout Delegate
    
    func memberDidLogoutSuccess(mid: String) {
        
        
        // Clear Cache & token data
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = "0"
                
            })
            
            (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = ""
            (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = ""
            (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! UserPanelTableViewCell).countLabel.text = ""
            
            CTMemCache.sharedInstance.cleanNamespace("member")
            CTMemCache.sharedInstance.cleanNamespace("token")
            
            // Refresh user panel interface
            self.userInfoHeaderView.panelIcon.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
            self.userInfoHeaderView.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.userInfoHeaderView.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
            
        } else {
            println("ERROR @ Can not find token in the local data")
        }
        
    }
    
}