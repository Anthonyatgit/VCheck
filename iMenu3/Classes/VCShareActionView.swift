//
//  VCShareActionView.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/18.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore
import PureLayout
import DKChainableAnimationKit
import RKDropdownAlert

class VCShareActionView: UIView {
    
    
    var isShow: Bool?
    
    var shareType: VCAppLetor.ShareToType!
    var shareCode: String?
    
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
        
        self.visualEffectView!.addGestureRecognizer(self.tapGuestureBG)
        self.shareBox.addGestureRecognizer(self.tapGuestureF)
        
        
        self.shareBox.animation.makeY(self.height-200.0).animate(0.3)
        self.visualEffectView!.animation.makeAlpha(1.0).animate(0.3)
        
        
    }
    
    func shareViewDidTaped(tapGuesture: UITapGestureRecognizer) {
        
        self.removeFromSuperview()
    }
    
    func cancleShare() {
        self.removeFromSuperview()
    }
    
    func shareContent(typeButton: UIButton) {
        
        var type: ShareType!
        
        var typeString: String = ""
        
        switch typeButton.tag {
            
        case 1:
            type = ShareTypeSinaWeibo
            typeString = "Weibo"
            CTMemCache.sharedInstance.set(VCAppLetor.ShareTag.shareWeibo, data: true, namespace: "share")
        case 2:
            type = ShareTypeWeixiSession
            typeString = "Wechat"
            CTMemCache.sharedInstance.set(VCAppLetor.ShareTag.shareWechat, data: true, namespace: "share")
        case 3:
            type = ShareTypeWeixiTimeline
            typeString = "Wechat"
            CTMemCache.sharedInstance.set(VCAppLetor.ShareTag.shareWechat, data: true, namespace: "share")
        default:
            type = nil
            typeString = ""
        }
        
        if let shareTag = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optShareTag, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                shareTag.sid = "\(NSDate())"
                shareTag.value = typeString
            })
        }
        else { // App version DO NOT exist, create one with empty
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let shareTagToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                shareTagToBeCreate.sid = "\(NSDate())"
                shareTagToBeCreate.name = VCAppLetor.SettingName.optShareTag
                shareTagToBeCreate.value = typeString
                shareTagToBeCreate.type = VCAppLetor.SettingType.AppConfig
                shareTagToBeCreate.data = ""
                
            })
            
        }
        
        
        if self.shareType == VCAppLetor.ShareToType.food {
            
            Alamofire.request(.GET, self.foodInfo!.foodImage!).validate(contentType: ["image/*"]).responseImage() {
                
                (_, _, image, error) in
                
                if error == nil && image != nil {
                    
                    let foodImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: 400, height: 400), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    let png = ShareSDK.pngImageWithImage(foodImage)
                    
                    var msg: String = "知味-最精致的餐品和就餐体验"
                    
                    var title = "\(self.foodInfo!.subTitle!)" as String
                    
                    if self.shareCode! != "" {
                        msg = msg + ", 用邀请码\(self.shareCode!)注册即获30元礼券"
                    }
                    
                    if type.value == ShareTypeWeixiTimeline.value {
                        title = title + ", 使用邀请码:\(self.shareCode!) 注册即获30元礼券"
                    }
                    
                    if type.value == ShareTypeSinaWeibo.value {
                        msg = "@知味_Taste 上的「\(title)」超赞~ 知味Taste最精致的高端定制餐饮体验"
                        
                        if self.shareCode! != "" {
                            msg = msg + ", 用邀请码 \(self.shareCode!) 即可获取30元礼券 \(self.foodInfo!.shareLink!)"
                        }
                        else {
                            msg = msg + " \(self.foodInfo!.shareLink!)"
                        }
                        
                    }
                    
                    
                    let shareContent: ISSContent = ShareSDK.content(msg, defaultContent: VCAppLetor.StringLine.DefaultShareContent, image: png, title: title, url: self.foodInfo!.shareLink!, description: "Description", mediaType: SSPublishContentMediaTypeNews)
                    
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
                        
                        self.removeFromSuperview()
                    }
                }
            }
            
        }
        else if self.shareType == VCAppLetor.ShareToType.invite {
            
            let voucherImage: UIImage = UIImage(named: VCAppLetor.IconName.CouponBlack)!
            
            let shareLink: String = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo).shareURL!
            
            let png = ShareSDK.pngImageWithImage(voucherImage)
            
            var title: String = "送你知味App独享30元礼券"
            
            if type.value == ShareTypeWeixiTimeline.value {
                
                title = title + ", 邀请码:\(self.shareCode!)"
            }
            
            var msg = "高端定制限量美食,享受最优质的用餐体验, 邀请码: \(self.shareCode!)"
            
            if type.value == ShareTypeSinaWeibo.value {
                
                msg = "@知味_Taste 邀请你体验 知味App-最精致的高端定制餐饮"
                
                msg = msg + ", 使用邀请码 \(self.shareCode!) 即可获取30元礼券 \(shareLink)"
                
                
            }
            
            let shareContent: ISSContent = ShareSDK.content(msg, defaultContent: "", image: png, title: title, url: shareLink, description: "v0.0.1", mediaType: SSPublishContentMediaTypeNews)
            
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
                
                self.removeFromSuperview()
            }
            
        }
        
        
        
    }
    

    
}



