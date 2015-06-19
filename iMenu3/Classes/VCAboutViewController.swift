//
//  VCAboutViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/16.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class VCAboutViewController: VCBaseViewController {
    
    
    let aboutSubTitle: UILabel = UILabel.newAutoLayoutView()
    let subtitleLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let appIcon: UILabel = UILabel.newAutoLayoutView()
    
    let appVersion: UILabel = UILabel.newAutoLayoutView()
    let appWebsiteURL: UILabel = UILabel.newAutoLayoutView()
    let appCopyright: UILabel = UILabel.newAutoLayoutView()
    
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.AboutTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.subtitleLine.drawType = "Line"
        self.subtitleLine.lineWidth = 1.0
        self.view.addSubview(self.subtitleLine)
        
        self.aboutSubTitle.text = VCAppLetor.StringLine.AppSubtitle
        self.aboutSubTitle.textAlignment = .Center
        self.aboutSubTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.aboutSubTitle.backgroundColor = UIColor.whiteColor()
        self.aboutSubTitle.font = VCAppLetor.Font.NormalFont
        self.view.addSubview(self.aboutSubTitle)
        
        
        self.appIcon.text = VCAppLetor.StringLine.AppName
        self.appIcon.textAlignment = .Center
        self.appIcon.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.appIcon.font = VCAppLetor.Font.XXXLarge
        self.view.addSubview(self.appIcon)
        
        if let version = Settings.findFirst(attribute: "name", value: "version_app", contextType: BreezeContextType.Main) as? Settings { // Get current app version
            
            self.appVersion.text = "V\(version.value)"
        }
        else { // App version DO NOT exist, create one with version "1.0"
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let versionToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                versionToBeCreate.sid = "\(NSDate())"
                versionToBeCreate.name = "version_app"
                versionToBeCreate.value = "1.0.0"
                versionToBeCreate.type = VCAppLetor.SettingType.AppConfig
                versionToBeCreate.data = ""
                
            })
            
            self.appVersion.text = "V1.0.0"
        }
        
        self.appVersion.textAlignment = .Center
        self.appVersion.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.appVersion.font = VCAppLetor.Font.BigFont
        self.appVersion.backgroundColor = UIColor.clearColor()
        self.appVersion.layer.cornerRadius = 15.0
        self.appVersion.layer.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1).CGColor
        self.view.addSubview(self.appVersion)
        
        self.appWebsiteURL.text = VCAppLetor.StringLine.AppWebsiteURL
        self.appWebsiteURL.textAlignment = .Center
        self.appWebsiteURL.textColor = UIColor.lightGrayColor()
        self.appWebsiteURL.font = VCAppLetor.Font.SmallFont
        self.view.addSubview(self.appWebsiteURL)
        
        self.appCopyright.text = VCAppLetor.StringLine.AppCopyRight
        self.appCopyright.textAlignment = .Center
        self.appCopyright.textColor = UIColor.lightGrayColor()
        self.appCopyright.font = VCAppLetor.Font.SmallFont
        self.view.addSubview(self.appCopyright)
        
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.subtitleLine.autoSetDimensionsToSize(CGSizeMake(162.0, 3.0))
        self.subtitleLine.autoPinEdgeToSuperviewEdge(.Top, withInset: 200.0)
        self.subtitleLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.aboutSubTitle.autoSetDimensionsToSize(CGSizeMake(142.0, 30.0))
        self.aboutSubTitle.autoAlignAxisToSuperviewAxis(.Vertical)
        self.aboutSubTitle.autoAlignAxis(.Horizontal, toSameAxisOfView: self.subtitleLine)
        
        self.appIcon.autoSetDimensionsToSize(CGSizeMake(220.0, 40.0))
        self.appIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        self.appIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.aboutSubTitle, withOffset: 30.0)
        
        self.appCopyright.autoPinEdgeToSuperviewEdge(.Top, withInset: self.view.height-50.0)
        self.appCopyright.autoAlignAxisToSuperviewAxis(.Vertical)
        self.appCopyright.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0, 20.0))
        
        self.appWebsiteURL.autoSetDimensionsToSize(CGSizeMake(self.view.width-100.0, 20.0))
        self.appWebsiteURL.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.appCopyright, withOffset: 0.0)
        self.appWebsiteURL.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.appVersion.autoSetDimensionsToSize(CGSizeMake(62.0, 30.0))
        self.appVersion.autoAlignAxisToSuperviewAxis(.Vertical)
        self.appVersion.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.appWebsiteURL, withOffset: -40.0)
        
    }
    
    
    
    
}


