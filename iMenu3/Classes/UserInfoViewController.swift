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
import MBProgressHUD

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
        
        //self.contentView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        
    }
}

class UserInfoViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, EditUserInfoDelegate, UzysAssetsPickerControllerDelegate, UIAlertViewDelegate {
    
    // Interface datasource
    var userInfoDataSource: NSMutableArray = NSMutableArray()
    
    var memberInfo: MemberInfo?
    
    var delegate: MemberLogoutDelegate?
    var parentNav: UINavigationController?
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    let picker: UzysAssetsPickerController = UzysAssetsPickerController()
    
    var hud: MBProgressHUD!
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserInfoSettings
        
        var mInfo: NSMutableArray = ["头像", "邮箱", "昵称"]
        var securityInfo: NSMutableArray = ["手机号", "密码"]
        var authInfo: NSMutableArray = ["新浪微博", "微信"]
        
        self.userInfoDataSource.addObject(mInfo)
        self.userInfoDataSource.addObject(securityInfo)
        self.userInfoDataSource.addObject(authInfo)
        
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
        //return self.userInfoDataSource.values.array[section].count
        return self.userInfoDataSource[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserInfoCell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell", forIndexPath: indexPath) as! UserInfoCell
        cell.backgroundColor = UIColor.whiteColor()
        
        if (indexPath.section == 0 && indexPath.row == 0) { // Avatar
            cell.title.text = VCAppLetor.UserPanel.Avatar
            cell.subTitle.hidden = true
            cell.avatar.hidden = false
            
            if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberIcon, namespace: "member") {
                
                cell.avatar.image = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberIcon, namespace: "member")?.data as? UIImage
            }
            else {
                
                let midString = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                
                // Read avatar icon from local cache file
                if var avatarDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                    
                    var err: NSError?
                    
                    avatarDirectoryURL = avatarDirectoryURL.URLByAppendingPathComponent("/avatar/\(midString)")
                    
                    let avatarIconFile = NSFileManager.defaultManager().contentsAtPath(avatarDirectoryURL.path!)
                    
                    if avatarIconFile != nil {
                        
                        let avatarIconImage = UIImage(data: avatarIconFile!)
                        
                        let avatarIcon = Toucan.Resize.resizeImage(avatarIconImage!, size: CGSizeMake(40.0, 40.0), fitMode: Toucan.Resize.FitMode.Crop)
                        
                        cell.avatar.image = avatarIcon
                    }
                    else {
                        
                        let icon = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Icon, namespace: "member")?.data as! String
                        Alamofire.request(.GET, icon).validate().responseImage() {
                            (_, _, image, error) in
                            
                            if error == nil && image != nil {
                                
                                cell.avatar.image = image
                            }
                        }
                    }
                }
            }
            
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // Email
            cell.title.text = VCAppLetor.UserPanel.Email
            cell.subTitle.text = self.memberInfo?.email == "" ? VCAppLetor.StringLine.NotSetYet : self.memberInfo?.email
        }
        else if (indexPath.section == 0 && indexPath.row == 2) { // Nickname
            cell.title.text = VCAppLetor.UserPanel.Nickname
            cell.subTitle.text = self.memberInfo?.nickname == "" ? VCAppLetor.StringLine.NotSetYet : self.memberInfo?.nickname
        }
        else if (indexPath.section == 1 && indexPath.row == 0) { // Phone Number
            cell.title.text = VCAppLetor.UserPanel.PhoneNumber
            var phoneNumber = self.memberInfo?.mobile == "" ?  VCAppLetor.StringLine.NotSetYet : self.memberInfo?.mobile!
            
            if phoneNumber != VCAppLetor.StringLine.NotSetYet {
                var range = Range<String.Index>(start: advance(phoneNumber!.startIndex, 3),end: advance(phoneNumber!.endIndex, -4))
                phoneNumber!.replaceRange(range, with: "••••")
            }
            
            cell.subTitle.text = phoneNumber!
            
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
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return VCAppLetor.ConstValue.UserPanelCellHeight+20
        }
        else {
            return VCAppLetor.ConstValue.UserPanelCellHeight
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected: AnyObject! = self.userInfoDataSource[indexPath.section][indexPath.row]
        
        let editMemberInfoViewController: EditUserInfoViewController = EditUserInfoViewController()
        editMemberInfoViewController.parentNav = self.parentNav
        editMemberInfoViewController.delegate = self
        editMemberInfoViewController.memberInfo = self.memberInfo
        
        if (indexPath.section == 0 && indexPath.row == 0) { // Avatar
            
            let UConfig: UzysAppearanceConfig = UzysAppearanceConfig()
            UConfig.finishSelectionButtonColor = UIColor.nephritisColor()
            UConfig.cellSpacing = 1.0
            UConfig.assetsCountInALine = 3
            UzysAssetsPickerController.setUpAppearanceConfig(UConfig)
            
            
            self.picker.delegate = self
            self.picker.maximumNumberOfSelectionPhoto = 1
            
            self.presentViewController(self.picker, animated: true, completion: { () -> Void in
                
            })
            return
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // Nickname
            editMemberInfoViewController.editType = VCAppLetor.EditType.Email
        }
        else if (indexPath.section == 0 && indexPath.row == 2) { // Nickname
            editMemberInfoViewController.editType = VCAppLetor.EditType.Nickname
        }
        else if (indexPath.section == 1 && indexPath.row == 0) { // Phone number
            RKDropdownAlert.title(VCAppLetor.StringLine.MobileCannotChange, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            return
        }
        else if (indexPath.section == 1 && indexPath.row == 1) { // Passcode
            editMemberInfoViewController.editType = VCAppLetor.EditType.Password
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
    
    // MARK: - UzysAssetsPickerController Delegate
    
    func uzysAssetsPickerController(picker: UzysAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        
        if (assets[0].valueForProperty("ALAssetPropertyType")).isEqualToString("ALAssetTypePhoto") {
            
            let assetsArr = assets as NSArray
            
            let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.picker.view, animated: true)
            hud.mode = MBProgressHUDMode.Indeterminate
            
            assetsArr.enumerateObjectsUsingBlock({ (obj, idx, stop) -> Void in
                
                let representation: ALAsset = obj as! ALAsset
                
                //                let img: UIImage = UIImage(CGImage: representation.defaultRepresentation().fullResolutionImage() as! CGImage)!
                let img: UIImage = UIImage(CGImage: representation.defaultRepresentation().fullResolutionImage().takeUnretainedValue() as CGImage)!
                
                let iconResizedImage = Toucan.Resize.resizeImage(img, size: CGSizeMake(200, 200), fitMode: Toucan.Resize.FitMode.Crop)
                
                // Uploading image to server
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                let dic: NSDictionary = NSDictionary(object: memberId, forKey: "member_id")
                
                if self.reachability.isReachable() {
                    
                    var directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
                    directoryURL = directoryURL!.URLByAppendingPathComponent("avatar")
                    
                    if !NSFileManager.defaultManager().fileExistsAtPath(directoryURL!.path!) {
                        
                        NSFileManager.defaultManager().createDirectoryAtPath(directoryURL!.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
                    }
                    
                    directoryURL = directoryURL!.URLByAppendingPathComponent("\(memberId)")
                    
                    var err: NSError?
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(directoryURL!.path!) {
                        
                        NSFileManager.defaultManager().removeItemAtPath(directoryURL!.path!, error: &err)
                        println("remove path: \(directoryURL!.path!)")
                    }
                    
                    NSFileManager.defaultManager().createFileAtPath(directoryURL!.path!, contents: UIImagePNGRepresentation(iconResizedImage), attributes: nil)
                    
                    
                    (self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! UserInfoCell).avatar.image = iconResizedImage
                    
                    let result: NSDictionary = self.uploadIcon(dic, route: "member/member/editMemberIcon", token: token, image: iconResizedImage)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if !result.isEqualToDictionary(NSDictionary.new() as [NSObject : AnyObject]) {
                            
                            if (result.valueForKey("status") as! NSDictionary).valueForKey("succeed") as! String == "1" {
                                
                                hud.hide(true)
                                println("upload successful")
                                
                                
                                
                                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberIcon, data: iconResizedImage, namespace: "member")
                            }
                            else {
                                let errStr = (result.valueForKey("status") as! NSDictionary).valueForKey("error_desc") as! String
                                println("\(errStr)")
                                hud.hide(true)
                            }
                        }
                    })
                }
                else {
                    
                    hud.hide(true)
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                
            })
            
        }
    }
    
    func uzysAssetsPickerControllerDidCancel(picker: UzysAssetsPickerController!) {
        
        
    }
    
    func uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection(picker: UzysAssetsPickerController!) {
        
        let alert: UIAlertView = UIAlertView(title: "", message: VCAppLetor.StringLine.OneImageOnly, delegate: self, cancelButtonTitle: VCAppLetor.StringLine.Done)
        
        alert.show()
    }
    
    func uploadIcon(data: NSDictionary, route: String, token: String, image: UIImage) -> NSDictionary {
        
        let s_boundary: String = "AaB03x"
        
        let jsonData: NSData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        //let jsonText: String = "\(NSString(data: jsonData, encoding: NSUTF8StringEncoding))"
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let jsonText: String = "{\"member_id\":\"\(memberId)\"}"
        
        let baseURL: String = VCheckGo.Router.baseAPIURLString
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: baseURL)!, cachePolicy:NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let MPboundary: String = "--\(s_boundary)"
        let endMPboundary: String = "\(MPboundary)--"
        
        let imageData: NSData = UIImageJPEGRepresentation(image, 1.0)
        
        let body: NSMutableString = NSMutableString()
        
        body.appendFormat("%@\r\n", MPboundary)
        body.appendFormat("Content-Disposition: form-data; name=\"%@\"\r\n\r\n", "route")
        body.appendFormat("%@\r\n", route)
        
        body.appendFormat("%@\r\n", MPboundary)
        body.appendFormat("Content-Disposition: form-data; name=\"%@\"\r\n\r\n", "token")
        body.appendFormat("%@\r\n", token)
        
        body.appendFormat("%@\r\n", MPboundary)
        body.appendFormat("Content-Disposition: form-data; name=\"%@\"\r\n\r\n", "jsonText")
        body.appendFormat("%@\r\n", jsonText)
        
        body.appendFormat("%@\r\n", MPboundary)
        body.appendFormat("Content-Disposition: form-data; name=\"image\"; filename=\"boris.jpg\"\r\n")
        body.appendFormat("Content-Type: image/jpeg\r\n\r\n")
        
        let end: String = "\r\n\(endMPboundary)"
        
        let myRequestData: NSMutableData = NSMutableData()
        
        myRequestData.appendData(body.dataUsingEncoding(NSUTF8StringEncoding)!)
        //myRequestData.appendData(("Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        myRequestData.appendData(imageData)
        
        myRequestData.appendData(end.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        
        
        request.setValue("multipart/form-data; boundary=\(s_boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(myRequestData.length)", forHTTPHeaderField: "Content-Length")
        request.HTTPBody = myRequestData
        request.HTTPMethod = "POST"
        
        
        let returnData: NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)!
        
        if !returnData.isEqual(nil) {
            
            let respText = NSString(data: returnData, encoding: NSUTF8StringEncoding)
            
            let jsonObject: NSDictionary = NSJSONSerialization.JSONObjectWithData(returnData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
            
            return jsonObject
        }
        
        return NSDictionary.new()
        
    }
    
    
    // MARK: - EditMemberInfoDelegate
    
    func didFinishEditingMemberInfo(email: String, nickname: String) {
        
        if email != "" {
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! UserInfoCell
            cell.subTitle.text = email
            
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            if let member = Member.findFirst(attribute: "mid", value: mid, contextType: BreezeContextType.Main) as? Member {
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    member.email = email
                })
                
                let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                
                memberInfo.email = email
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
            }
            else { //Create member record if DO NOT EXIST
                
                let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    
                    member.mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                    member.email = email
                    member.phone = memberInfo.mobile!
                    member.nickname = memberInfo.nickname!
                    member.iconURL = memberInfo.icon!
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
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! UserInfoCell
            cell.subTitle.text = nickname
            
            let mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            if let member = Member.findFirst(attribute: "mid", value: mid, contextType: BreezeContextType.Main) as? Member {
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    member.nickname = nickname
                })
                
                let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                
                memberInfo.nickname = nickname
                
                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
            }
            else { //Create member record if DO NOT EXIST
                
                let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    
                    member.mid = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                    member.email = memberInfo.email!
                    member.phone = memberInfo.mobile!
                    member.nickname = nickname
                    member.iconURL = memberInfo.icon!
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
            
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.hud.mode = MBProgressHUDMode.Indeterminate
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            if memberId != "0" && token != "0" {
                
                
                let deviceToken = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optDeviceToken, namespace: "DeviceToken")?.data as! String
                
                Alamofire.request(VCheckGo.Router.MemberLogout(token, memberId, deviceToken)).validate().responseSwiftyJSON({
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
                            
                            // Push user device token
                            //pushDeviceToken(VCheckGo.PushDeviceType.delete, tokenStr: token)
                            
                            // Call delegate
                            self.parentNav?.popViewControllerAnimated(true)
                            self.delegate?.memberDidLogoutSuccess(memberId)
                            
                            self.hud.hide(true)
                            
                        }
                        else {
                            
                            self.hud.hide(true)
                            
                            // If token error, logout anyway
                            if json["status"]["error_code"].string! == VCAppLetor.ErrorCode.TokenError {
                                
                                self.delegate?.memberDidLogoutSuccess(memberId)
                                self.parentNav?.popViewControllerAnimated(true)
                            }
                            
                            
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        self.hud.hide(true)
                        println("ERROR @ request for member logout : \(error?.localizedDescription)")
                    }
                })
            }
            else {
                self.hud.hide(true)
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