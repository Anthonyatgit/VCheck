//
//  OrderListViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class OrderListViewCell: UITableViewCell {
    
    var orderInfo: OrderInfo!
    
    var parentNav: UINavigationController?
    
    let title: UILabel = UILabel.newAutoLayoutView()
    let status: UILabel = UILabel.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let amount: UILabel = UILabel.newAutoLayoutView()
    let checkButton: UIButton = UIButton.newAutoLayoutView()
    
    let orderImageView: UIImageView = UIImageView.newAutoLayoutView()
    
    let cellBottomLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        self.backgroundColor = UIColor.whiteColor()
        
        self.status.text = self.orderInfo.status!.description
        self.status.textAlignment = .Left
        
        if self.orderInfo.status!.rawValue == VCAppLetor.OrderStatus.waitForPay.rawValue {
            self.status.textColor = UIColor.orangeColor()
        }
        else {
            self.status.textColor = UIColor.lightGrayColor()
        }
        
        self.status.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.status)
        
        self.title.text = ""
        self.title.textAlignment = .Left
        self.title.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.title.font = VCAppLetor.Font.BigFont
        self.addSubview(self.title)
        
        self.price.text = ""
        self.price.textAlignment = .Left
        self.price.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        self.price.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.price)
        
        self.amount.text = ""
        self.amount.textAlignment = .Left
        self.amount.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        self.amount.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.amount)
        
        if self.orderInfo.status!.rawValue == VCAppLetor.OrderStatus.waitForPay.rawValue {
            
            self.checkButton.backgroundColor = UIColor.whiteColor()
            self.checkButton.setTitle(VCAppLetor.StringLine.CheckNow, forState: UIControlState.Normal)
            self.checkButton.setTitleColor(UIColor.pumpkinColor(), forState: UIControlState.Normal)
            self.checkButton.layer.borderWidth = 1.0
            self.checkButton.layer.borderColor = UIColor.pumpkinColor().CGColor
            self.checkButton.addTarget(self, action: "payNowAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(self.checkButton)
        }
        
        self.cellBottomLine.drawType = "GrayLine"
        self.cellBottomLine.lineWidth = 1.0
        self.addSubview(self.cellBottomLine)
        
        self.addSubview(self.orderImageView)
        self.orderImageView.alpha = 0.2
        
        let imageURL: String = self.orderInfo.orderImageURL!
        
        let progressIndicatorView = UIProgressView(frame: CGRect(x: 10.0, y: 10.0, width: self.width-20.0, height: 4.0))
        self.orderImageView.kf_setImageWithURL(NSURL(string: imageURL)!, placeholderImage: nil, optionsInfo: nil,
            progressBlock: { (receivedSize, totalSize) -> () in
                
                progressIndicatorView.tintColor = UIColor.nephritisColor()
                progressIndicatorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                self.addSubview(progressIndicatorView)
                
                progressIndicatorView.setProgress(Float(receivedSize) / Float(totalSize), animated: true)
                
            },
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                
                let foodImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.width - 20.0, height: 150.0), fitMode: Toucan.Resize.FitMode.Crop)
                self.orderImageView.image = foodImage
                
                self.orderImageView.animation.makeAlpha(1.0).animate(0.2)
                
                progressIndicatorView.removeFromSuperview()
        })
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.orderImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            self.orderImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10.0)
            self.orderImageView.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
            
            if self.orderInfo.status?.rawValue == VCAppLetor.OrderStatus.waitForPay.rawValue {
                
                self.status.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderImageView)
            }
            else {
                self.status.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderImageView, withOffset: 20.0)
            }
            
            self.status.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.orderImageView, withOffset: 10.0)
            self.status.autoSetDimensionsToSize(CGSizeMake(self.width/4.0, 20.0))
            
            
            self.title.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.status)
            self.title.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.status, withOffset: 10.0)
            self.title.autoSetDimensionsToSize(CGSizeMake(self.width/2.0, 26.0))
            
            self.price.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.status)
            self.price.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.title, withOffset: 10.0)
            self.price.autoSetDimensionsToSize(CGSizeMake(self.width/6.0, 20.0))
            
            self.amount.autoPinEdge(.Top, toEdge: .Top, ofView: self.price)
            self.amount.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price)
            self.amount.autoSetDimensionsToSize(CGSizeMake(self.width/6.0, 20.0))
            
            if self.orderInfo.status?.rawValue == VCAppLetor.OrderStatus.waitForPay.rawValue {
                
                self.checkButton.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
                self.checkButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.status)
                self.checkButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 10.0)
            }
            
            self.cellBottomLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.orderImageView)
            self.cellBottomLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderImageView, withOffset: 10.0)
            self.cellBottomLine.autoSetDimensionsToSize(CGSizeMake(self.width-20.0, 3.0))
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Functions
    
    // Submit order action
    func payNowAction() {
        
        let paymentVC: VCPayNowViewController = VCPayNowViewController()
        paymentVC.parentNav = self.parentNav
        paymentVC.orderInfo = self.orderInfo
        self.parentNav!.showViewController(paymentVC, sender: self)
    }
    
    
}
