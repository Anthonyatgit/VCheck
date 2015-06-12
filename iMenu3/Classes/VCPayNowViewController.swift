//
//  VCPayNowViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/8.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD


class VCPayNowViewController: VCBaseViewController, UIScrollViewDelegate, RKDropdownAlertDelegate {
    
    var foodItem: FoodItem?
    
    var orderInfo: OrderInfo?
    
    var payType: VCAppLetor.PayType = VCAppLetor.PayType.AliPay
    
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
    let amountValue: UILabel = UILabel.newAutoLayoutView()
    let amountUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let totalPriceName: UILabel = UILabel.newAutoLayoutView()
    let totalPriceValue: UILabel = UILabel.newAutoLayoutView()
    let totalPriceUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    
    let payBarView: UIView = UIView.newAutoLayoutView()
    let payBg: UIView = UIView.newAutoLayoutView()
    let payBtn: UIButton = UIButton.newAutoLayoutView()
    let orderPriceName: UILabel = UILabel.newAutoLayoutView()
    let orderPriceValue: UILabel = UILabel.newAutoLayoutView()
    
    let couponName: UILabel = UILabel.newAutoLayoutView()
    let couponStat: UILabel = UILabel.newAutoLayoutView()
    let couponArraw: UIImageView = UIImageView.newAutoLayoutView()
    let couponBtn: UIButton = UIButton.newAutoLayoutView()
    let couponUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let finalTotalName: UILabel = UILabel.newAutoLayoutView()
    let finalTotalValue: UILabel = UILabel.newAutoLayoutView()
    let finalTotalUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let choosePayType: UILabel = UILabel.newAutoLayoutView()
    let payTip: UIButton = UIButton.newAutoLayoutView()
    let choosePayTypeUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let alipayIcon: UIImageView = UIImageView.newAutoLayoutView()
    let alipayTitle: UILabel = UILabel.newAutoLayoutView()
    let alipayActive: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let alipayUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let alipayBtn: UIButton = UIButton.newAutoLayoutView()
    
    let wechatIcon: UIImageView = UIImageView.newAutoLayoutView()
    let wechatTitle: UILabel = UILabel.newAutoLayoutView()
    let wechatActive: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let wechatUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let wechatBtn: UIButton = UIButton.newAutoLayoutView()
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.PayOrderTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.setupPayView()
        
        self.setupPayBar()
        
        self.updateViewConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        self.scrollView.contentSize.height = self.wechatUnderline.originY + 20.0
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
        
        self.amountValue.autoAlignAxis(.Horizontal, toSameAxisOfView: self.amountName)
        self.amountValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.amountValue.autoSetDimensionsToSize(CGSizeMake(20.0, 14.0))
        
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
        
        self.couponName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.couponName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline, withOffset: 10.0)
        self.couponName.autoSetDimensionsToSize(CGSizeMake(78.0, 20.0))
        
        self.couponArraw.autoSetDimensionsToSize(CGSizeMake(18.0, 24.0))
        self.couponArraw.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.couponArraw.autoPinEdge(.Top, toEdge: .Top, ofView: self.couponName)
        
        self.couponStat.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
        self.couponStat.autoPinEdge(.Top, toEdge: .Top, ofView: self.couponName)
        self.couponStat.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.couponArraw, withOffset: -10.0)
        
        self.couponUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.couponUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.couponUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.couponName, withOffset: 10.0)
        self.couponUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.couponBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.couponBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.couponBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline)
        self.couponBtn.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.couponUnderline)
        
        self.finalTotalName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.finalTotalName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.couponUnderline, withOffset: 10.0)
        self.finalTotalName.autoSetDimensionsToSize(CGSizeMake(78.0, 20.0))
        
        self.finalTotalValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.finalTotalValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.finalTotalName)
        self.finalTotalValue.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
        
        self.finalTotalUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.finalTotalUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.finalTotalUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.finalTotalName, withOffset: 10.0)
        self.finalTotalUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.choosePayType.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.choosePayType.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.finalTotalUnderline, withOffset: 20.0)
        self.choosePayType.autoSetDimensionsToSize(CGSizeMake(124.0, 24.0))
        
        self.payTip.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        self.payTip.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.payTip.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.choosePayType)
        
        self.choosePayTypeUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.choosePayTypeUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayType, withOffset: 10.0)
        self.choosePayTypeUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.choosePayTypeUnderline.autoSetDimension(.Height, toSize: 5.0)
        
        self.alipayIcon.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
        self.alipayIcon.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.alipayIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayTypeUnderline, withOffset: 10.0)
        
        self.alipayTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.alipayIcon, withOffset: 10.0)
        self.alipayTitle.autoAlignAxis(.Horizontal, toSameAxisOfView: self.alipayIcon)
        self.alipayTitle.autoSetDimensionsToSize(CGSizeMake(132.0, 20.0))
        
        self.alipayActive.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.alipayActive.autoAlignAxis(.Horizontal, toSameAxisOfView: self.alipayIcon)
        self.alipayActive.autoSetDimensionsToSize(CGSizeMake(26.0, 26.0))
        
        self.alipayUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.alipayUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.alipayUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayIcon, withOffset: 10.0)
        self.alipayUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.alipayBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.alipayIcon)
        self.alipayBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.alipayBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayTypeUnderline)
        self.alipayBtn.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.alipayUnderline)
        
        self.wechatIcon.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
        self.wechatIcon.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.wechatIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayUnderline, withOffset: 10.0)
        
        self.wechatTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.wechatIcon, withOffset: 10.0)
        self.wechatTitle.autoAlignAxis(.Horizontal, toSameAxisOfView: self.wechatIcon)
        self.wechatTitle.autoSetDimensionsToSize(CGSizeMake(132.0, 20.0))
        
        self.wechatActive.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.wechatActive.autoAlignAxis(.Horizontal, toSameAxisOfView: self.wechatIcon)
        self.wechatActive.autoSetDimensionsToSize(CGSizeMake(26.0, 26.0))
        
        self.wechatUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        self.wechatUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.wechatUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.wechatIcon, withOffset: 10.0)
        self.wechatUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.wechatBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.wechatIcon)
        self.wechatBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        self.wechatBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayUnderline)
        self.wechatBtn.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.wechatUnderline)
        
        self.payBarView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Top)
        self.payBarView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
        
        self.payBtn.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
        self.payBtn.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payBarView, withMultiplier: 0.4)
        
        self.payBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.payBtn, withOffset: -1.0)
        self.payBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.payBtn, withOffset: -1.0)
        self.payBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.payBtn, withOffset: 2.0)
        self.payBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payBtn, withOffset: 2.0)
        
        self.orderPriceValue.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payBtn)
        self.orderPriceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.payBtn, withOffset: -30.0)
        self.orderPriceValue.autoSetDimensionsToSize(CGSizeMake(54.0, 22.0))
        
        self.orderPriceName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderPriceValue, withOffset: 0.0)
        self.orderPriceName.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payBtn)
        self.orderPriceName.autoSetDimensionsToSize(CGSizeMake(62.0, 20.0))
    }
    
    
    // MARK: - Functions
    
    func setupPayView() {
        
        self.topTip.drawType = "PayTopTip"
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
        
        self.amountValue.text = "1"
        self.amountValue.textAlignment = .Right
        self.amountValue.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.amountValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountValue)
        
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
        self.totalPriceValue.textColor = UIColor.orangeColor()
        self.totalPriceValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.totalPriceValue)
        
        self.totalPriceUnderline.drawType = "GrayLine"
        self.totalPriceUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.totalPriceUnderline)
        
        self.couponName.text = VCAppLetor.StringLine.UseCouponName
        self.couponName.textAlignment = .Left
        self.couponName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.couponName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.couponName)
        
        self.couponStat.text = VCAppLetor.StringLine.CouponNone
        self.couponStat.textAlignment = .Right
        self.couponStat.textColor = UIColor.grayColor()
        self.couponStat.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.couponStat)
        
        self.couponArraw.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)
        self.couponArraw.alpha = 0.2
        self.scrollView.addSubview(self.couponArraw)
        
        self.couponBtn.setTitle("", forState: .Normal)
        self.couponBtn.backgroundColor = UIColor.clearColor()
        self.couponBtn.addTarget(self, action: "showCoupon", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.couponBtn)
        
        self.couponUnderline.drawType = "GrayLine"
        self.couponUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.couponUnderline)
        
        self.finalTotalName.text = VCAppLetor.StringLine.FinalOrderTotal
        self.finalTotalName.textAlignment = .Left
        self.finalTotalName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.finalTotalName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.finalTotalName)
        
        self.finalTotalValue.text = "118元"
        self.finalTotalValue.textAlignment = .Right
        self.finalTotalValue.textColor = UIColor.orangeColor()
        self.finalTotalValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.finalTotalValue)
        
        self.finalTotalUnderline.drawType = "GrayLine"
        self.finalTotalUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.finalTotalUnderline)
        
        self.choosePayType.text = VCAppLetor.StringLine.ChoosePayType
        self.choosePayType.textAlignment = .Left
        self.choosePayType.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.choosePayType.font = VCAppLetor.Font.XLarge
        self.scrollView.addSubview(self.choosePayType)
        
        self.payTip.setTitle("Debug", forState: .Normal)
        self.payTip.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.payTip.titleLabel?.textAlignment = .Right
        self.payTip.titleLabel?.font = VCAppLetor.Font.SmallFont
        self.payTip.layer.borderWidth = 0.0
        self.payTip.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.scrollView.addSubview(self.payTip)
        
        self.choosePayTypeUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.choosePayTypeUnderline)
        
        self.alipayIcon.image = UIImage(named: VCAppLetor.IconName.AlipayIcon)
        self.alipayIcon.layer.cornerRadius = VCAppLetor.ConstValue.IconImageCornerRadius
        self.scrollView.addSubview(self.alipayIcon)
        
        self.alipayTitle.text = VCAppLetor.StringLine.AlipayType
        self.alipayTitle.textAlignment = .Left
        self.alipayTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.alipayTitle.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.alipayTitle)
        
        self.alipayActive.drawType = "SelectedCircle"
        self.scrollView.addSubview(self.alipayActive)
        
        self.alipayUnderline.drawType = "GrayLine"
        self.alipayUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.alipayUnderline)
        
        self.alipayBtn.setTitle("", forState: .Normal)
        self.alipayBtn.layer.borderWidth = 0.0
        self.alipayBtn.tag = 1
        self.alipayBtn.addTarget(self, action: "setPayType:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.alipayBtn)
        
        self.wechatIcon.image = UIImage(named: VCAppLetor.IconName.WechatIcon)
        self.wechatIcon.layer.cornerRadius = VCAppLetor.ConstValue.IconImageCornerRadius
        self.scrollView.addSubview(self.wechatIcon)
        
        self.wechatTitle.text = VCAppLetor.StringLine.WechatType
        self.wechatTitle.textAlignment = .Left
        self.wechatTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.wechatTitle.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.wechatTitle)
        
        self.wechatActive.drawType = "SelectedCircle"
        self.wechatActive.hidden = true
        self.scrollView.addSubview(self.wechatActive)
        
        self.wechatUnderline.drawType = "GrayLine"
        self.wechatUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.wechatUnderline)
        
        self.wechatBtn.setTitle("", forState: .Normal)
        self.wechatBtn.layer.borderWidth = 0.0
        self.wechatBtn.tag = 2
        self.wechatBtn.addTarget(self, action: "setPayType:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.wechatBtn)
        
        self.view.addSubview(self.scrollView)
    }
    
    func setupPayBar() {
        
        self.payBg.backgroundColor = UIColor.pumpkinColor()
        self.payBarView.addSubview(self.payBg)
        
        self.payBtn.backgroundColor = UIColor.pumpkinColor()
        self.payBtn.setTitle(VCAppLetor.StringLine.PayNow, forState: UIControlState.Normal)
        self.payBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.payBtn.layer.borderWidth = 1.0
        self.payBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.payBtn.addTarget(self, action: "payNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.payBarView.addSubview(self.payBtn)
        
        self.orderPriceName.text = VCAppLetor.StringLine.FinalOrderTotal
        self.orderPriceName.textAlignment = .Left
        self.orderPriceName.textColor = UIColor.orangeColor()
        self.orderPriceName.font = VCAppLetor.Font.NormalFont
        self.payBarView.addSubview(self.orderPriceName)
        
        self.orderPriceValue.text = "118元"
        self.orderPriceValue.textAlignment = .Center
        self.orderPriceValue.textColor = UIColor.orangeColor()
        self.orderPriceValue.font = VCAppLetor.Font.XLarge
        self.payBarView.addSubview(self.orderPriceValue)
        
        
        self.payBarView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        
        let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
        topBorder.drawType = "GrayLine"
        topBorder.lineWidth = 1.0
        self.payBarView.addSubview(topBorder)
        
        topBorder.autoSetDimension(.Height, toSize: 1.0)
        topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        self.view.addSubview(self.payBarView)
    }
    
    
    func setPayType(btn: UIButton) {
        
        if btn.tag == 1 {
            self.payType = VCAppLetor.PayType.AliPay
            self.wechatActive.hidden = true
            self.alipayActive.hidden = false
        }
        else if btn.tag == 2 {
            self.payType = VCAppLetor.PayType.WechatPay
            self.alipayActive.hidden = true
            self.wechatActive.hidden = false
        }
    }
    
    func showCoupon() {
        
        
    }
    
    // Transfer to pay actions
    func payNowAction() {
        
        
    }
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        
        return true
    }
    

}


