//
//  VCInviteViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/17.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert

class VCInviteViewController: VCBaseViewController, UIScrollViewDelegate {
    
    // MARK: - Make Values
    
    var scrollView: UIScrollView = UIScrollView()
    
    var bView: UIView!
    
    let largeCircle: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let inviteCount: UILabel = UILabel.newAutoLayoutView()
    let inviteUnit: UILabel = UILabel.newAutoLayoutView()
    
    let inviteTips: UILabel = UILabel.newAutoLayoutView()
    
    let codeBg: UIView = UIView.newAutoLayoutView()
    
    let codeIcon: UIImageView = UIImageView.newAutoLayoutView()
    let myCode: UILabel = UILabel.newAutoLayoutView()
    
    let rewards1: UILabel = UILabel.newAutoLayoutView()
    let rewards2: UILabel = UILabel.newAutoLayoutView()
    
    let inviteBtn: UIButton = UIButton.newAutoLayoutView()
    
    var didSetupConstraints: Bool = false
    
    let shareBtn: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 26.0, 26.0))
    
    var parentNav: UINavigationController?
    
    var shareView: VCShareActionView?
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.ShareToGetCoupon
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.height = self.view.height - 62.0
        self.scrollView.originY = 62.0
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        self.shareBtn.setImage(UIImage(named: VCAppLetor.IconName.ShareBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        self.shareBtn.tintColor = UIColor.whiteColor()
        self.shareBtn.addTarget(self, action: "inviteFriendAction:", forControlEvents: .TouchUpInside)
        self.shareBtn.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.shareBtn)
        
        let tableBG: UIImageView = UIImageView(frame: self.view.frame)
        tableBG.image = UIImage(named: "user_nep.jpg")
        self.view.addSubview(tableBG)
        
        self.setupShareView()
        
        self.view.addSubview(self.scrollView)
        
        self.setupShareViewConstraints()
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "showUserInfo:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        
        if self.didSetupConstraints {
            
            let height = self.inviteBtn.originY + 40.0
            
            if height < self.scrollView.height {
                
                self.scrollView.contentSize.height += 1
            }
            else {
                self.scrollView.contentSize.height = self.inviteBtn.originY + 60.0
            }
            
        }
        
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Functions
    
    func setupShareView() {
        
        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
        
        self.largeCircle.drawType = "circle"
        self.largeCircle.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(self.largeCircle)
        
        self.inviteCount.text = memberInfo.inviteCount
        self.inviteCount.textAlignment = .Center
        self.inviteCount.textColor = UIColor.cloudsColor(alpha: 0.8)
        self.inviteCount.font = VCAppLetor.Font.XXXXUltraLight
        self.inviteCount.backgroundColor = UIColor.clearColor()
        self.inviteCount.sizeToFit()
        self.scrollView.addSubview(self.inviteCount)
        
        self.inviteUnit.text = "人"
        self.inviteUnit.textAlignment = .Left
        self.inviteUnit.textColor = UIColor.silverColor()
        self.inviteUnit.font = VCAppLetor.Font.NormalFont
        self.inviteUnit.backgroundColor = UIColor.clearColor()
        self.inviteUnit.sizeToFit()
        self.scrollView.addSubview(self.inviteUnit)
        
        self.inviteTips.text = memberInfo.inviteTip
        self.inviteTips.textAlignment = .Center
        self.inviteTips.textColor = UIColor.cloudsColor(alpha: 0.5)
        self.inviteTips.font = VCAppLetor.Font.NormalFont
        self.inviteTips.backgroundColor = UIColor.clearColor()
        self.inviteTips.sizeToFit()
        self.scrollView.addSubview(self.inviteTips)
        
        self.codeBg.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        self.scrollView.addSubview(self.codeBg)
        
        self.myCode.text = memberInfo.inviteCode
        self.myCode.textAlignment = .Center
        self.myCode.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.myCode.font = VCAppLetor.Font.XXLight
        self.myCode.sizeToFit()
        self.codeBg.addSubview(self.myCode)
        
        self.codeIcon.image = UIImage(named: VCAppLetor.IconName.CouponBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.codeIcon.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.codeBg.addSubview(self.codeIcon)
        
//        self.rewards1.text = VCAppLetor.StringLine.Rewards1
//        self.rewards1.textAlignment = .Center
//        self.rewards1.textColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
//        self.rewards1.font = VCAppLetor.Font.NormalFont
//        self.rewards1.sizeToFit()
//        self.codeBg.addSubview(self.rewards1)
        
        self.rewards2.text = memberInfo.inviteRewards
        self.rewards2.textAlignment = .Center
        self.rewards2.textColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.rewards2.font = VCAppLetor.Font.SmallFont
        self.rewards2.sizeToFit()
        self.codeBg.addSubview(self.rewards2)
        
        self.inviteBtn.setTitle(VCAppLetor.StringLine.InviteFriend, forState: .Normal)
        self.inviteBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.inviteBtn.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        self.inviteBtn.backgroundColor = UIColor.nephritisColor()
        self.inviteBtn.addTarget(self, action: "inviteFriendAction:", forControlEvents: .TouchUpInside)
        self.codeBg.addSubview(self.inviteBtn)
        
        
    }
    
    func setupShareViewConstraints() {
        
        self.largeCircle.autoSetDimensionsToSize(CGSizeMake(self.view.width-80.0, self.view.width-80.0))
        self.largeCircle.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
        self.largeCircle.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.inviteCount.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.largeCircle, withOffset: (self.view.width-80.0)/2.0+10.0)
        self.inviteCount.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.inviteUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.inviteCount)
        self.inviteUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.inviteCount, withOffset: 2.0)
        
        self.inviteTips.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.largeCircle, withOffset: 20.0)
        self.inviteTips.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.codeBg.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.inviteTips, withOffset: 20.0)
        self.codeBg.autoSetDimensionsToSize(CGSizeMake(self.view.width, 800))
        self.codeBg.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.myCode.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        self.myCode.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.codeIcon.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.myCode, withOffset: -40.0)
        self.codeIcon.autoAlignAxis(.Horizontal, toSameAxisOfView: self.myCode)
        self.codeIcon.autoSetDimensionsToSize(CGSizeMake(28, 24))
        
//        self.rewards1.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.myCode, withOffset: 20.0)
//        self.rewards1.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.rewards2.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.myCode, withOffset: 24.0)
        self.rewards2.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.inviteBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.rewards2, withOffset: 20.0)
        self.inviteBtn.autoSetDimensionsToSize(CGSizeMake(self.view.width-40, 40))
        self.inviteBtn.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.didSetupConstraints = true
    }

    
    func inviteFriendAction(btn: UIButton) {
        
        self.shareView?.removeFromSuperview()
        
        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
        
        self.shareView = VCShareActionView(frame: self.view.frame)
        self.shareView!.shareType = VCAppLetor.ShareToType.invite
        self.shareView!.shareCode = memberInfo.inviteCode
        self.view.addSubview(self.shareView!)
        
    }
    


}



