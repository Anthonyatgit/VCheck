//
//  VCPaySuccessViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/1.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//


import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD


class VCPaySuccessViewController: VCBaseViewController, UIScrollViewDelegate {
    
    var orderInfo: OrderInfo!
    
    var parentNav: UINavigationController!
    var foodDetailVC: VCBaseViewController!
    
    let scrollView: UIScrollView = UIScrollView()
    
    let topTip: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let successIcon: UIImageView = UIImageView.newAutoLayoutView()
    let successText: UILabel = UILabel.newAutoLayoutView()
    
    let orderProductName: UILabel = UILabel.newAutoLayoutView()
    let orderProductTitle: UILabel = UILabel.newAutoLayoutView()
    let orderPrice: UILabel = UILabel.newAutoLayoutView()
    
    let spiritUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let orderInfoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let orderNoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let codeName: UILabel = UILabel.newAutoLayoutView()
    let codeValue: UILabel = UILabel.newAutoLayoutView()
    
    let orderInfoButton: UIButton = UIButton.newAutoLayoutView()
    let returnButton: UIButton = UIButton.newAutoLayoutView()
    
    let end: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var hud: MBProgressHUD!
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.PaymentDoneTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        let backView: UIView = UIView(frame: CGRectMake(0.0, 0.0, 42.0, 42.0))
        backView.backgroundColor = UIColor.clearColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backView)
        
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        
        self.setupViews()
        
        self.view.setNeedsUpdateConstraints()
        
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
        
        self.topTip.autoSetDimensionsToSize(CGSizeMake(self.view.width, 32.0))
        self.topTip.autoPinEdgeToSuperviewEdge(.Top)
        self.topTip.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.successIcon.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.topTip, withOffset: 30.0)
        self.successIcon.autoSetDimensionsToSize(CGSizeMake(self.view.width/8.0, self.view.width/8.0))
        self.successIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.successText.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.successIcon, withOffset: 10.0)
        self.successText.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.spiritUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.successText, withOffset: 20.0)
        self.spiritUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width - 60.0, 3.0))
        self.spiritUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.orderProductName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.spiritUnderline)
        self.orderProductName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.spiritUnderline, withOffset: 20.0)
        
        self.orderProductTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.spiritUnderline)
        self.orderProductTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderProductName)
        
        self.orderPrice.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderProductTitle, withOffset: 10.0)
        self.orderPrice.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.spiritUnderline)
        
        self.orderInfoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderPrice, withOffset: 20.0)
        self.orderInfoUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width - 60.0, 3.0))
        self.orderInfoUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.codeName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoUnderline, withOffset: 20.0)
        self.codeName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.spiritUnderline)
        
        self.codeValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.spiritUnderline)
        self.codeValue.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.codeName)
        
        self.orderNoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.codeName, withOffset: 20.0)
        self.orderNoUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width - 60.0, 3.0))
        self.orderNoUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.orderInfoButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.codeName)
        self.orderInfoButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderNoUnderline, withOffset: 40.0)
        self.orderInfoButton.autoSetDimensionsToSize(CGSizeMake((self.view.width-60.0)/2.0-20.0, 35.0))
        
        self.returnButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.spiritUnderline)
        self.returnButton.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderInfoButton)
        self.returnButton.autoSetDimensionsToSize(CGSizeMake((self.view.width-60.0)/2.0-20.0, 35.0))
        
        self.end.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoButton, withOffset: 30.0)
        self.end.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.spiritUnderline)
        self.end.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.spiritUnderline)
        self.end.autoSetDimension(.Height, toSize: 50.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK : - Functions
    
    func setupViews() {
        
        self.topTip.drawType = "PayDoneTopTip"
        self.topTip.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1)
        self.scrollView.addSubview(self.topTip)
        
        self.successIcon.image = UIImage(named: VCAppLetor.IconName.SuccessIcon)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.successIcon.tintColor = VCAppLetor.Colors.done
        self.scrollView.addSubview(self.successIcon)
        
        self.successText.text = VCAppLetor.StringLine.PaymentSuccessString
        self.successText.textAlignment = .Center
        self.successText.textColor = VCAppLetor.Colors.Title
        self.successText.font = VCAppLetor.Font.XLarge
        self.successText.sizeToFit()
        self.scrollView.addSubview(self.successText)
        
        self.spiritUnderline.drawType = "GrayLine"
        self.spiritUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.spiritUnderline)
        
        self.orderProductName.text = VCAppLetor.StringLine.OrderProductName
        self.orderProductName.textAlignment = .Left
        self.orderProductName.textColor = VCAppLetor.Colors.Title
        self.orderProductName.font = VCAppLetor.Font.NormalFont
        self.orderProductName.sizeToFit()
        self.scrollView.addSubview(self.orderProductName)
        
        self.orderProductTitle.text = self.orderInfo.menuTitle!
        self.orderProductTitle.textAlignment = .Right
        self.orderProductTitle.textColor = VCAppLetor.Colors.Title
        self.orderProductTitle.font = VCAppLetor.Font.NormalFont
        self.orderProductTitle.sizeToFit()
        self.scrollView.addSubview(self.orderProductTitle)
        
        self.orderPrice.text = round_price(self.orderInfo.totalPrice!) + "元"
        self.orderPrice.textAlignment = .Right
        self.orderPrice.textColor = VCAppLetor.Colors.HighLight
        self.orderPrice.font = VCAppLetor.Font.NormalFont
        self.orderPrice.sizeToFit()
        self.scrollView.addSubview(self.orderPrice)
        
        self.orderInfoUnderline.drawType = "GrayLine"
        self.orderInfoUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderInfoUnderline)
        
        self.codeName.text = VCAppLetor.StringLine.OrderNumber
        self.codeName.textAlignment = .Left
        self.codeName.textColor = VCAppLetor.Colors.Title
        self.codeName.font = VCAppLetor.Font.NormalFont
        self.codeName.sizeToFit()
        self.scrollView.addSubview(self.codeName)
        
        self.codeValue.text = self.orderInfo.no
        self.codeValue.textAlignment = .Right
        self.codeValue.textColor = VCAppLetor.Colors.Light
        self.codeValue.font = VCAppLetor.Font.XLarge
        self.codeValue.sizeToFit()
        self.scrollView.addSubview(self.codeValue)
        
        self.orderNoUnderline.drawType = "GrayLine"
        self.orderNoUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderNoUnderline)
        
        self.orderInfoButton.setTitle(VCAppLetor.StringLine.CheckOrderTitle, forState: .Normal)
        self.orderInfoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.orderInfoButton.titleLabel?.font = VCAppLetor.Font.BigFont
        self.orderInfoButton.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.8)
        self.orderInfoButton.addTarget(self, action: "checkMyOrder", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.orderInfoButton)
        
        self.returnButton.setTitle(VCAppLetor.StringLine.BackToGo, forState: .Normal)
        self.returnButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.returnButton.titleLabel?.font = VCAppLetor.Font.XLarge
        self.returnButton.backgroundColor = UIColor.turquoiseColor(alpha: 0.8)
        self.returnButton.addTarget(self, action: "backToGo", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.returnButton)
        
        self.end.drawType = "noMore"
        self.scrollView.addSubview(self.end)
        
        self.view.addSubview(self.scrollView)
        
    }
    
    
    func checkMyOrder() {
        
        // Show order page
        
    }
    
    
    func backToGo() {
        
        self.parentNav.popToViewController(self.foodDetailVC, animated: true)
        
    }
    
    
    

}




