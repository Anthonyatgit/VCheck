//
//  UserInfoHeaderView.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/18.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import QuartzCore
import PureLayout
import Alamofire

class UserInfoHeaderView: UIView {
    
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    let disclosureIndicator: UIImageView = UIImageView.newAutoLayoutView()
    
    let panelIcon: UIImageView = UIImageView()
    let panelTitle: UILabel = UILabel()
    
    let mailBoxButton: UserIconButton = UserIconButton()
    let inviteButton: UserIconButton = UserIconButton()
    
    var memberInfo: MemberInfo?
    
    var didSetupConstraints = false
    
    var userPanelViewController: UserPanelViewController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    func setupViews() {
        
//        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.clearColor()
        
        var oY: CGFloat = 0.0
        
        self.panelIcon.frame = CGRectMake(self.width/2.0-self.width/5.0/2.0, 30.0, self.width/5.0, self.width/5.0)
        self.panelIcon.layer.cornerRadius = self.panelIcon.width / 2.0
        self.panelIcon.layer.masksToBounds = true
        self.panelIcon.layer.borderWidth = 1.0
        self.panelIcon.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.4).CGColor
        self.addSubview(self.panelIcon)
        
        oY += 30.0 + self.width/5.0 + 10.0
        self.panelTitle.frame = CGRectMake(20, oY, self.width-40.0, 20.0)
        self.panelTitle.font = VCAppLetor.Font.BigFont
        self.panelTitle.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        self.panelTitle.textAlignment = .Center
        self.addSubview(self.panelTitle)
        
        var token: String = "0"
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
            
            token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        }
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optMemberIcon, namespace: "member") {
            
            self.panelIcon.image = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberIcon, namespace: "member")?.data as? UIImage
            self.panelTitle.text = self.memberInfo!.nickname!
        }
        else {
            if (token != "0"){
                
                
                self.panelTitle.text = self.memberInfo!.nickname
                
                let midString = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                
                // Read avatar icon from local cache file
                if var avatarDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                    
                    var err: NSError?
                    
                    avatarDirectoryURL = avatarDirectoryURL.URLByAppendingPathComponent("/avatar/\(midString)")
                    
                    let avatarIconFile = NSFileManager.defaultManager().contentsAtPath(avatarDirectoryURL.path!)
                    
                    if avatarIconFile != nil {
                        
                        let avatarIconImage = UIImage(data: avatarIconFile!)
                        
                        let avatarIcon = Toucan.Resize.resizeImage(avatarIconImage!, size: CGSizeMake(self.width/5.0, self.width/5.0), fitMode: Toucan.Resize.FitMode.Crop)
                        
                        self.panelIcon.image = avatarIcon
                        
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberIcon, data: avatarIcon, namespace: "member")
                    }
                    else {
                        
                        let icon = self.memberInfo!.icon!
                        Alamofire.request(.GET, icon).validate().responseImage() {
                            (_, _, image, error) in
                            
                            if error == nil && image != nil {
                                
                                self.panelIcon.image = image
                                
                                CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberIcon, data: image, namespace: "member")
                            }
                        }
                    }
                }
                
            }
            else {
                
                if CTMemCache.sharedInstance.exists(VCAppLetor.LoginType.WeChat, namespace: "Sign") {
                    
                    let avatar = CTMemCache.sharedInstance.get(VCAppLetor.LoginStatus.WechatAvatar, namespace: "LoginStatus")?.data as! String
                    let nickname = CTMemCache.sharedInstance.get(VCAppLetor.LoginStatus.WechatNickname, namespace: "LoginStatus")?.data as! String
                    
                    self.panelTitle.text = nickname
                    // If local file do not exist, download and save in local directory
                    Alamofire.request(.GET, avatar).validate().responseImage() {
                        (_, _, image, error) in
                        
                        if error == nil && image != nil {
                            
                            self.panelIcon.image = image
                            
                        }
                    }
                }
                else {
                    
                    self.panelIcon.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
                    self.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    self.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
                }
                
                
            }
        }
        
        
        
//        self.disclosureIndicator.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)
//        self.disclosureIndicator.alpha = 0.2
//        self.addSubview(self.disclosureIndicator)
        
        
        oY += 20.0 + 30.0
        self.mailBoxButton.frame = CGRectMake(self.width/2.0-130, oY, 110, 38.0)
        self.mailBoxButton.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.mailBoxButton.icon.image = UIImage(named: VCAppLetor.IconName.MailBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.mailBoxButton.titleStr.text = VCAppLetor.StringLine.MyMail
        self.mailBoxButton.titleStr.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.mailBoxButton.titleStr.font = VCAppLetor.Font.SmallFont
        self.mailBoxButton.backgroundColor = UIColor.clearColor()
        self.addSubview(self.mailBoxButton)
        
        self.inviteButton.frame = CGRectMake(self.width/2.0+20, oY, 110, 38.0)
        self.inviteButton.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.inviteButton.icon.image = UIImage(named: VCAppLetor.IconName.GiftBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.inviteButton.titleStr.text = VCAppLetor.StringLine.InviteFriend
        self.inviteButton.titleStr.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.inviteButton.titleStr.font = VCAppLetor.Font.SmallFont
        self.inviteButton.backgroundColor = UIColor.whiteColor()
        self.inviteButton.addTarget(self, action: "invite", forControlEvents: .TouchUpInside)
        self.addSubview(self.inviteButton)
        
        
        
    }
    
    // MARK : - Functions
    
    
    func invite() {
        
        if CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
            
            let inviteVC: VCInviteViewController = VCInviteViewController()
            inviteVC.parentNav = self.userPanelViewController?.parentNav
            self.userPanelViewController?.parentNav?.showViewController(inviteVC, sender: self)
        }
        else {
            
            self.userPanelViewController!.presentLoginPanel()
        }
        
    }
    
    
    
}

// MARK: - IconButton
// Button with icon@left & text@right
class UserIconButton: UIButton {
    
    let icon: UIImageView = UIImageView.newAutoLayoutView()
    let titleStr: UILabel = UILabel.newAutoLayoutView()
    
    var bgColor: UIColor?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var didSetConstraints = false
    
    func setupView() {
        
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        self.backgroundColor = self.bgColor
        
        self.addSubview(self.icon)
        
        self.titleStr.textAlignment = .Center
        self.titleStr.textColor = UIColor.blackColor()
        self.titleStr.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.titleStr)
        
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        
        if !self.didSetConstraints {
            
            self.icon.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(6.0, 12.0, 6.0, 0.0), excludingEdge: .Trailing)
            self.icon.autoMatchDimension(.Width, toDimension: .Height, ofView: self, withOffset: -12.0)
            
            self.titleStr.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.icon, withOffset: 6.0)
            self.titleStr.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.titleStr.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 6.0)
            self.titleStr.autoMatchDimension(.Height, toDimension: .Height, ofView: self.icon, withMultiplier: 1.0)
            
            self.didSetConstraints = true
        }
        
        super.updateConstraints()
        
    }
    
}

