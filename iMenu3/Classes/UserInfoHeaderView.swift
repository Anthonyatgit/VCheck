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
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        if (token != "0"){
            
            if self.reachability.isReachable() {
                
                self.panelTitle.text = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Nickname, namespace: "member")?.data as? String
                let icon = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Icon, namespace: "member")?.data as! String
                Alamofire.request(.GET, icon).validate().responseImage() {
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
        else {
            
            self.panelIcon.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
            self.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
        }
        
//        self.disclosureIndicator.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)
//        self.disclosureIndicator.alpha = 0.2
//        self.addSubview(self.disclosureIndicator)
        
        
        oY += 20.0 + 30.0
        self.mailBoxButton.frame = CGRectMake(self.width/2.0-130, oY, 110, 40.0)
        self.mailBoxButton.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.mailBoxButton.icon.image = UIImage(named: VCAppLetor.IconName.MailBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.mailBoxButton.titleStr.text = VCAppLetor.StringLine.MyMail
        self.mailBoxButton.titleStr.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.mailBoxButton.titleStr.font = VCAppLetor.Font.SmallFont
        self.mailBoxButton.backgroundColor = UIColor.clearColor()
        self.addSubview(self.mailBoxButton)
        
        self.inviteButton.frame = CGRectMake(self.width/2.0+20, oY, 110, 40.0)
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
        
        println("invite")
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
            
            self.icon.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(8.0, 14.0, 10.0, 0.0), excludingEdge: .Trailing)
            self.icon.autoMatchDimension(.Width, toDimension: .Height, ofView: self, withOffset: -20.0)
            
            self.titleStr.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.icon, withOffset: 6.0)
            self.titleStr.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.titleStr.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 6.0)
            self.titleStr.autoMatchDimension(.Height, toDimension: .Height, ofView: self.icon, withMultiplier: 0.8)
            
            self.didSetConstraints = true
        }
        
        super.updateConstraints()
        
    }
    
}

