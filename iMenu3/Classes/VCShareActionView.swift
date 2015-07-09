//
//  VCShareActionView.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/18.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import QuartzCore
import PureLayout
import DKChainableAnimationKit
import RKDropdownAlert

class VCShareActionView: UIView {
    
    var isShow: Bool?
    
    var shareType: VCAppLetor.ShareType!
    
    var foodItem: FoodItem?
    var foodInfo: FoodInfo?
    var inviteItem: String?
    
    let blackBG: UIView = UIView.newAutoLayoutView()
    var visualEffectView: UIVisualEffectView?
    
    let shareBox: UIView = UIView()
    
    let weiboShareButton: UIButton = UIButton()
    let wechatShareButton: UIButton = UIButton()
    let friendsShareButton: UIButton = UIButton()
    
    let weiboName: UILabel = UILabel()
    let wechatName: UILabel = UILabel()
    let friendsName: UILabel = UILabel()
    
    let cancleButton: UIButton = UIButton()
    
    var tapGuestureBG: UITapGestureRecognizer!
    var tapGuestureF: UITapGestureRecognizer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        
        self.setupView()
        
    }
    
    func setupView() {
        
        self.isShow = true
        
//        self.blackBG.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
//        self.addSubview(self.blackBG)
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.visualEffectView!.frame = self.frame
        self.visualEffectView!.alpha = 0.1
        
        self.addSubview(self.visualEffectView!)
        
        self.visualEffectView!.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        self.shareBox.backgroundColor = UIColor.whiteColor()
        self.shareBox.frame = CGRectMake(0, self.height, self.width, 200.0)
        self.addSubview(self.shareBox)
        
        self.weiboShareButton.frame = CGRectMake(self.shareBox.width/4-27, 30, 54, 54)
        self.weiboShareButton.setImage(UIImage(named: "weibo_color.png"), forState: .Normal)
        self.weiboShareButton.backgroundColor = UIColor.whiteColor()
        self.weiboShareButton.imageEdgeInsets = UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0)
        self.weiboShareButton.addTarget(self, action: "shareContent:", forControlEvents: .TouchUpInside)
        self.weiboShareButton.layer.cornerRadius = 27.0
        self.weiboShareButton.layer.borderWidth = 1.0
        self.weiboShareButton.layer.borderColor = UIColor.alizarinColor().CGColor
        self.weiboShareButton.alpha = 0.8
        self.weiboShareButton.tag = 1
        self.shareBox.addSubview(self.weiboShareButton)
        
        self.weiboName.text = VCAppLetor.StringLine.Weibo
        self.weiboName.textAlignment = .Center
        self.weiboName.textColor = UIColor.alizarinColor()
        self.weiboName.font = VCAppLetor.Font.SmallFont
        self.weiboName.originX = self.weiboShareButton.originX
        self.weiboName.originY = self.weiboShareButton.originY + 54 + 10
        self.weiboName.size = CGSizeMake(54, 20)
        self.shareBox.addSubview(self.weiboName)
        
        self.wechatShareButton.frame = CGRectMake(self.shareBox.width/2-27, 30, 54, 54)
        self.wechatShareButton.setImage(UIImage(named: "wechat_color.png"), forState: .Normal)
        self.wechatShareButton.backgroundColor = UIColor.whiteColor()
        self.wechatShareButton.imageEdgeInsets = UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0)
        self.wechatShareButton.addTarget(self, action: "shareContent:", forControlEvents: .TouchUpInside)
        self.wechatShareButton.layer.cornerRadius = 27.0
        self.wechatShareButton.layer.borderWidth = 1.0
        self.wechatShareButton.layer.borderColor = UIColor.nephritisColor().CGColor
        self.wechatShareButton.alpha = 0.8
        self.wechatShareButton.tag = 2
        self.shareBox.addSubview(self.wechatShareButton)
        
        self.wechatName.text = VCAppLetor.StringLine.Wechat
        self.wechatName.textAlignment = .Center
        self.wechatName.textColor = UIColor.nephritisColor()
        self.wechatName.font = VCAppLetor.Font.SmallFont
        self.wechatName.originX = self.wechatShareButton.originX
        self.wechatName.originY = self.wechatShareButton.originY + 54 + 10
        self.wechatName.size = CGSizeMake(54, 20)
        self.shareBox.addSubview(self.wechatName)
        
        self.friendsShareButton.frame = CGRectMake(self.shareBox.width*3/4-27, 30, 54, 54)
        self.friendsShareButton.setImage(UIImage(named: "friends_color.png"), forState: .Normal)
        self.friendsShareButton.backgroundColor = UIColor.whiteColor()
        self.friendsShareButton.imageEdgeInsets = UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0)
        self.friendsShareButton.addTarget(self, action: "shareContent:", forControlEvents: .TouchUpInside)
        self.friendsShareButton.layer.cornerRadius = 27.0
        self.friendsShareButton.layer.borderWidth = 1.0
        self.friendsShareButton.layer.borderColor = UIColor.orangeColor().CGColor
        self.friendsShareButton.alpha = 0.8
        self.friendsShareButton.tag = 3
        self.shareBox.addSubview(self.friendsShareButton)
        
        self.friendsName.text = VCAppLetor.StringLine.Friends
        self.friendsName.textAlignment = .Center
        self.friendsName.textColor = UIColor.orangeColor()
        self.friendsName.font = VCAppLetor.Font.SmallFont
        self.friendsName.originX = self.friendsShareButton.originX
        self.friendsName.originY = self.friendsShareButton.originY + 54 + 10
        self.friendsName.size = CGSizeMake(54, 20)
        self.shareBox.addSubview(self.friendsName)
        
        self.cancleButton.frame = CGRectMake(-1, 150, self.width+2, 51)
        self.cancleButton.setTitle(VCAppLetor.StringLine.Cancle, forState: .Normal)
        self.cancleButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.6), forState: .Normal)
        self.cancleButton.titleLabel?.font = VCAppLetor.Font.NormalFont
        self.cancleButton.layer.borderWidth = 1.0
        self.cancleButton.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor
        self.cancleButton.addTarget(self, action: "cancleShare", forControlEvents: .TouchUpInside)
        self.shareBox.addSubview(self.cancleButton)
        
        
        self.tapGuestureBG = UITapGestureRecognizer(target: self, action: "shareViewDidTaped:")
        self.tapGuestureBG.numberOfTapsRequired = 1
        self.tapGuestureBG.numberOfTouchesRequired = 1
        
        self.tapGuestureF = UITapGestureRecognizer(target: self, action: "shareViewDidTaped:")
        self.tapGuestureF.numberOfTapsRequired = 1
        self.tapGuestureF.numberOfTouchesRequired = 1
        
        self.blackBG.addGestureRecognizer(self.tapGuestureBG)
        self.shareBox.addGestureRecognizer(self.tapGuestureF)
        
        
        self.shareBox.animation.makeY(self.height-200.0).animate(0.3)
        self.visualEffectView!.animation.makeAlpha(0.9).animate(0.3)
        
    }
    
    func shareViewDidTaped(tapGuesture: UITapGestureRecognizer) {
        
        self.removeFromSuperview()
    }
    
    func cancleShare() {
        self.removeFromSuperview()
    }
    
    func shareContent(typeButton: UIButton) {
        
        
        //        var shareContent: ISSContent = ShareSDK.content("分享文字", defaultContent: "默认分享内容，没内容时显示", image: nil, title: "提示", url: "返回链接", description: "这是一条测试内容", mediaType: SSPublishContentMediaTypeNews)
        //
        //        var shareList: NSArray = ShareSDKContentController.getCustomShareList()
        //
        //        let container: ISSContainer = ShareSDK.container()
        //        container.setIPhoneContainerWithViewController(self)
        //
        //        ShareSDK.showShareActionSheet(nil,
        //            shareList: nil,
        //            content: shareContent,
        //            statusBarTips: true,
        //            authOptions: nil,
        //            shareOptions: nil,
        //            result: { (type: ShareType, state:SSResponseState, statusInfo: ISSPlatformShareInfo!, error: ICMErrorInfo!, end: Bool) in
        //
        //        })
        
        var type: ShareType!
        
        switch typeButton.tag {
            
        case 1:
            type = ShareTypeSinaWeibo
        case 2:
            type = ShareTypeWeixiSession
        case 3:
            type = ShareTypeWeixiTimeline
        default:
            type = nil
        }
        
        
        let shareContent: ISSContent = ShareSDK.content(self.foodItem?.title, defaultContent: VCAppLetor.StringLine.DefaultShareContent, image: nil, title: "VCheck-美食", url: VCAppLetor.StringLine.AppWebsiteURL, description: "测试v0.0.1", mediaType: SSPublishContentMediaTypeNews)
        
        ShareSDK.shareContent(shareContent, type: type, authOptions: nil, shareOptions: nil, statusBarTips: false) {
            (type, state, statusInfo, error, end) -> Void in
            
            if state.value == SSPublishContentStateSuccess.value {
                
                RKDropdownAlert.title(VCAppLetor.StringLine.ShareSucceed, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                
            }
            else if state.value == SSPublishContentStateCancel.value {
                
                RKDropdownAlert.title(VCAppLetor.StringLine.ShareCancledByUser, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            else if state.value == SSPublishContentStateFail.value {
                
                RKDropdownAlert.title(VCAppLetor.StringLine.ShareFailed, message: "\(error.errorCode()) | \(error.errorDescription())", backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        }
        
        
    }
    

    
}



