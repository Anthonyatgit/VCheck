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
import DKChainableAnimationKit


class VCCheckNowViewController: VCBaseViewController, UIScrollViewDelegate, UITextFieldDelegate, RKDropdownAlertDelegate, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate {
    
    var foodItem: FoodItem!
    var foodInfo: FoodInfo!
    
    var parentNav: UINavigationController!
    var foodDetailVC: VCBaseViewController!
    
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
    
    var orderItemCount: Int = 1 {
        willSet(newValue) {
            
            self.amountValue.text = "\(newValue)"
            
            let price: CGFloat = CGFloat((self.foodInfo.price! as NSString).floatValue)
            let count: CGFloat = CGFloat(("\(newValue)" as NSString).floatValue)
            self.totalPriceValue.text = "\(price * count)\(self.foodInfo.priceUnit!)"
            
            self.orderPriceValue.text = "\(price * count)\(self.foodInfo.priceUnit!)"
        }
    }
    
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
    
    var keyboardHeight: CGFloat = 0
    
    var hud: MBProgressHUD!
    
    var tapGueture: UITapGestureRecognizer?
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.CheckNowTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        self.setupOrderView()
        
        self.setupSubmitView()
        
        self.updateViewConstraints()
        
        self.tapGueture = UITapGestureRecognizer(target: self, action: "viewTaped:")
        self.tapGueture?.numberOfTapsRequired = 1
        self.tapGueture?.numberOfTouchesRequired = 1
        self.scrollView.addGestureRecognizer(self.tapGueture!)
        
        self.registerForKeyboardNotifications()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        IHKeyboardAvoiding.setAvoidingView(self.view, withTriggerView: self.verifyCode)
        IHKeyboardAvoiding.setPaddingForCurrentAvoidingView(140)
        IHKeyboardAvoiding.setBuffer(140)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        self.scrollView.contentSize.height = self.scrollView.height - VCAppLetor.ConstValue.CheckNowBarHeight
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
        self.priceName.autoSetDimension(.Height, toSize: 20.0)
        
        self.priceUnit.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.priceUnit.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceName)
        //        self.priceUnit.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.priceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.priceUnit)
        self.priceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceName)
        //        self.priceValue.autoSetDimensionsToSize(CGSizeMake(120.0, 20.0))
        
        self.priceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceName, withOffset: 10.0)
        self.priceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.priceName)
        self.priceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.priceUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.amountName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.amountName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceUnderline, withOffset: 10.0)
        self.amountName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.plusBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.plusBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.amountName)
        self.plusBtn.autoSetDimensionsToSize(CGSizeMake(22.0, 22.0))
        
        self.amountValue.autoAlignAxis(.Horizontal, toSameAxisOfView: self.amountName)
        self.amountValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.plusBtn, withOffset: -14.0)
        self.amountValue.autoSetDimensionsToSize(CGSizeMake(20.0, 14.0))
        
        self.reduceBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.amountName)
        self.reduceBtn.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.amountValue, withOffset: -14.0)
        self.reduceBtn.autoSetDimensionsToSize(CGSizeMake(22.0, 22.0))
        
        self.amountUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.amountUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountName, withOffset: 10.0)
        self.amountUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.amountUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.totalPriceName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.totalPriceName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountUnderline, withOffset: 10.0)
        self.totalPriceName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
        
        self.totalPriceValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.totalPriceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.totalPriceName)
        //        self.totalPriceValue.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
        
        self.totalPriceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.totalPriceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.totalPriceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceName, withOffset: 10.0)
        self.totalPriceUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        if !self.isLogin() {
            
            self.mobile.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.mobile.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline, withOffset: 10.0)
            self.mobile.autoSetDimension(.Width, toSize: self.view.width - 40 - 80 - 10)
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
        self.orderPriceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.submitBtn, withOffset: -20.0)
        //        self.orderPriceValue.autoSetDimensionsToSize(CGSizeMake(164.0, 22.0))
        
        self.orderPriceName.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.submitBtn)
        self.orderPriceName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderPriceValue, withOffset: -10.0)
        self.orderPriceName.autoSetDimensionsToSize(CGSizeMake(40.0, 18.0))
        
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
        self.orderPriceName.textAlignment = .Right
        self.orderPriceName.textColor = UIColor.orangeColor()
        self.orderPriceName.font = VCAppLetor.Font.NormalFont
        self.submitView.addSubview(self.orderPriceName)
        
        self.orderPriceValue.text = round_price(self.foodInfo.price!) + "\(self.foodInfo.priceUnit!)"
        self.orderPriceValue.textAlignment = .Right
        self.orderPriceValue.textColor = UIColor.orangeColor()
        self.orderPriceValue.font = VCAppLetor.Font.Light
        self.orderPriceValue.sizeToFit()
        self.submitView.addSubview(self.orderPriceValue)
        
        
        self.submitView.backgroundColor = UIColor.cloudsColor(alpha: 1.0)
        
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
        self.topTip.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1)
        self.scrollView.addSubview(self.topTip)
        
        self.foodTitle.text = self.foodInfo.menuName!
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.textAlignment = .Left
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.scrollView.addSubview(self.foodTitle)
        
        self.foodTitleUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.foodTitleUnderline)
        
        self.priceName.text = VCAppLetor.StringLine.PriceName
        self.priceName.textAlignment = .Left
        self.priceName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.priceName)
        
        self.priceValue.text = round_price(self.foodInfo.price!)
        self.priceValue.textAlignment = .Right
        self.priceValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceValue.font = VCAppLetor.Font.LightSmall
        self.priceValue.sizeToFit()
        self.scrollView.addSubview(self.priceValue)
        
        self.priceUnit.text = "\(self.foodInfo.priceUnit!)/\(self.foodInfo.unit!)"
        self.priceUnit.textAlignment = .Right
        self.priceUnit.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.priceUnit.font = VCAppLetor.Font.NormalFont
        self.priceUnit.sizeToFit()
        self.scrollView.addSubview(self.priceUnit)
        
        self.priceUnderline.drawType = "GrayLine"
        self.priceUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.priceUnderline)
        
        self.amountName.text = VCAppLetor.StringLine.AmountName
        self.amountName.textAlignment = .Left
        self.amountName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.amountName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountName)
        
        self.reduceBtn.setTitle("-", forState: .Normal)
        self.reduceBtn.setTitle("-", forState: .Disabled)
        self.reduceBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        self.reduceBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.reduceBtn.enabled = false
        self.reduceBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 1.0, 1.0)
        self.reduceBtn.titleLabel?.font = VCAppLetor.Font.NormalFont
        self.reduceBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.reduceBtn.layer.borderWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.reduceBtn.addTarget(self, action: "reduceAmount", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.reduceBtn)
        
        self.amountValue.text = "\(self.orderItemCount)"
        self.amountValue.textAlignment = .Center
        self.amountValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.amountValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountValue)
        
        self.plusBtn.setTitle("+", forState: .Normal)
        self.plusBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.plusBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.plusBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 1.0, 1.0)
        self.plusBtn.titleLabel?.font = VCAppLetor.Font.NormalFont
        self.plusBtn.layer.borderWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.plusBtn.addTarget(self, action: "plusAmount", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.plusBtn)
        
        self.amountUnderline.drawType = "GrayLine"
        self.amountUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.amountUnderline)
        
        self.totalPriceName.text = VCAppLetor.StringLine.TotalPriceName
        self.totalPriceName.textAlignment = .Left
        self.totalPriceName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.totalPriceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.totalPriceName)
        
        self.totalPriceValue.text = round_price(self.priceValue.text!) + "\(self.foodInfo.priceUnit!)"
        self.totalPriceValue.textAlignment = .Left
        self.totalPriceValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.totalPriceValue.font = VCAppLetor.Font.LightSmall
        self.totalPriceValue.sizeToFit()
        self.scrollView.addSubview(self.totalPriceValue)
        
        self.totalPriceUnderline.drawType = "GrayLine"
        self.totalPriceUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.totalPriceUnderline)
        
        if !self.isLogin() {
            
            self.mobile.placeholder = VCAppLetor.StringLine.MobilePlease
            self.mobile.clearButtonMode = .WhileEditing
            self.mobile.keyboardType = UIKeyboardType.DecimalPad
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
            self.sendVerifyBtn.layer.borderWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.sendVerifyBtn.addTarget(self, action: "checkMobile", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(self.sendVerifyBtn)
            
            self.mobileUnderline.drawType = "GrayLine"
            self.mobileUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.scrollView.addSubview(self.mobileUnderline)
            
            self.verifyCode.placeholder = VCAppLetor.StringLine.InputVerifyCode
            self.verifyCode.clearButtonMode = .WhileEditing
            self.verifyCode.keyboardType = UIKeyboardType.DecimalPad
            self.verifyCode.textAlignment = .Left
            self.verifyCode.font = VCAppLetor.Font.BigFont
            self.verifyCode.delegate = self
            self.scrollView.addSubview(self.verifyCode)
            
            self.verifyCodeShaker = AFViewShaker(view: self.verifyCode)
            
            self.verifyCodeUnderline.drawType = "GrayLine"
            self.verifyCodeUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.scrollView.addSubview(self.verifyCodeUnderline)
            
            self.loginNote.text = VCAppLetor.StringLine.LoginWithCoupon
            self.loginNote.textAlignment = .Left
            self.loginNote.textColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            self.loginNote.font = VCAppLetor.Font.SmallFont
            self.scrollView.addSubview(self.loginNote)
            
            self.loginBtn.setTitle(VCAppLetor.StringLine.LoginNow, forState: .Normal)
            self.loginBtn.setTitleColor(UIColor.pumpkinColor(), forState: .Normal)
            self.loginBtn.titleLabel?.font = VCAppLetor.Font.SmallFont
            self.loginBtn.layer.borderWidth = 0.0
            self.loginBtn.hidden = true
            self.loginBtn.addTarget(self, action: "userLogin", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(self.loginBtn)
        }
        else {
            
            self.mobileName.text = VCAppLetor.StringLine.MobileName
            self.mobileName.textAlignment = .Left
            self.mobileName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.mobileName.font = VCAppLetor.Font.NormalFont
            self.scrollView.addSubview(self.mobileName)
            
            var phoneNumber: String = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo).mobile!
            var range = Range<String.Index>(start: advance(phoneNumber.startIndex, 3),end: advance(phoneNumber.endIndex, -4))
            phoneNumber.replaceRange(range, with: "••••")
            
            self.mobileNumber.text = phoneNumber
            self.mobileNumber.textAlignment = .Right
            self.mobileNumber.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.mobileNumber.font = VCAppLetor.Font.LightSmall
            self.scrollView.addSubview(self.mobileNumber)
            
            self.mobileUnderline.drawType = "GrayLine"
            self.mobileUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.scrollView.addSubview(self.mobileUnderline)
        }
        
        
        
        self.view.addSubview(self.scrollView)
    }
    
    
    func isLogin() -> Bool {
        
        return CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token")
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
        
        if self.orderItemCount == 2 {
            self.reduceBtn.enabled = false
        }
        
        if self.orderItemCount > 1 {
            
            self.orderItemCount -= 1
        }
        
        
    }
    
    func plusAmount() {
        
        if self.orderItemCount == 1 {
            self.reduceBtn.enabled = true
        }
        
        self.orderItemCount += 1
        
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
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                isLogin.sid = "\(NSDate())"
                isLogin.value = "1"
                
            })
            
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: true, namespace: "member")
        }
        
        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                cMid.sid = "\(NSDate())"
                cMid.value = currentMid
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: currentMid, namespace: "member")
        }
        
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.PhoneReg
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.PhoneReg, namespace: "member")
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
                
                let mobileText = self.mobile.text
                let code = (CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.SaltCode, namespace: "member")?.data as! String + VCAppLetor.StringLine.SaltKey).md5
                
                Alamofire.request(VCheckGo.Router.QuickLogin(mobileText, code)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"] == "1" {
                            
                            
                            self.quickLogin(json["data"]["member_id"].string!, token: json["data"]["token"].string!)
                            
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
            
            self.checkOrderInfo()
            
        }
        
    }
    
    func submitOrder() {
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        self.hud.labelText = VCAppLetor.StringLine.SubmitOrderInProgress
        
        // Update cart
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let editType = VCheckGo.EditCartType.edit
        let menuId = self.foodInfo.menuId!
        let count = "\(self.orderItemCount)"
        let articleId = "\(self.foodInfo.id)"
        let mobileString = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo).mobile!
        
        Alamofire.request(VCheckGo.Router.EditCart(memberId, editType, menuId, count, articleId, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    // Add Order
                    Alamofire.request(VCheckGo.Router.AddOrder(memberId, token)).validate().responseSwiftyJSON({
                        (_, _, JSON, error) -> Void in
                        
                        if error == nil {
                            
                            let json = JSON
                            
                            if json["status"]["succeed"].string! == "1" {
                                
                                let orderId = json["data"]["order_info"]["order_id"].string!
                                let orderNo = json["data"]["order_info"]["order_no"].string!
                                let newOrder: OrderInfo = OrderInfo(id: orderId, no: orderNo)
                                
                                newOrder.title = json["data"]["order_info"]["menu_info"]["menu_name"].string!
                                newOrder.pricePU = json["data"]["order_info"]["menu_info"]["price"]["special_price"].string!
                                newOrder.priceUnit = json["data"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                newOrder.createDate = dateFormatter.dateFromString(json["data"]["order_info"]["create_date"].string!)
                                newOrder.createByMobile = mobileString
                                newOrder.totalPrice = json["data"]["order_info"]["total_price"]["special_price"].string!
                                newOrder.originalTotalPrice = json["data"]["order_info"]["total_price"]["original_price"].string!
                                newOrder.menuId = json["data"]["order_info"]["menu_info"]["menu_id"].string!
                                newOrder.menuTitle = json["data"]["order_info"]["menu_info"]["menu_name"].string!
                                newOrder.menuUnit = json["data"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                                newOrder.itemCount = json["data"]["order_info"]["menu_info"]["count"].string!
                                newOrder.foodId = "\(self.foodInfo.id)"
                                newOrder.orderImageURL = "\(self.foodInfo.foodImage!)"
                                
                                newOrder.orderType = json["data"]["order_info"]["order_type"].string!
                                newOrder.typeDescription = json["data"]["order_info"]["order_type_description"].string!
                                
                                newOrder.voucherId = json["data"]["order_info"]["voucher_info"]["voucher_member_id"].string!
                                newOrder.voucherName = json["data"]["order_info"]["voucher_info"]["voucher_name"].string!
                                newOrder.voucherPrice = json["data"]["order_info"]["voucher_info"]["discount"].string!
                                
                                newOrder.exCode = json["data"]["order_info"]["consume_info"]["consume_code"].string!
                                
                                let dateFM: NSDateFormatter = NSDateFormatter()
                                dateFM.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                
                                newOrder.exCodeExpireDate = dateFM.dateFromString(json["data"]["order_info"]["consume_info"]["exprie_date"].string!)
                                newOrder.exCodeUseDate = json["data"]["order_info"]["consume_info"]["consume_date"].string!
                                
                                newOrder.isReturn = json["data"]["order_info"]["is_return"].string!
                                
                                println("newOrder voucherId: \(newOrder.voucherId) | name: \(newOrder.voucherName)")
                                
                                //                                // Cache member order session, CAN NOT submit order with same menu until the order session complete (Deleted OR Paid)
                                //                                let orderSessionMenus = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.orderSessionMenuIds, namespace: "order")?.data as? NSMutableArray
                                //                                if orderSessionMenus != nil {
                                //
                                //                                    orderSessionMenus?.addObject(menuId)
                                //                                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.orderSessionMenuIds, data: orderSessionMenus, namespace: "order")
                                //
                                //                                    let orderSessionOrderObjs = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.orderSessionOrderObjs, namespace: "order")?.data as? NSMutableArray
                                //
                                //                                    if orderSessionOrderObjs != nil {
                                //                                        orderSessionOrderObjs?.addObject(newOrder)
                                //                                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.orderSessionOrderObjs, data: orderSessionOrderObjs, namespace: "order")
                                //                                    }
                                //                                    else {
                                //                                        println("Order Session data missing! CAN NOT pair menus")
                                //                                    }
                                //
                                //                                }
                                //                                else {
                                //
                                //                                    let menus: NSMutableArray = NSMutableArray()
                                //
                                //                                    menus.addObject(menuId)
                                //                                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.orderSessionMenuIds, data: menus, namespace: "order")
                                //
                                //                                    let orders: NSMutableArray = NSMutableArray()
                                //
                                //                                    orders.addObject(newOrder)
                                //                                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.orderSessionOrderObjs, data: orders, namespace: "order")
                                //                                }
                                
                                
                                self.hud.hide(true)
                                
                                // Transfer to payment page
                                let paymentVC: VCPayNowViewController = VCPayNowViewController()
                                paymentVC.parentNav = self.parentNav
                                paymentVC.foodDetailVC = self.foodDetailVC
                                paymentVC.orderInfo = newOrder
                                self.parentNav.showViewController(paymentVC, sender: self)
                                
                            }
                            else {
                                RKDropdownAlert.title(json["status"]["error_desc"].string!+"[AddOrder]", backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                self.hud.hide(true)
                            }
                            
                        }
                        else {
                            println("ERROR @ Request for [Add Order] : \(error?.localizedDescription)")
                            RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            self.hud.hide(true)
                        }
                    })
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!+"[EditCart]", backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    self.hud.hide(true)
                }
                
                
            }
            else {
                println("ERROR @ Request for [Edit Cart] : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                self.hud.hide(true)
            }
            
        })
        
        
    }
    
    func viewTaped(tap: UITapGestureRecognizer) {
        
        self.mobile.resignFirstResponder()
        self.verifyCode.resignFirstResponder()
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
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Keyboard Notification
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasHide:", name: UIKeyboardDidHideNotification, object: nil)
        
    }
    
    func keyboardWasShow(notification: NSNotification) {
        
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.keyboardHeight = keyboardFrame.height
        
        self.submitView.animation.moveY(-self.keyboardHeight).animate(0.01)
    }
    
    func keyboardWasHide(notification: NSNotification) {
        
        self.keyboardHeight = 0
        self.submitView.animation.moveY(self.keyboardHeight).animate(0.01)
    }
    
    
    // MARK: - Member register delegate
    
    func memberDidFinishRegister(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                    
                    
                    memberInfo.email = json["data"]["member_info"]["email"].string!
                    memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                    memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                    memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                    
                    // Listing Info
                    memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                    memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                    memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                    memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                    
                    // Share Info
                    memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                    memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                    memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                    memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                    memberInfo.shareURL = json["data"]["share_info"]["share_url"].string!
                    
                    memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                    memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                    memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                    memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                    
                    memberInfo.bindWechat = json["data"]["thirdpart_info"]["weixin_bind"].string!
                    memberInfo.bindWeibo = json["data"]["thirdpart_info"]["weibo_bind"].string!
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    // Get member info and refresh userinterface
                    BreezeStore.saveInMain({ (contextType) -> Void in
                        
                        let member = Member.createInContextOfType(contextType) as! Member
                        
                        member.mid = mid
                        member.email = memberInfo.email!
                        member.phone = memberInfo.mobile!
                        member.nickname = memberInfo.nickname!
                        member.iconURL = memberInfo.icon!
                        member.lastLog = NSDate()
                        member.token = token
                        
                    })
                    
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                    
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
    
    func memberDidSigninWithWechatSuccess(mid: String, token: String) {
        
    }
    
    func memberDidSigninSuccess(mid: String, token: String) {
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        // Get member info which just finish Signing In
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string == "1" {
                        
                        let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                        
                        memberInfo.email = json["data"]["member_info"]["email"].string!
                        memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                        memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                        memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                        
                        // Listing Info
                        memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                        memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                        memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                        memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                        memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                        
                        // Share Info
                        memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                        memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                        memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                        memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                        memberInfo.shareURL = json["data"]["share_info"]["share_url"].string!
                        
                        memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                        memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                        memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                        memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                        
                        
                        memberInfo.bindWechat = json["data"]["thirdpart_info"]["weixin_bind"].string!
                        memberInfo.bindWeibo = json["data"]["thirdpart_info"]["weibo_bind"].string!
                        
                        // update local data
                        self.updateSettings(token, currentMid: mid)
                        
                        if let member = Member.findFirst(attribute: "mid", value: memberInfo.memberId, contextType: BreezeContextType.Main) as? Member {
                            
                            BreezeStore.saveInMain({ (contextType) -> Void in
                                
                                member.email = memberInfo.email!
                                member.phone = memberInfo.mobile!
                                member.nickname = memberInfo.nickname!
                                member.iconURL = memberInfo.icon!
                                member.lastLog = NSDate()
                                member.token = token
                                
                            })
                        }
                        else { // Member login for the first time without register on the device
                            // Get member info and refresh userinterface
                            BreezeStore.saveInMain({ (contextType) -> Void in
                                
                                let member = Member.createInContextOfType(contextType) as! Member
                                
                                member.mid = memberInfo.memberId
                                member.email = memberInfo.email!
                                member.phone = memberInfo.mobile!
                                member.nickname = memberInfo.nickname!
                                member.iconURL = memberInfo.icon!
                                member.lastLog = NSDate()
                                member.token = token
                                
                            })
                            
                        }
                        
                        // Push user device token
                        pushDeviceToken(VCheckGo.PushDeviceType.add)
                        
                        
                        // setup cache & user panel interface
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                        
                        self.resetOrderPageLayout()
                        self.checkOrderInfo()
                    }
                    else {
                        self.hud.hide(true)
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                }
                else {
                    self.hud.hide(true)
                    println("ERROR @ Request for member info : \(error?.localizedDescription)")
                }
            })
        })
    }
    
    
    func quickLogin(mid: String, token: String) {
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        // Get member info which just finish Signing In
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string == "1" {
                        
                        let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                        
                        memberInfo.email = json["data"]["member_info"]["email"].string!
                        memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                        memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                        memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                        
                        // Listing Info
                        memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                        memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                        memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                        memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                        memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                        
                        // Share Info
                        memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                        memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                        memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                        memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                        memberInfo.shareURL = json["data"]["share_info"]["share_url"].string!
                        
                        memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                        memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                        memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                        memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                        
                        
                        memberInfo.bindWechat = json["data"]["thirdpart_info"]["weixin_bind"].string!
                        memberInfo.bindWeibo = json["data"]["thirdpart_info"]["weibo_bind"].string!
                        
                        
                        
                        // update local data
                        self.updateSettings(token, currentMid: mid)
                        
                        if let member = Member.findFirst(attribute: "mid", value: memberInfo.memberId, contextType: BreezeContextType.Main) as? Member {
                            
                            BreezeStore.saveInMain({ (contextType) -> Void in
                                
                                
                                member.email = memberInfo.email!
                                member.phone = memberInfo.mobile!
                                member.nickname = memberInfo.nickname!
                                member.iconURL = memberInfo.icon!
                                member.lastLog = NSDate()
                                member.token = token
                                
                            })
                            
                        }
                        else { // Member login for the first time without register on the device
                            // Get member info and refresh userinterface
                            BreezeStore.saveInMain({ (contextType) -> Void in
                                
                                let member = Member.createInContextOfType(contextType) as! Member
                                
                                member.mid = memberInfo.memberId
                                member.email = memberInfo.email!
                                member.phone = memberInfo.mobile!
                                member.nickname = memberInfo.nickname!
                                member.iconURL = memberInfo.icon!
                                member.lastLog = NSDate()
                                member.token = token
                                
                            })
                            
                        }
                        
                        // Push user device token
                        pushDeviceToken(VCheckGo.PushDeviceType.add)
                        
                        // setup cache & user panel interface
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                        
                        self.resetOrderPageLayout()
                        self.checkOrderInfo()
                    }
                    else {
                        self.hud.hide(true)
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                }
                else {
                    self.hud.hide(true)
                    println("ERROR @ Request for member info : \(error?.localizedDescription)")
                }
            })
        })
    }
    
    func checkOrderInfo() {
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetProductDetailWithMember(self.foodInfo.id, memberId)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    
                    // Unpaid order exist?
                    let foodOrder = json["data"]["article_info"]["order_info"]
                    
                    if foodOrder != "" {
                        
                        RKDropdownAlert.title(VCAppLetor.StringLine.BackToPay, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
                        
                        self.foodInfo.orderExist = json["data"]["article_info"]["order_info"]["order_id"].string!
                        
                        self.submitBtn.removeTarget(self, action: "checkNowAction", forControlEvents: .TouchUpInside)
                        self.submitBtn.addTarget(self, action: "backToPay", forControlEvents: .TouchUpInside)
                    }
                    else {
                        self.foodInfo.orderExist = "0"
                        self.submitOrder()
                    }
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
            }
            else {
                
                println("ERROR @ Request for Product Detail[CheckNow] : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        })
        
    }
    
    func backToPay() {
        
        RKDropdownAlert.title(VCAppLetor.StringLine.BackToPay, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
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
        
        var phoneNumber: String = (CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo).mobile!
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







