//
//  UserInfoViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/15.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert

protocol MemberLogoutDelegate {
    func memberDidLogoutSuccess(mid: String)
}

class UserInfoSectionHeaderView: UITableViewHeaderFooterView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    func setupViews() {
        
//        self.contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        
    }
}

class UserInfoViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, EditUserInfoDelegate {
    
    // Interface datasource
    var userInfoDataSource: [String: [String]]!
    
    var delegate: MemberLogoutDelegate?
    var parentNav: UINavigationController?
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserInfoSettings
        
        self.userInfoDataSource = VCAppLetor.UserPanel.MyInfos
        
        // Config tableView Style
        let userInfoTableView: UITableView = UITableView(frame: self.tableView.bounds, style: UITableViewStyle.Grouped)
        self.tableView = userInfoTableView
        
        self.tableView.registerClass(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCell")
        self.tableView.registerClass(UserInfoSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "userInfoHeaderView")
        
        
        self.tableView.updateConstraintsIfNeeded()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userInfoDataSource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userInfoDataSource.values.array[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserInfoCell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell", forIndexPath: indexPath) as! UserInfoCell
        cell.backgroundColor = UIColor.whiteColor()
        
        
        if (indexPath.section == 0 && indexPath.row == 0) { // Email
            cell.title.text = VCAppLetor.UserPanel.Email
            cell.subTitle.text = CTMemCache.sharedInstance.get("email", namespace: "member")?.data as? String ?? VCAppLetor.StringLine.NotSetYet
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // Nickname
            cell.title.text = VCAppLetor.UserPanel.Nickname
            cell.subTitle.text = CTMemCache.sharedInstance.get("nickname", namespace: "member")?.data as? String ?? VCAppLetor.StringLine.NotSetYet
        }
        else if (indexPath.section == 1 && indexPath.row == 0) { // Phone Number
            cell.title.text = VCAppLetor.UserPanel.PhoneNumber
            //            var phoneNumber = CTMemCache.sharedInstance.get("phoneNumber", namespace: "member")?.data as! String
            var phoneNumber: String = "15229354910"
            var range = Range<String.Index>(start: advance(phoneNumber.startIndex, 3),end: advance(phoneNumber.endIndex, -4))
            phoneNumber.replaceRange(range, with: "••••")
            
            cell.subTitle.text = phoneNumber
            
        }
        else if (indexPath.section == 1 && indexPath.row == 1) { // Passcode
            cell.title.text = VCAppLetor.UserPanel.Passcode
            cell.subTitle.text = VCAppLetor.StringLine.PassCodeString
        }
        else if (indexPath.section == 2 && indexPath.row == 0) { // Weibo
            cell.title.text = VCAppLetor.UserPanel.SinaWeibo
            cell.subTitle.text = CTMemCache.sharedInstance.get("nickname_weibo", namespace: "member")?.data as? String ?? VCAppLetor.StringLine.NotAuthYet
        }
        else if (indexPath.section == 2 && indexPath.row == 1) { // WeChat
            cell.title.text = VCAppLetor.UserPanel.WeChat
            cell.subTitle.text = CTMemCache.sharedInstance.get("nickname_wechat", namespace: "member")?.data as? String ?? VCAppLetor.StringLine.NotAuthYet
        }
        
        cell.setNeedsUpdateConstraints()
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VCAppLetor.ConstValue.UserPanelCellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected = self.userInfoDataSource.values.array[indexPath.section][indexPath.row]
        
        let editMemberInfoViewController: EditUserInfoViewController = EditUserInfoViewController()
        editMemberInfoViewController.parentNav = self.parentNav
        editMemberInfoViewController.delegate = self
        
        if (indexPath.section == 0 && indexPath.row == 0) { // Email
            
            editMemberInfoViewController.editType = VCAppLetor.EditType.Email
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // Nickname
            editMemberInfoViewController.editType = VCAppLetor.EditType.Nickname
        }
        else if (indexPath.section == 1 && indexPath.row == 0) { // Phone number
            editMemberInfoViewController.editType = VCAppLetor.EditType.Password
        }
        else if (indexPath.section == 1 && indexPath.row == 1) { // Passcode
            
            RKDropdownAlert.title(VCAppLetor.StringLine.MobileCannotChange, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            return
        }
        else if (indexPath.section == 2 && indexPath.row == 0) { // Weibo
            // Logout with ShareSDK if neccesory
            if !ShareSDK.hasAuthorizedWithType(ShareTypeSinaWeibo) {
                
            }
            return
        }
        else if (indexPath.section == 2 && indexPath.row == 1) { // WeChat
            if ShareSDK.hasAuthorizedWithType(ShareTypeWeixiTimeline) {
                
            }
            return
        }
        else {
            return
        }
        
        self.parentNav?.showViewController(editMemberInfoViewController, sender: self)
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return VCAppLetor.ConstValue.UserInfoSectionHeaderHight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let userInfoHeaderView: UserInfoSectionHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("userInfoHeaderView") as! UserInfoSectionHeaderView
        userInfoHeaderView.frame = CGRectMake(0, 0, self.tableView.bounds.width, 40)
        
        switch section {
        case 0: userInfoHeaderView.textLabel.text = VCAppLetor.UserPanel.PersonalInfo
        case 1: userInfoHeaderView.textLabel.text = VCAppLetor.UserPanel.AccountSecurity
        case 2: userInfoHeaderView.textLabel.text = VCAppLetor.UserPanel.SocialAuth
        default: userInfoHeaderView.textLabel.text = ""
        }
        
        return userInfoHeaderView
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 2 {
            let v: UITableViewHeaderFooterView = UITableViewHeaderFooterView.newAutoLayoutView()
            v.frame = CGRectMake(0, 0, self.tableView.bounds.width, VCAppLetor.ConstValue.UserInfoFooterViewHeight)
            
            let logoutButton: UIButton = UIButton.newAutoLayoutView()
            logoutButton.setTitle(VCAppLetor.StringLine.Logout, forState: .Normal)
            logoutButton.titleLabel?.font = VCAppLetor.Font.BigFont
            logoutButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            logoutButton.backgroundColor = UIColor.pomegranateColor()
            logoutButton.addTarget(self, action: "Logout", forControlEvents: .TouchUpInside)
            logoutButton.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
            v.contentView.addSubview(logoutButton)
            
            logoutButton.autoCenterInSuperview()
            logoutButton.autoPinEdgeToSuperviewEdge(.Leading, withInset: 30.0)
            logoutButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 30.0)
            logoutButton.autoSetDimension(.Height, toSize: 42.0)
            
            v.setNeedsUpdateConstraints()
            return v
        }
        else {
            return UIView(frame: CGRectZero)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            return 80.0
        }
        else {
            return 1.0
        }
    }
    
    
    // MARK: - EditMemberInfoDelegate
    
    func didFinishEditingMemberInfo(email: String, nickname: String) {
        
        if email != "" {
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! UserInfoCell
            cell.subTitle.text = email
            
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            if let member = Member.findFirst(attribute: "mid", value: mid, contextType: BreezeContextType.Main) as? Member {
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    member.email = email
                })
                
                CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: email, namespace: "member")
            }
            else { //Create member record if DO NOT EXIST
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    
                    member.mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                    member.email = email
                    member.phone = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
                    member.nickname = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Nickname, namespace: "member")?.data as! String
                    member.iconURL = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Icon, namespace: "member")?.data as! String
                    member.lastLog = NSDate()
                    member.token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                    
                    }, completion: { error -> Void in
                        
                        if (error != nil) {
                            println("ERROR @ Create member ON DO NOT EXIST when finish edit memberinfo : \(error?.localizedDescription)")
                        }
                        else {
                            // DO something when save done
                        }
                })
            }
        }
        else if nickname != "" {
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! UserInfoCell
            cell.subTitle.text = nickname
            
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            if let member = Member.findFirst(attribute: "mid", value: mid, contextType: BreezeContextType.Main) as? Member {
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    member.nickname = nickname
                })
                
                CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nickname, namespace: "member")
            }
            else { //Create member record if DO NOT EXIST
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    
                    member.mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                    member.email = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Email, namespace: "member")?.data as! String
                    member.phone = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
                    member.nickname = nickname
                    member.iconURL = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Icon, namespace: "member")?.data as! String
                    member.lastLog = NSDate()
                    member.token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                    
                    }, completion: { error -> Void in
                        
                        if (error != nil) {
                            println("ERROR @ Create member ON DO NOT EXIST when finish edit memberinfo : \(error?.localizedDescription)")
                        }
                        else {
                            // DO something when save done
                        }
                })
            }
        }
    }
    
    
    // MARK: - Functions
    
    func Logout() {
        
        if reachability.isReachable() {
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            if memberId != "0" && token != "0" {
                
                println("Before Logout: member_id=\(memberId), token=\(token)")
                
                Alamofire.request(VCheckGo.Router.MemberLogout(token, memberId)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string == "1" {
                            
                            // Logout with ShareSDK if neccesory
                            if ShareSDK.hasAuthorizedWithType(ShareTypeSinaWeibo) {
                                ShareSDK.cancelAuthWithType(ShareTypeSinaWeibo)
                                
                            }
                            else if ShareSDK.hasAuthorizedWithType(ShareTypeWeixiTimeline) {
                                ShareSDK.cancelAuthWithType(ShareTypeWeixiTimeline)
                            }
                            
                            // Call delegate
                            self.delegate?.memberDidLogoutSuccess(memberId)
                            self.parentNav?.popViewControllerAnimated(true)
                            
                            
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ request for member logout : \(error?.localizedDescription)")
                    }
                })
            }
            else {
                println("ERROR @ Unexpected empty value with member_id OR token!")
            }
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
    }
    
    
    func addTableFooter() {
        
        let userInfoFooterView: CustomDrawView = CustomDrawView.newAutoLayoutView()
        userInfoFooterView.drawType = "LogoutButton"
        userInfoFooterView.withTitle = VCAppLetor.StringLine.Logout
        userInfoFooterView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        userInfoFooterView.frame = CGRectMake(0, 0, self.view.bounds.width, VCAppLetor.ConstValue.UserInfoFooterViewHeight)
        
        let v: UITableViewHeaderFooterView = UITableViewHeaderFooterView.newAutoLayoutView()
        v.frame = CGRectMake(0, 0, self.view.bounds.width, VCAppLetor.ConstValue.UserInfoFooterViewHeight)
        v.contentView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        self.tableView.tableFooterView = v
        
    }
    
}