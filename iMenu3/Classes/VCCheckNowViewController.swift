//
//  VCCheckNowViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/5.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD
import AFViewShaker
import IHKeyboardAvoiding


class VCCheckNowViewController: VCBaseViewController, UIScrollViewDelegate, UITextFieldDelegate, RKDropdownAlertDelegate, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate {
    
    var foodItem: FoodItem!
    
    var parentNav: UINavigationController!
    
    let scrollView: UIScrollView = UIScrollView()
    
    let topTip: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let foodTitleUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let priceName: UILabel = UILabel.newAutoLayoutView()
    let priceValue: UILabel = UILabel.newAutoLayoutView()
    let priceUnit: UILabel = UILabel.newAutoLayoutView()
    let priceUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let amountName: UILabel = UILabel.newAutoLayoutView()
    let reduceBtn: UIButton = UIButton.newAutoLayoutView()
    let plusBtn: UIButton = UIButton.newAutoLayoutView()
    let amountValue: UILabel = UILabel.newAutoLayoutView()
    let amountUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let totalPriceName: UILabel = UILabel.newAutoLayoutView()
    let totalPriceValue: UILabel = UILabel.newAutoLayoutView()
    let totalPriceUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let mobile: UITextField = UITextField.newAutoLayoutView()
    let sendVerifyBtn: UIButton = UIButton.newAutoLayoutView()
    let mobileUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var mobileShaker: AFViewShaker?
    
    let verifyCode: UITextField = UITextField.newAutoLayoutView()
    let verifyCodeUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var verifyCodeShaker: AFViewShaker?
    
    let loginNote: UILabel = UILabel.newAutoLayoutView()
    let loginBtn: UIButton = UIButton.newAutoLayoutView()
    
    let mobileName: UILabel = UILabel.newAutoLayoutView()
    let mobileNumber: UILabel = UILabel.newAutoLayoutView()
    
    let submitView: UIView = UIView.newAutoLayoutView()
    let submitBg: UIView = UIView.newAutoLayoutView()
    let submitBtn: UIButton = UIButton.newAutoLayoutView()
    let orderPriceName: UILabel = UILabel.newAutoLayoutView()
    let orderPriceValue: UILabel = UILabel.newAutoLayoutView()
    
    var remainingSecond: Int = VCAppLetor.ConstValue.SMSRemainingSeconds {
        willSet(newSecond) {
            self.sendVerifyBtn.titleLabel?.text = "\(newSecond)"
        }
    }
    
    var timer: NSTimer?
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            }
            else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.CheckNowTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.setupOrderView()
        
        self.setupSubmitView()
        
        self.updateViewConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        self.scrollView.contentSize.height = self.scrollView.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.topTip.autoSetDimensionsToSize(CGSizeMake(self.scrollView.width, 32.0))
        self.topTip.autoPinEdgeToSuperviewEdge(.Top)
        self.topTip.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.foodTitle.autoPinEdgeToSuperviewEdge(.Left, withInset: 20.0)
        self.foodTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.topTip, withOffset: 25.0)
        self.foodTitle.autoSetDimensionsToSize(CGSizeMake(self.scrollView.width - 40.0, 30.0))
        
        self.foodTitleUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.foodTitleUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 5.0)
        self.foodTitleUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.foodTitle)
        self.foodTitleUnderline.autoSetDimension(.Height, toSize: 5.0)
        
        self.priceName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.priceName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitleUnderline, withOffset: 10.0)
        self.priceName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.priceUnit.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.priceUnit.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceName)
        self.priceUnit.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
        
        self.priceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.priceUnit)
        self.priceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceName)
        self.priceValue.autoSetDimensionsToSize(CGSizeMake(30.0, 20.0))
        
        self.priceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceName, withOffset: 10.0)
        self.priceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.priceName)
        self.priceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.priceUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.amountName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.amountName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceUnderline, withOffset: 10.0)
        self.amountName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.plusBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.plusBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.amountName)
        self.plusBtn.autoSetDimensionsToSize(CGSizeMake(20.0, 20.0))
        
        self.amountValue.autoAlignAxis(.Horizontal, toSameAxisOfView: self.amountName)
        self.amountValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.plusBtn, withOffset: -10.0)
        self.amountValue.autoSetDimensionsToSize(CGSizeMake(20.0, 14.0))
        
        self.reduceBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.amountName)
        self.reduceBtn.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.amountValue, withOffset: -10.0)
        self.reduceBtn.autoSetDimensionsToSize(CGSizeMake(20.0, 20.0))
        
        self.amountUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.amountUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountName, withOffset: 10.0)
        self.amountUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.amountUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.totalPriceName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.totalPriceName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountUnderline, withOffset: 10.0)
        self.totalPriceName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.totalPriceValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.totalPriceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.totalPriceName)
        self.totalPriceValue.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
        
        self.totalPriceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.totalPriceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.totalPriceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceName, withOffset: 10.0)
        self.totalPriceUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        if !self.isLogin() {
            
            self.mobile.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.mobile.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline, withOffset: 10.0)
            self.mobile.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.5)
            self.mobile.autoSetDimension(.Height, toSize: 30.0)
            
            self.sendVerifyBtn.autoSetDimensionsToSize(CGSizeMake(80.0, 32.0))
            self.sendVerifyBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.sendVerifyBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.mobile, withOffset: 0.0)
            
            self.mobileUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.mobileUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.mobile, withOffset: 5.0)
            self.mobileUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.mobile)
            self.mobileUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.verifyCode.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.verifyCode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.mobileUnderline, withOffset: 10.0)
            self.verifyCode.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.verifyCode.autoSetDimension(.Height, toSize: 30.0)
            
            self.verifyCodeUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.verifyCodeUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.verifyCodeUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.verifyCode, withOffset: 5.0)
            self.verifyCodeUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.loginNote.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.loginNote.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.verifyCodeUnderline, withOffset: 10.0)
            self.loginNote.autoSetDimensionsToSize(CGSizeMake(214.0, 20.0))
            
            self.loginBtn.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.loginNote)
            self.loginBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.loginNote)
            self.loginBtn.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
            
        }
        else {
            
            self.mobileName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.mobileName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline, withOffset: 10.0)
            self.mobileName.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
            
            self.mobileNumber.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.mobileNumber.autoPinEdge(.Top, toEdge: .Top, ofView: self.mobileName)
            self.mobileNumber.autoSetDimensionsToSize(CGSizeMake(100.0, 20.0))
            
            self.mobileUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.mobileUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.mobileName, withOffset: 10.0)
            self.mobileUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.mobileUnderline.autoSetDimension(.Height, toSize: 3.0)
            
        }
        
        
        self.submitView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Top)
        self.submitView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
        
        self.submitBtn.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
        self.submitBtn.autoMatchDimension(.Width, toDimension: .Width, ofView: self.submitView, withMultiplier: 0.4)
        
        self.submitBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.submitBtn, withOffset: -1.0)
        self.submitBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.submitBtn, withOffset: -1.0)
        self.submitBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.submitBtn, withOffset: 2.0)
        self.submitBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.submitBtn, withOffset: 2.0)
        
        self.orderPriceValue.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.submitBtn)
        self.orderPriceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.submitBtn, withOffset: -40.0)
        self.orderPriceValue.autoSetDimensionsToSize(CGSizeMake(54.0, 22.0))
        
        self.orderPriceName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderPriceValue, withOffset: 10.0)
        self.orderPriceName.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.submitBtn)
        self.orderPriceName.autoSetDimensionsToSize(CGSizeMake(42.0, 20.0))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Functions
    
    func setupSubmitView() {
        
        self.submitBg.backgroundColor = UIColor.pumpkinColor()
        self.submitView.addSubview(self.submitBg)
        
        self.submitBtn.backgroundColor = UIColor.pumpkinColor()
        self.submitBtn.setTitle(VCAppLetor.StringLine.SubmitBtnTitle, forState: UIControlState.Normal)
        self.submitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.submitBtn.layer.borderWidth = 1.0
        self.submitBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.submitBtn.addTarget(self, action: "checkNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.submitView.addSubview(self.submitBtn)
        
        self.orderPriceName.text = VCAppLetor.StringLine.OrderPriceName
        self.orderPriceName.textAlignment = .Left
        self.orderPriceName.textColor = UIColor.orangeColor()
        self.orderPriceName.font = VCAppLetor.Font.NormalFont
        self.submitView.addSubview(self.orderPriceName)
        
        self.orderPriceValue.text = "118元"
        self.orderPriceValue.textAlignment = .Center
        self.orderPriceValue.textColor = UIColor.orangeColor()
        self.orderPriceValue.font = VCAppLetor.Font.XLarge
        self.submitView.addSubview(self.orderPriceValue)
        
        
        self.submitView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        
        let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
        topBorder.drawType = "GrayLine"
        topBorder.lineWidth = 1.0
        self.submitView.addSubview(topBorder)
        
        topBorder.autoSetDimension(.Height, toSize: 1.0)
        topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        self.view.addSubview(self.submitView)
    }
    
    func setupOrderView() {
        
        
        self.topTip.drawType = "SubmitTopTip"
        self.topTip.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        self.scrollView.addSubview(self.topTip)
        
        self.foodTitle.text = self.foodItem?.title
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.textAlignment = .Left
        self.foodTitle.textColor = UIColor.blackColor()
        self.scrollView.addSubview(self.foodTitle)
        
        self.foodTitleUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.foodTitleUnderline)
        
        self.priceName.text = VCAppLetor.StringLine.PriceName
        self.priceName.textAlignment = .Left
        self.priceName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.priceName)
        
        self.priceValue.text = "118"
        self.priceValue.textAlignment = .Right
        self.priceValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.priceValue)
        
        self.priceUnit.text = "元/2位"
        self.priceUnit.textAlignment = .Right
        self.priceUnit.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceUnit.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.priceUnit)
        
        self.priceUnderline.drawType = "GrayLine"
        self.priceUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.priceUnderline)
        
        self.amountName.text = VCAppLetor.StringLine.AmountName
        self.amountName.textAlignment = .Left
        self.amountName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.amountName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountName)
        
        self.reduceBtn.setTitle("-", forState: .Normal)
        self.reduceBtn.setTitle("-", forState: UIControlState.Disabled)
        self.reduceBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        self.reduceBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.reduceBtn.enabled = false
        self.reduceBtn.titleEdgeInsets = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)
        self.reduceBtn.titleLabel?.font = VCAppLetor.Font.NormalFont
        self.reduceBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.reduceBtn.layer.borderWidth = 1.0
        self.reduceBtn.addTarget(self, action: "reduceAmount", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.reduceBtn)
        
        self.amountValue.text = "1"
        self.amountValue.textAlignment = .Center
        self.amountValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.amountValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountValue)
        
        self.plusBtn.setTitle("+", forState: .Normal)
        self.plusBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.plusBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.plusBtn.titleEdgeInsets = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)
        self.plusBtn.titleLabel?.font = VCAppLetor.Font.NormalFont
        self.plusBtn.layer.borderWidth = 1.0
        self.plusBtn.addTarget(self, action: "plusAmount", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.plusBtn)
        
        self.amountUnderline.drawType = "GrayLine"
        self.amountUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.amountUnderline)
        
        self.totalPriceName.text = VCAppLetor.StringLine.TotalPriceName
        self.totalPriceName.textAlignment = .Left
        self.totalPriceName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.totalPriceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.totalPriceName)
        
        self.totalPriceValue.text = "\((self.priceValue.text! as NSString).floatValue * (self.amountValue.text! as NSString).floatValue)" + "元"
        self.totalPriceValue.textAlignment = .Left
        self.totalPriceValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.totalPriceValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.totalPriceValue)
        
        self.totalPriceUnderline.drawType = "GrayLine"
        self.totalPriceUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.totalPriceUnderline)
        
        if !self.isLogin() {
            
            self.mobile.placeholder = VCAppLetor.StringLine.MobilePlease
            self.mobile.clearButtonMode = .WhileEditing
            self.mobile.keyboardType = UIKeyboardType.PhonePad
            self.mobile.textAlignment = .Left
            self.mobile.font = VCAppLetor.Font.BigFont
            self.mobile.delegate = self
            self.scrollView.addSubview(self.mobile)
            
            self.mobileShaker = AFViewShaker(view: self.mobile)
            
            self.sendVerifyBtn.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
            self.sendVerifyBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
            self.sendVerifyBtn.titleLabel?.font = VCAppLetor.Font.SmallFont
            self.sendVerifyBtn.titleLabel?.textAlignment = .Center
            self.sendVerifyBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.sendVerifyBtn.layer.borderWidth = 1.0
            self.sendVerifyBtn.addTarget(self, action: "checkMobile", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(self.sendVerifyBtn)
            
            self.mobileUnderline.drawType = "GrayLine"
            self.mobileUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.mobileUnderline)
            
            self.verifyCode.placeholder = VCAppLetor.StringLine.InputVerifyCode
            self.verifyCode.clearButtonMode = .WhileEditing
            self.verifyCode.keyboardType = UIKeyboardType.PhonePad
            self.verifyCode.textAlignment = .Left
            self.verifyCode.font = VCAppLetor.Font.BigFont
            self.verifyCode.delegate = self
            self.scrollView.addSubview(self.verifyCode)
            
            self.verifyCodeShaker = AFViewShaker(view: self.verifyCode)
            
            self.verifyCodeUnderline.drawType = "GrayLine"
            self.verifyCodeUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.verifyCodeUnderline)
            
            self.loginNote.text = VCAppLetor.StringLine.LoginWithCoupon
            self.loginNote.textAlignment = .Left
            self.loginNote.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.loginNote.font = VCAppLetor.Font.SmallFont
            self.scrollView.addSubview(self.loginNote)
            
            self.loginBtn.setTitle(VCAppLetor.StringLine.LoginNow, forState: .Normal)
            self.loginBtn.setTitleColor(UIColor.pumpkinColor(), forState: .Normal)
            self.loginBtn.titleLabel?.font = VCAppLetor.Font.SmallFont
            self.loginBtn.layer.borderWidth = 0.0
            self.loginBtn.addTarget(self, action: "userLogin", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(self.loginBtn)
        }
        else {
            
            self.mobileName.text = VCAppLetor.StringLine.MobileName
            self.mobileName.textAlignment = .Left
            self.mobileName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.mobileName.font = VCAppLetor.Font.NormalFont
            self.scrollView.addSubview(self.mobileName)
            
            var phoneNumber: String = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
            var range = Range<String.Index>(start: advance(phoneNumber.startIndex, 3),end: advance(phoneNumber.endIndex, -4))
            phoneNumber.replaceRange(range, with: "••••")
            
            self.mobileNumber.text = phoneNumber
            self.mobileNumber.textAlignment = .Right
            self.mobileNumber.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.mobileNumber.font = VCAppLetor.Font.NormalFont
            self.scrollView.addSubview(self.mobileNumber)
            
            self.mobileUnderline.drawType = "GrayLine"
            self.mobileUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.mobileUnderline)
        }
        
        
        
        self.view.addSubview(self.scrollView)
    }
    
    
    func isLogin() -> Bool {
        
        return CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String != "0"
    }
    
    func checkMobile() {
        // Check mobile phone number
        let mobile: String = self.mobile.text as String
        self.disableSending()
        
        if (mobile == "") {
            
            self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileCannotEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            })
        }
        else if (!self.isMobile(mobile)) {
            self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            })
        }
        else {
            
            self.mobile.resignFirstResponder()
            
            self.sendOrderingAuthCode(mobile)
            
//            Alamofire.request(VCheckGo.Router.ValidateMemberInfo(VCheckGo.ValidateType.Mobile, mobile)).validate().responseSwiftyJSON({
//                (_, _, JSON, error) -> Void in
//                
//                let json = JSON
//                
//                if (error == nil) {
//                    
//                    if json["status"]["succeed"].string == "0" && json["status"]["error_code"].string == VCAppLetor.ErrorCode.MobileAlreadyExist {
//                        self.sendRegAuthCode(mobile)
//                    }
//                    else {
//                        self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
//                            RKDropdownAlert.title(VCAppLetor.StringLine.MobileNotExist, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
//                        })
//                    }
//                    
//                    
//                }
//                else {
//                    println("ERROR @ Validate member info request : \(error?.localizedDescription)")
//                }
//                
//                self.mobile.resignFirstResponder()
//                hud.hide(true)
//                
//            })
            
            
        }
        
    }
    
    func disableSending() {
        
        // disable sending button while processing
        self.sendVerifyBtn.enabled = false
        self.sendVerifyBtn.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        self.sendVerifyBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func enableSending() {
        self.sendVerifyBtn.enabled = true
        self.sendVerifyBtn.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
        self.sendVerifyBtn.backgroundColor = UIColor.whiteColor()
    }
    
    func startCounting() {
        self.remainingSecond = VCAppLetor.ConstValue.SMSRemainingSeconds
        self.isCounting = !self.isCounting
    }
    
    func sendOrderingAuthCode(mobile: String) {
        
        let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = VCAppLetor.StringLine.VerifyCodeInProgress
        
        let validateCode: String = (mobile + VCAppLetor.StringLine.SaltKey).md5
        println("code: \(validateCode)")
        
        Alamofire.request(VCheckGo.Router.GetVerifyCode(mobile, validateCode)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    self.startCounting()
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobile, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.VerifyCode, data: json["data"]["verify_code"].string, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.SaltCode, data: json["data"]["code"].string, namespace: "member")
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendDone, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                }
                
                hud.hide(true)
            }
            else {
                println("ERROR @ Request for sending varify code : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendFail, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            }
        })
        
    }
    
    func updateTimer(timer: NSTimer) {
        
        self.remainingSecond -= 1
        
        if self.remainingSecond <= 0 {
            self.isCounting = !self.isCounting
            
            self.sendVerifyBtn.enabled = true
            self.sendVerifyBtn.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
            self.sendVerifyBtn.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func reduceAmount() {
        
        var amount: Int = (self.amountValue.text! as NSString).integerValue
        if amount > 1 {
            self.amountValue.text = "\(amount-1)"
            
        }
        
        if amount == 2 {
            self.reduceBtn.enabled = false
        }
    }
    
    func plusAmount() {
        
        var amount: Int = (self.amountValue.text! as NSString).integerValue
        self.amountValue.text = "\(amount+1)"
        
        if amount >= 1 {
            self.reduceBtn.enabled = true
        }
    }
    
    func isMobile(mobile: String) -> Bool {
        
        let mobileRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
        let mobileTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobileTest.evaluateWithObject(mobile)
    }
    
    func userLogin() {
        
        let userLoginController: VCMemberLoginViewController = VCMemberLoginViewController()
        userLoginController.modalPresentationStyle = .Popover
        userLoginController.modalTransitionStyle = .CoverVertical
        userLoginController.popoverPresentationController?.delegate = self
        userLoginController.delegate = self
//        userLoginController.userPanelController = self
        presentViewController(userLoginController, animated: true, completion: nil)
    }
    
    func updateSettings(tokenStr: String, currentMid: String) {
        
        // Cache token
        
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = tokenStr
                
                println("update token after login \(token.value)")
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: tokenStr, namespace: "token")
            
            let t = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            println("After Login: token=" + t)
        }
        
        // update local data
        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                isLogin.sid = "\(NSDate())"
                isLogin.value = "1"
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update isLogin value @ loginWithToken : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: true, namespace: "member")
                    }
            })
        }
        
        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                cMid.sid = "\(NSDate())"
                cMid.value = currentMid
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update currentMid value @ loginWithToken : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: currentMid, namespace: "member")
                    }
            })
        }
        
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInBackground({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.PhoneReg
                
                }, completion: { error -> Void in
                    
                    if (error != nil) {
                        println("ERROR @ update loginType value @ loginWithToken : \(error?.localizedDescription)")
                    }
                    else {
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.PhoneReg, namespace: "member")
                    }
            })
        }
    }
    
    func checkNowAction() {
        
        if !self.isLogin() { // Not login? Login OR Register with mobile&verify code
            
            self.mobile.resignFirstResponder()
            self.verifyCode.resignFirstResponder()
            
            let verifyCodeText: String = self.verifyCode.text
            let sendingCode = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.VerifyCode, namespace: "member")?.data as? String ?? ""
            
            if verifyCodeText == "" || verifyCodeText != sendingCode {
                self.verifyCodeShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeWrong, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else {
                
                let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Determinate
                hud.labelText = VCAppLetor.StringLine.SubmitOrderInProgress
                
                let mobileText = self.mobile.text
                let code = (CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.SaltCode, namespace: "member")?.data as! String + VCAppLetor.StringLine.SaltKey).md5
                
                Alamofire.request(VCheckGo.Router.QuickLogin(mobileText, code)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"] == "1" {
                            
                            self.memberDidSigninSuccess(json["data"]["member_id"].string!, token: json["data"]["token"].string!)
                            self.submitOrder(hud)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ Request for QuickLogin : \(error?.localizedDescription)")
                    }
                })
                
                
            }
        }
        else {
            
            let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Determinate
            hud.labelText = VCAppLetor.StringLine.SubmitOrderInProgress
            
            self.submitOrder(hud)
            
        }
        
    }
    
    func submitOrder(hud: MBProgressHUD) {
        
        hud.hide(true)
        
        // Transfer to payment page
        let paymentViewController: VCPayNowViewController = VCPayNowViewController()
        paymentViewController.parentNav = self.parentNav
        paymentViewController.foodItem = self.foodItem
        self.parentNav.showViewController(paymentViewController, sender: self)
    }
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        
        self.enableSending()
        return true
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    
    
    // MARK: - UITextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        IHKeyboardAvoiding.setAvoidingView(self.view)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        IHKeyboardAvoiding.setAvoidingView(self.view)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    
    // MARK: - Member register delegate
    
    func memberDidFinishRegister(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    // Member info
                    let midString = json["data"]["member_info"]["member_id"].string!
                    let emailString = json["data"]["member_info"]["email"].string!
                    let mobileString = json["data"]["member_info"]["mobile"].string!
                    let nicknameString = json["data"]["member_info"]["member_name"].string!
                    let iconString = json["data"]["member_info"]["icon_image"]["thumb"].string!
                    
                    // Listing Info
                    //                    let orderCount = json["data"]["order_info"]["order_total_count"].string!
                    // Collection Info
                    //                    let collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    // Coupon Info
                    //                    let couponCount = json["data"]["coupon_info"]["coupon_total_count"].string!
                    
                    // Get member info and refresh userinterface
                    BreezeStore.saveInMain({ (contextType) -> Void in
                        
                        let member = Member.createInContextOfType(contextType) as! Member
                        
                        member.mid = midString
                        member.email = emailString
                        member.phone = mobileString
                        member.nickname = nicknameString
                        member.iconURL = iconString
                        member.lastLog = NSDate()
                        member.token = token
                        
                    })
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                    
                    
                    self.resetOrderPageLayout()
                    
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
        
        // Get member info which just finish Signing In
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let midString = json["data"]["member_info"]["member_id"].string!
                    let emailString = json["data"]["member_info"]["email"].string!
                    let mobileString = json["data"]["member_info"]["mobile"].string!
                    let nicknameString = json["data"]["member_info"]["member_name"].string!
                    let iconString = json["data"]["member_info"]["icon_image"]["thumb"].string!
                    
                    // Listing Info
                    //                    let orderCount = json["data"]["order_info"]["order_total_count"].string!
                    // Collection Info
                    //                    let collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    // Coupon Info
                    //                    let couponCount = json["data"]["coupon_info"]["coupon_total_count"].string!
                    
                    if let member = Member.findFirst(attribute: "mid", value: midString, contextType: BreezeContextType.Main) as? Member {
                        
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            member.email = emailString
                            member.phone = mobileString
                            member.nickname = nicknameString
                            member.iconURL = iconString
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                        
                        // update local data
                        self.updateSettings(token, currentMid: mid)
                        
                        // setup cache & user panel interface
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                        
                        self.resetOrderPageLayout()
                        
                    }
                    else { // Member login for the first time without register on the device
                        // Get member info and refresh userinterface
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            let member = Member.createInContextOfType(contextType) as! Member
                            
                            member.mid = midString
                            member.email = emailString
                            member.phone = mobileString
                            member.nickname = nicknameString
                            member.iconURL = iconString
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                        
                        // update local data
                        self.updateSettings(token, currentMid: mid)
                        
                        // setup cache & user panel interface
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Nickname, data: nicknameString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Email, data: emailString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobileString, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Icon, data: iconString, namespace: "member")
                        
                        self.resetOrderPageLayout()
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
    
    
    func resetOrderPageLayout() {
        
        self.mobile.removeFromSuperview()
        self.sendVerifyBtn.removeFromSuperview()
        self.mobileUnderline.removeFromSuperview()
        self.verifyCode.removeFromSuperview()
        self.verifyCodeUnderline.removeFromSuperview()
        self.loginNote.removeFromSuperview()
        self.loginBtn.removeFromSuperview()
        
        self.mobileName.text = VCAppLetor.StringLine.MobileName
        self.mobileName.textAlignment = .Left
        self.mobileName.textColor = UIColor.blackColor()
        self.mobileName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.mobileName)
        
        var phoneNumber: String = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
        var range = Range<String.Index>(start: advance(phoneNumber.startIndex, 3),end: advance(phoneNumber.endIndex, -4))
        phoneNumber.replaceRange(range, with: "••••")
        
        self.mobileNumber.text = phoneNumber
        self.mobileNumber.textAlignment = .Right
        self.mobileNumber.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.mobileNumber.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.mobileNumber)
        
        self.mobileUnderline.drawType = "GrayLine"
        self.mobileUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.mobileUnderline)
        
        self.view.setNeedsUpdateConstraints()
    }
    
}


