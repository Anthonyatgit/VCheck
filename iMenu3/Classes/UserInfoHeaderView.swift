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
    
    let disclosureIndicator: UIImageView = UIImageView.newAutoLayoutView()
    
    var panelIcon: UIImageView = UIImageView.newAutoLayoutView()
    var panelTitle: UILabel = UILabel.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    var userPanelViewController: UserPanelViewController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    func setupViews() {
        
        self.contentMode = UIViewContentMode.ScaleAspectFit
//        self.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        
        self.panelIcon.layer.cornerRadius = VCAppLetor.ConstValue.ImageCornerRadius
        self.panelIcon.alpha = 0.2
        self.panelIcon.layer.cornerRadius = self.panelIcon.frame.size.width / 2.0
        self.addSubview(self.panelIcon)
        
        self.panelTitle.font = VCAppLetor.Font.BigFont
        self.panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.addSubview(self.panelTitle)
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        if (token != "0"){
            
            self.panelTitle.text = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Nickname, namespace: "member")?.data as? String
            let icon = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Icon, namespace: "member")?.data as! String
            Alamofire.request(.GET, icon).validate().responseImage() {
                (_, _, image, error) in
                
                if error == nil && image != nil {
                    self.panelIcon.image = image
                    self.panelIcon.alpha = 1.0
                }
            }
            
        }
        else {
            self.panelIcon.image = UIImage(named: VCAppLetor.IconName.UserInfoIconWithoutSignin)
            self.panelTitle.text = VCAppLetor.StringLine.UserInfoWithoutSignin
        }
        
        self.disclosureIndicator.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)
        self.disclosureIndicator.alpha = 0.2
        self.addSubview(self.disclosureIndicator)
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            
            self.panelIcon.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.panelIcon.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            self.panelIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
            
            self.panelTitle.autoSetDimensionsToSize(CGSizeMake(160.0, 20.0))
            self.panelTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.panelIcon, withOffset: 14.0)
            self.panelTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.disclosureIndicator.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
            self.disclosureIndicator.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self, withOffset: -8.0)
            self.disclosureIndicator.autoAlignAxisToSuperviewAxis(.Horizontal)
        }
        
        super.updateConstraints()
    }
    
    
    
    
    
}