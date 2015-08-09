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


class VCPayNowViewController: VCBaseViewController, UIScrollViewDelegate, RKDropdownAlertDelegate, WXApiDelegate, VoucherDelegate {
    
    
    var orderInfo: OrderInfo!
    
    var paymentCode: VCAppLetor.PaymentCode = VCAppLetor.PaymentCode.AliPay {
        willSet(type) {
            
            if type == VCAppLetor.PaymentCode.AliPay {
                self.activeCircleAlipay.hidden = false
                self.activeCircleWechat.hidden = true
            }
            else if type == VCAppLetor.PaymentCode.WechatPay {
                self.activeCircleAlipay.hidden = true
                self.activeCircleWechat.hidden = false
            }
        }
    }
    
    var voucherId: String? = ""
    var voucherPrice: String? = ""
    
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
    let alipaySubtitle: UILabel = UILabel.newAutoLayoutView()
    let alipayActive: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let alipayUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let alipayBtn: UIButton = UIButton.newAutoLayoutView()
    
    let wechatIcon: UIImageView = UIImageView.newAutoLayoutView()
    let wechatTitle: UILabel = UILabel.newAutoLayoutView()
    let wechatSubtitle: UILabel = UILabel.newAutoLayoutView()
    let wechatActive: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let wechatUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let wechatBtn: UIButton = UIButton.newAutoLayoutView()
    
    let activeCircleAlipay: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let activeCircleWechat: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let backButton: UIButton = UIButton(frame: CGRectMake(-20.0, 0.0, 42.0, 42.0))
    
    var hud: MBProgressHUD!
    
    var didUpdateConstraint: Bool = false
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.PayOrderTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        let backView: UIView = UIView(frame: CGRectMake(0.0, 0.0, 42.0, 42.0))
        backView.backgroundColor = UIColor.clearColor()
        
        self.backButton.setImage(UIImage(named: VCAppLetor.IconName.backBlack)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.backButton.backgroundColor = UIColor.clearColor()
        self.backButton.addTarget(self, action: "canclePay", forControlEvents: .TouchUpInside)
        backView.addSubview(self.backButton)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backView)
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        
        self.setupPayView()
        
        self.setupPayBar()
        
        self.updateViewConstraints()
        
        self.updatePaymentInfo()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.didUpdateConstraint {
            
            self.scrollView.contentSize = self.scrollView.frame.size
            
            if (self.wechatUnderline.originY + 15.0) < self.scrollView.frame.height {
                
                self.scrollView.contentSize.height = self.scrollView.frame.height + 1.0 - VCAppLetor.ConstValue.CheckNowBarHeight
            }
            else {
                self.scrollView.contentSize.height = self.wechatUnderline.originY + 15.0
            }
        }
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        
        
        
        if !self.didUpdateConstraint {
            
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
            //self.priceUnit.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
            
            self.priceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.priceUnit)
            self.priceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceName)
            //self.priceValue.autoSetDimensionsToSize(CGSizeMake(50.0, 20.0))
            
            self.priceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceName, withOffset: 10.0)
            self.priceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.priceName)
            self.priceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.priceUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.amountName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.amountName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceUnderline, withOffset: 10.0)
            self.amountName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
            
            self.amountValue.autoAlignAxis(.Horizontal, toSameAxisOfView: self.amountName)
            self.amountValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            //self.amountValue.autoSetDimensionsToSize(CGSizeMake(30.0, 14.0))
            
            self.amountUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.amountUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountName, withOffset: 10.0)
            self.amountUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.amountUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.totalPriceName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.totalPriceName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.amountUnderline, withOffset: 10.0)
            self.totalPriceName.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
            
            self.totalPriceValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.totalPriceValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.totalPriceName)
            //self.totalPriceValue.autoSetDimensionsToSize(CGSizeMake(80.0, 20.0))
            
            self.totalPriceUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.totalPriceUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.totalPriceUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceName, withOffset: 10.0)
            self.totalPriceUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.couponName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.couponName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.totalPriceUnderline, withOffset: 10.0)
            self.couponName.autoSetDimensionsToSize(CGSizeMake(78.0, 20.0))
            
            self.couponArraw.autoSetDimensionsToSize(CGSizeMake(20.0, 24.0))
            self.couponArraw.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.couponArraw.autoPinEdge(.Top, toEdge: .Top, ofView: self.couponName, withOffset: -4.0)
            
            //self.couponStat.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
            self.couponStat.autoPinEdge(.Top, toEdge: .Top, ofView: self.couponName)
            self.couponStat.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.couponArraw, withOffset: -6.0)
            
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
            //self.finalTotalValue.autoSetDimensionsToSize(CGSizeMake(80.0, 20.0))
            
            self.finalTotalUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.finalTotalUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.finalTotalUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.finalTotalName, withOffset: 10.0)
            self.finalTotalUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.choosePayType.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.choosePayType.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.finalTotalUnderline, withOffset: 20.0)
            self.choosePayType.autoSetDimensionsToSize(CGSizeMake(124.0, 24.0))
            
            self.payTip.autoSetDimensionsToSize(CGSizeMake(100.0, 20.0))
            self.payTip.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.payTip.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.choosePayType)
            
            self.choosePayTypeUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.choosePayTypeUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayType, withOffset: 10.0)
            self.choosePayTypeUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.choosePayTypeUnderline.autoSetDimension(.Height, toSize: 5.0)
            
            self.alipayIcon.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
            self.alipayIcon.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.alipayIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayTypeUnderline, withOffset: 12.0)
            
            self.alipayTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.alipayIcon, withOffset: 10.0)
            //self.alipayTitle.autoSetDimensionsToSize(CGSizeMake(132.0, 20.0))
            self.alipayTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.alipayIcon, withOffset: 0.0)
            
            self.alipaySubtitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.wechatIcon, withOffset: 10.0)
            //self.alipaySubtitle.autoSetDimensionsToSize(CGSizeMake(self.view.width - 120, 20.0))
            self.alipaySubtitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayTitle, withOffset: 1.0)
            
            self.alipayActive.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.alipayActive.autoAlignAxis(.Horizontal, toSameAxisOfView: self.alipayIcon)
            self.alipayActive.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
            
            self.activeCircleAlipay.autoPinEdge(.Top, toEdge: .Top, ofView: self.alipayActive)
            self.activeCircleAlipay.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.alipayActive)
            self.activeCircleAlipay.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
            
            self.alipayUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.alipayUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.alipayUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayIcon, withOffset: 12.0)
            self.alipayUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.alipayBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.alipayIcon)
            self.alipayBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.alipayBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.choosePayTypeUnderline)
            self.alipayBtn.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.alipayUnderline)
            
            self.wechatIcon.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
            self.wechatIcon.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.wechatIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.alipayUnderline, withOffset: 12.0)
            
            self.wechatTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.wechatIcon, withOffset: 10.0)
            //self.wechatTitle.autoSetDimensionsToSize(CGSizeMake(132.0, 20.0))
            self.wechatTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.wechatIcon, withOffset: 0.0)
            
            self.wechatSubtitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.wechatIcon, withOffset: 10.0)
            //self.wechatSubtitle.autoSetDimensionsToSize(CGSizeMake(self.view.width - 120, 20.0))
            self.wechatSubtitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.wechatTitle, withOffset: 1.0)
            
            self.wechatActive.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.wechatActive.autoAlignAxis(.Horizontal, toSameAxisOfView: self.wechatIcon)
            self.wechatActive.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
            
            self.activeCircleWechat.autoPinEdge(.Top, toEdge: .Top, ofView: self.wechatActive)
            self.activeCircleWechat.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.wechatActive)
            self.activeCircleWechat.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
            
            self.wechatUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.wechatUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.wechatUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.wechatIcon, withOffset: 12.0)
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
            //self.orderPriceValue.autoSetDimensionsToSize(CGSizeMake(54.0, 22.0))
            
            self.orderPriceName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderPriceValue, withOffset: 0.0)
            self.orderPriceName.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payBtn)
            self.orderPriceName.autoSetDimensionsToSize(CGSizeMake(62.0, 20.0))
            
            self.didUpdateConstraint = true
            
        }
        
    }
    
    // MARK: - Voucher Delegate
    func didUseVoucher(voucherId: String, price: String) {
        
        self.voucherId = voucherId
        self.voucherPrice = price
        self.updatePaymentInfo()
    }
    
    
    
    // MARK: - Functions
    
    func canclePay() {
        
        self.parentNav.popToViewController(self.foodDetailVC, animated: true)
    }
    
    func setupPayView() {
        
        self.topTip.drawType = "PayTopTip"
        self.topTip.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        self.scrollView.addSubview(self.topTip)
        
        self.foodTitle.text = self.orderInfo.title!
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.textAlignment = .Left
        self.foodTitle.textColor = UIColor.blackColor()
        self.scrollView.addSubview(self.foodTitle)
        
        self.foodTitleUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.foodTitleUnderline)
        
        self.priceName.text = VCAppLetor.StringLine.PriceName
        self.priceName.textAlignment = .Left
        self.priceName.textColor = VCAppLetor.Colors.Label
        self.priceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.priceName)
        
        self.priceValue.text = round_price(self.orderInfo.pricePU!)
        self.priceValue.textAlignment = .Right
        self.priceValue.textColor = VCAppLetor.Colors.Label
        self.priceValue.font = VCAppLetor.Font.LightSmall
        self.priceValue.sizeToFit()
        self.scrollView.addSubview(self.priceValue)
        
        self.priceUnit.text = "\(self.orderInfo.priceUnit!)/\(self.orderInfo.menuUnit!)"
        self.priceUnit.textAlignment = .Right
        self.priceUnit.textColor = VCAppLetor.Colors.Label
        self.priceUnit.font = VCAppLetor.Font.NormalFont
        self.priceUnit.sizeToFit()
        self.scrollView.addSubview(self.priceUnit)
        
        self.priceUnderline.drawType = "GrayLine"
        self.priceUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.priceUnderline)
        
        self.amountName.text = VCAppLetor.StringLine.AmountName
        self.amountName.textAlignment = .Left
        self.amountName.textColor = VCAppLetor.Colors.Label
        self.amountName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.amountName)
        
        self.amountValue.text = self.orderInfo.itemCount!
        self.amountValue.textAlignment = .Right
        self.amountValue.textColor = VCAppLetor.Colors.Label
        self.amountValue.font = VCAppLetor.Font.LightSmall
        self.amountValue.sizeToFit()
        self.scrollView.addSubview(self.amountValue)
        
        self.amountUnderline.drawType = "GrayLine"
        self.amountUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.amountUnderline)
        
        self.totalPriceName.text = VCAppLetor.StringLine.TotalPriceName
        self.totalPriceName.textAlignment = .Left
        self.totalPriceName.textColor = VCAppLetor.Colors.Label
        self.totalPriceName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.totalPriceName)
        
        self.totalPriceValue.text = round_price("\((self.orderInfo.pricePU! as NSString).floatValue * (self.orderInfo.itemCount! as NSString).floatValue)") + self.orderInfo.priceUnit!
        self.totalPriceValue.textAlignment = .Right
        self.totalPriceValue.textColor = UIColor.orangeColor()
        self.totalPriceValue.font = VCAppLetor.Font.LightSmall
        self.totalPriceValue.sizeToFit()
        self.scrollView.addSubview(self.totalPriceValue)
        
        self.totalPriceUnderline.drawType = "GrayLine"
        self.totalPriceUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.totalPriceUnderline)
        
        self.couponName.text = VCAppLetor.StringLine.UseCouponName
        self.couponName.textAlignment = .Left
        self.couponName.textColor = VCAppLetor.Colors.Label
        self.couponName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.couponName)
        
        if self.orderInfo.voucherId! != "" {
            self.voucherId = self.orderInfo.voucherId!
            self.voucherPrice = round_price("\((self.orderInfo.pricePU! as NSString).floatValue * (self.orderInfo.itemCount! as NSString).floatValue - (self.orderInfo.totalPrice! as NSString).floatValue)")
            
        }
        
        self.couponStat.text = self.voucherId! != "" ? "-\(self.voucherPrice!)元" : VCAppLetor.StringLine.CouponNone
        self.couponStat.textAlignment = .Right
        if self.voucherId! != "" {
            
            self.couponStat.textColor = UIColor.alizarinColor(alpha: 0.8)
        }
        else {
            self.couponStat.textColor = UIColor.grayColor()
        }
        self.couponStat.font = VCAppLetor.Font.LightSmall
        self.couponStat.sizeToFit()
        self.scrollView.addSubview(self.couponStat)
        
        self.couponArraw.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.couponArraw.tintColor = UIColor.lightGrayColor()
        self.scrollView.addSubview(self.couponArraw)
        
        self.couponBtn.setTitle("", forState: .Normal)
        self.couponBtn.backgroundColor = UIColor.clearColor()
        self.couponBtn.addTarget(self, action: "showCoupon", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.couponBtn)
        
        self.couponUnderline.drawType = "GrayLine"
        self.couponUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.couponUnderline)
        
        self.finalTotalName.text = VCAppLetor.StringLine.FinalOrderTotal
        self.finalTotalName.textAlignment = .Left
        self.finalTotalName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.finalTotalName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.finalTotalName)
        
        self.finalTotalValue.text = round_price(self.orderInfo.totalPrice!) + self.orderInfo.priceUnit!
        self.finalTotalValue.textAlignment = .Right
        self.finalTotalValue.textColor = UIColor.orangeColor()
        self.finalTotalValue.font = VCAppLetor.Font.LightSmall
        self.finalTotalValue.sizeToFit()
        self.scrollView.addSubview(self.finalTotalValue)
        
        self.finalTotalUnderline.drawType = "GrayLine"
        self.finalTotalUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.finalTotalUnderline)
        
        self.choosePayType.text = VCAppLetor.StringLine.ChoosePayType
        self.choosePayType.textAlignment = .Left
        self.choosePayType.textColor = VCAppLetor.Colors.Title
        self.choosePayType.font = VCAppLetor.Font.XLarge
        self.scrollView.addSubview(self.choosePayType)
        
        self.payTip.setTitle(VCAppLetor.StringLine.QuestionWithPay, forState: .Normal)
        self.payTip.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.payTip.titleLabel?.textAlignment = .Right
        self.payTip.titleLabel?.font = VCAppLetor.Font.SmallFont
        self.payTip.layer.borderWidth = 0.0
        self.scrollView.addSubview(self.payTip)
        
        self.choosePayTypeUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.choosePayTypeUnderline)
        
        self.alipayIcon.image = UIImage(named: VCAppLetor.IconName.AlipayIcon)
        self.alipayIcon.layer.cornerRadius = VCAppLetor.ConstValue.IconImageCornerRadius
        self.scrollView.addSubview(self.alipayIcon)
        
        self.alipayTitle.text = VCAppLetor.StringLine.AlipayType
        self.alipayTitle.textAlignment = .Left
        self.alipayTitle.textColor = VCAppLetor.Colors.Label
        self.alipayTitle.font = VCAppLetor.Font.NormalFont
        self.alipayTitle.sizeToFit()
        self.scrollView.addSubview(self.alipayTitle)
        
        self.alipaySubtitle.text = VCAppLetor.StringLine.AlipaySubtitle
        self.alipaySubtitle.textAlignment = .Left
        self.alipaySubtitle.textColor = VCAppLetor.Colors.Light
        self.alipaySubtitle.font = VCAppLetor.Font.XSmall
        self.alipaySubtitle.sizeToFit()
        self.scrollView.addSubview(self.alipaySubtitle)
        
        self.alipayActive.drawType = "UnselectedCircle"
        self.scrollView.addSubview(self.alipayActive)
        
        self.alipayUnderline.drawType = "GrayLine"
        self.alipayUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
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
        self.wechatTitle.sizeToFit()
        self.scrollView.addSubview(self.wechatTitle)
        
        self.wechatSubtitle.text = VCAppLetor.StringLine.WechatSubtitle
        self.wechatSubtitle.textAlignment = .Left
        self.wechatSubtitle.textColor = VCAppLetor.Colors.Light
        self.wechatSubtitle.font = VCAppLetor.Font.XSmall
        self.wechatSubtitle.sizeToFit()
        self.scrollView.addSubview(self.wechatSubtitle)
        
        self.wechatActive.drawType = "UnselectedCircle"
        self.scrollView.addSubview(self.wechatActive)
        
        self.wechatUnderline.drawType = "GrayLine"
        self.wechatUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.wechatUnderline)
        
        self.wechatBtn.setTitle("", forState: .Normal)
        self.wechatBtn.layer.borderWidth = 0.0
        self.wechatBtn.tag = 2
        self.wechatBtn.addTarget(self, action: "setPayType:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.wechatBtn)
        
        self.activeCircleAlipay.drawType = "SelectedCircle"
        self.activeCircleAlipay.hidden = false
        self.scrollView.addSubview(self.activeCircleAlipay)
        
        self.activeCircleWechat.drawType = "SelectedCircle"
        self.activeCircleWechat.hidden = true
        self.scrollView.addSubview(self.activeCircleWechat)
        
        self.view.addSubview(self.scrollView)
    }
    
    func setupPayBar() {
        
        self.payBg.backgroundColor = UIColor.nephritisColor()
        self.payBarView.addSubview(self.payBg)
        
        self.payBtn.backgroundColor = UIColor.nephritisColor()
        self.payBtn.setTitle(VCAppLetor.StringLine.PayNow, forState: UIControlState.Normal)
        self.payBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.payBtn.layer.borderWidth = 1.0
        self.payBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.payBtn.addTarget(self, action: "payNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.payBarView.addSubview(self.payBtn)
        
        self.orderPriceName.text = VCAppLetor.StringLine.FinalOrderTotal
        self.orderPriceName.textAlignment = .Left
        self.orderPriceName.textColor = UIColor.orangeColor()
        self.orderPriceName.font = VCAppLetor.Font.SmallFont
        self.orderPriceName.sizeToFit()
        self.payBarView.addSubview(self.orderPriceName)
        
        self.orderPriceValue.text = round_price(self.orderInfo.totalPrice!) + self.orderInfo.priceUnit!
        self.orderPriceValue.textAlignment = .Center
        self.orderPriceValue.textColor = UIColor.orangeColor()
        self.orderPriceValue.font = VCAppLetor.Font.Light
        self.orderPriceValue.sizeToFit()
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
            self.paymentCode = VCAppLetor.PaymentCode.AliPay
        }
        else if btn.tag == 2 {
            self.paymentCode = VCAppLetor.PaymentCode.WechatPay
        }
        
        // Update payment info
        self.updatePaymentInfo()
        
        
    }
    
    func updatePaymentInfo() {
        
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        
        Alamofire.request(VCheckGo.Router.UpdatePay(memberId, self.paymentCode, self.voucherId!, self.orderInfo.id, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                //println("json: \(json)")
                
                if json["status"]["succeed"].string! == "1" {
                    // Update done!
                    
                    if self.voucherId! != "" {
                        self.couponStat.text = "-\(round_price(self.voucherPrice!))元"
                        self.couponStat.textColor = UIColor.alizarinColor(alpha: 0.8)
                    }
                    else {
                        self.couponStat.text = VCAppLetor.StringLine.CouponNone
                        self.couponStat.textColor = UIColor.grayColor()
                    }
                    
                    let needToPay = json["data"]["order_info"]["total_price"]["special_price"].string!
                    self.finalTotalValue.text = round_price(needToPay) + self.orderInfo.priceUnit!
                    self.orderPriceValue.text = round_price(needToPay) + self.orderInfo.priceUnit!
                    
                }
                else {
                    
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                
                println("ERROR @ Request for update payment info : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        })
        
    }
    
    func showCoupon() {
        
        let voucherVC: VoucherViewController = VoucherViewController()
        voucherVC.parentNav = self.parentNav
        voucherVC.active = true
        voucherVC.delegate = self
        self.parentNav.showViewController(voucherVC, sender: self)
        
    }
    
    
    func didCancleVoucher() {
        
        self.voucherId = ""
        self.voucherPrice = ""
        self.updatePaymentInfo()
        
    }
    
    
    // Transfer to pay actions
    func payNowAction() {
        
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        
        // Get payment request string from server
        Alamofire.request(VCheckGo.Router.GetPayData(memberId, self.orderInfo.id, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    let orderString: String = json["data"]["payment_order_param"].string!
                    
                    //========== ALIPAY PAYGATE ================
                    if self.paymentCode == VCAppLetor.PaymentCode.AliPay {
                        
                        
                        self.saveForCache()
                        CTMemCache.sharedInstance.set(VCAppLetor.ObjectIns.objPayVC, data: self, namespace: "object")
                        
                        AlipaySDK.defaultService().payOrder(orderString, fromScheme: VCAppLetor.StringLine.AppScheme, callback: {
                            (resultDic) -> Void in
                            
                            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            self.hud.mode = MBProgressHUDMode.Determinate
                            self.hud.labelText = VCAppLetor.StringLine.AsyncPaymentInProgress
                            
                            let dic = resultDic as NSDictionary
                            
                            if dic.valueForKey("resultStatus") as! String == "9000" {
                                
                                let resultString = (dic.valueForKey("result") as! String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                                
                                Alamofire.request(VCheckGo.Router.AsyncPayment(memberId, self.orderInfo.id, resultString!, token)).validate().responseSwiftyJSON({
                                    (_, _, JSON, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        let json = JSON
                                        
                                        if json["status"]["succeed"].string! == "1" {
                                            
                                            self.hud.hide(true)
                                            
                                            // Show success view
                                            let paySuccessVC: VCPaySuccessViewController = VCPaySuccessViewController()
                                            paySuccessVC.parentNav = self.parentNav
                                            paySuccessVC.foodDetailVC = self.foodDetailVC
                                            paySuccessVC.orderInfo = self.orderInfo
                                            self.parentNav.showViewController(paySuccessVC, sender: self)
                                            
                                        }
                                        else {
                                            self.hud.hide(true)
                                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                        }
                                    }
                                    else {
                                        self.hud.hide(true)
                                        println("ERROR @ Request for async payment result : \(error?.localizedDescription)")
                                        RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                    }
                                })
                            }
                            else if dic.valueForKey("resultStatus") as! String == "6001" {
                                
                                self.hud.hide(true)
                                RKDropdownAlert.title(VCAppLetor.StringLine.UserCanclePayment, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
                                
                            }
                            else if dic.valueForKey("resultStatus") as! String == "6002" {
                                
                                self.hud.hide(true)
                                RKDropdownAlert.title(VCAppLetor.StringLine.PaymentNetworkError, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                
                            }
                            else if dic.valueForKey("resultStatus") as! String == "4000" {
                                
                                self.hud.hide(true)
                                RKDropdownAlert.title(VCAppLetor.StringLine.PaymentFailed, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                
                            }
                        })
                    }
                        //========== WeChat PAYGATE ================
                    else if self.paymentCode == VCAppLetor.PaymentCode.WechatPay {
                        
                        self.sendWXPay(orderString)
                        
                    }
                }
                else {
                    
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                
                println("ERROR @ Request for update payment info : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        })
        
    }
    
    
    func sendWXPay(orderString: String) {
        
        var error: NSError?
        
        CTMemCache.sharedInstance.set(VCAppLetor.ObjectIns.objPayVC, data: self, namespace: "object")
        
        // Save Cahce order data
        self.saveForCache()
        
        
        if orderString != "" {
            
            var dict: NSMutableDictionary = NSMutableDictionary()
            
            let data: NSData = orderString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
            
            dict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &error) as! NSMutableDictionary
            
            //println("orderString: \(orderString) \n dict: \(dict)")
            
            if !dict.isEqual(nil) {
                
                var stamp: String = dict.objectForKey("timestamp") as! String
                
                // Call Wechat Pay
                let req: PayReq = PayReq()
                req.openID          = dict.objectForKey("appid") as! String
                req.partnerId       = dict.objectForKey("partnerid") as! String
                req.prepayId        = dict.objectForKey("prepayid") as! String
                req.nonceStr        = dict.objectForKey("noncestr") as! String
                req.timeStamp       = UInt32((stamp as NSString).intValue)
                req.package         = dict.objectForKey("package") as! String
                req.sign            = dict.objectForKey("paySign") as! String
                
                WXApi.safeSendReq(req)
                
            }
            else {
                
                println("ERROR @ JSON Object return by server is nil")
            }
        }
        else {
            println("ERROR @ sending synchronousRequest for preorder")
        }
        
    }
    
    func onResp(resp: BaseResp!) {
        
        println("errCode: \(resp.errCode)")
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.AsyncPaymentInProgress
        
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        
        if resp.isKindOfClass(PayResp.classForCoder()) {
            
            if (resp.errCode == WXSuccess.value) {
                
                // Payment Result
                let resultString = "\(resp.errCode)"
                
                // Show success view
                let paySuccessVC: VCPaySuccessViewController = VCPaySuccessViewController()
                paySuccessVC.parentNav = self.parentNav
                paySuccessVC.foodDetailVC = self.foodDetailVC
                paySuccessVC.orderInfo = self.orderInfo
                self.parentNav.showViewController(paySuccessVC, sender: self)
                
//                Alamofire.request(VCheckGo.Router.AsyncPayment(memberId, self.orderInfo.id, resultString, token)).validate().responseSwiftyJSON({
//                    (_, _, JSON, error) -> Void in
//                    
//                    if error == nil {
//                        
//                        let json = JSON
//                        
//                        if json["status"]["succeed"].string! == "1" {
//                            
//                            self.hud.hide(true)
//                            
//                            // Show success view
//                            let paySuccessVC: VCPaySuccessViewController = VCPaySuccessViewController()
//                            paySuccessVC.parentNav = self.parentNav
//                            paySuccessVC.foodDetailVC = self.foodDetailVC
//                            paySuccessVC.orderInfo = self.orderInfo
//                            self.parentNav.showViewController(paySuccessVC, sender: self)
//                            
//                        }
//                        else {
//                            self.hud.hide(true)
//                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
//                        }
//                    }
//                    else {
//                        self.hud.hide(true)
//                        println("ERROR @ Request for async payment result[PaySuccess] : \(error?.localizedDescription)")
//                        RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
//                    }
//                })
                
                
            }
            else if resp.errCode == WXErrCodeUserCancel.value {
                
                self.hud.hide(true)
                RKDropdownAlert.title(VCAppLetor.StringLine.UserCanclePayment, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
            }
            else if resp.errCode == WXErrCodeAuthDeny.value {
                
                self.hud.hide(true)
                RKDropdownAlert.title(VCAppLetor.StringLine.UserAuthFail, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
            }
            else {
                
                self.hud.hide(true)
                RKDropdownAlert.title(VCAppLetor.StringLine.PaymentFailed, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTimeLong)
            }
        }
        else if resp.isKindOfClass(SendMessageToWXResp.classForCoder()) {
            
            // Response from share to WeChat callback
            
            
        }
        
    }
    
    func saveForCache() {
        
        if let orderId = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.payOrderId, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ (contextType) -> Void in
                
                orderId.sid = "\(NSDate())"
                orderId.value = self.orderInfo.id
                
            })
        }
        else {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let orderIdToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                orderIdToBeCreate.sid = "\(NSDate())"
                orderIdToBeCreate.name = VCAppLetor.SettingName.payOrderId
                orderIdToBeCreate.value = self.orderInfo.id
                orderIdToBeCreate.type = VCAppLetor.SettingType.AppConfig
                orderIdToBeCreate.data = ""
                
            })
        }
        
    }
    
    
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        
        return true
    }
    
    
}


