//
//  OrderListViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import DKChainableAnimationKit
import SWTableViewCell

class OrderListViewCell: UITableViewCell {
    
    var orderInfo: OrderInfo!
    
    var index: Int!
    var parentVC: OrderListViewController!
    
    var imageCache: NSCache?
    
    var parentNav: UINavigationController?
    
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let typeDescription: UILabel = UILabel.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let amount: UILabel = UILabel.newAutoLayoutView()
    let payButton: UIButton = UIButton.newAutoLayoutView()
    
    let finalPayPrice: UILabel = UILabel.newAutoLayoutView()
    let discount: UILabel = UILabel.newAutoLayoutView()
    
    let foodImageView: UIImageView = UIImageView.newAutoLayoutView()
    
    let cellBottomLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupViews() {
        
        self.setOrderStatus()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.foodImageView)
        
        let imageURL: String = self.orderInfo.orderImageURL!
        
        if let image = self.imageCache!.objectForKey(imageURL) as? UIImage {
            self.foodImageView.image = image
        }
        else {
            
            self.foodImageView.image = nil
            
            Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                
                (_, _, image, error) in
                
                if error == nil && image != nil {
                    
                    let foodImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: 120.0, height: 100.0), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    self.imageCache!.setObject(foodImage, forKey: imageURL)
                    
                    self.foodImageView.image = foodImage
                }
            }
        }
        
        
        if self.orderInfo.orderType! == "10" {
            
            self.typeDescription.textColor = UIColor.orangeColor()
        }
        else if self.orderInfo.orderType! == "31" {
            
            self.typeDescription.textColor = UIColor.sunflowerColor()
        }
        else if self.orderInfo.orderType! == "32" {
            
            self.typeDescription.textColor = UIColor.nephritisColor()
        }
        else if self.orderInfo.orderType! == "21" {
            
            self.typeDescription.textColor = UIColor.belizeHoleColor()
        }
        else if self.orderInfo.orderType! == "22" {
            
            self.typeDescription.textColor = UIColor.wetAsphaltColor()
        }
        else {
            self.typeDescription.textColor = UIColor.lightGrayColor()
        }
        self.typeDescription.text = self.orderInfo.typeDescription!
        self.typeDescription.textAlignment = .Left
        self.typeDescription.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.typeDescription)
        
        self.foodTitle.text = self.orderInfo.title!
        self.foodTitle.textAlignment = .Left
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.foodTitle.font = VCAppLetor.Font.BigFont
        self.addSubview(self.foodTitle)
        
        self.price.text = VCAppLetor.StringLine.PricePU + round_price(self.orderInfo.pricePU!) + self.orderInfo.priceUnit!
        self.price.textAlignment = .Left
        self.price.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        self.price.font = VCAppLetor.Font.SmallFont
        self.price.sizeToFit()
        self.addSubview(self.price)
        
        //let amountValue = round_price("\((self.orderInfo.totalPrice! as NSString).floatValue / (self.orderInfo.pricePU! as NSString).floatValue)")
        self.amount.text = "\(VCAppLetor.StringLine.AmountName): \(self.orderInfo.itemCount!)"
        self.amount.textAlignment = .Left
        self.amount.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        self.amount.font = VCAppLetor.Font.SmallFont
        self.amount.sizeToFit()
        self.addSubview(self.amount)
        
        self.payButton.backgroundColor = UIColor.whiteColor()
        self.payButton.setTitle(VCAppLetor.StringLine.PayNow, forState: UIControlState.Normal)
        self.payButton.setTitleColor(UIColor.nephritisColor(), forState: UIControlState.Normal)
        self.payButton.titleLabel?.font = VCAppLetor.Font.SmallFont
        self.payButton.layer.borderWidth = 1.0
        self.payButton.layer.borderColor = UIColor.nephritisColor().CGColor
        self.payButton.tag = self.index
        self.payButton.addTarget(self, action: "payNowAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.payButton)
        
        if self.orderInfo.voucherPrice! != "" {
            
            self.discount.text = "-" + round_price(self.orderInfo.voucherPrice!) + self.orderInfo.priceUnit!
            self.discount.textAlignment = .Center
            self.discount.textColor = UIColor.whiteColor()
            self.discount.font = VCAppLetor.Font.SmallFont
            self.discount.layer.backgroundColor = UIColor.alizarinColor(alpha: 0.6).CGColor
            self.discount.layer.cornerRadius = 2.0
            self.addSubview(self.discount)
            
        }
        
        
        
        self.cellBottomLine.drawType = "GrayLine"
        self.cellBottomLine.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.addSubview(self.cellBottomLine)
        
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    
    func setConstraints() {
        
        
    }
    
    func updateCellConstraints() {
        
        
        self.foodImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
        self.foodImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10.0)
        self.foodImageView.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
        
        self.typeDescription.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImageView)
        self.typeDescription.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodImageView, withOffset: 10.0)
        self.typeDescription.autoSetDimensionsToSize(CGSizeMake(self.width-120-30, 18.0))
        
        self.foodTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.typeDescription)
        self.foodTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.typeDescription, withOffset: 6.0)
        self.foodTitle.autoSetDimensionsToSize(CGSizeMake(self.width-120-30, 20.0))
        
        self.price.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.typeDescription)
        self.price.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 8.0)
        
        self.amount.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price, withOffset: 8.0)
        self.amount.autoPinEdge(.Top, toEdge: .Top, ofView: self.price, withOffset: 0.0)
        
        self.payButton.autoSetDimensionsToSize(CGSizeMake(80.0, 26.0))
        self.payButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.typeDescription)
        self.payButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 6.0)
        
        if self.orderInfo.voucherPrice! != "" {
            
            self.discount.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.typeDescription)
            self.discount.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 10.0)
            self.discount.autoSetDimensionsToSize(CGSizeMake(56.0, 18.0))
            
        }
        
        self.cellBottomLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
        self.cellBottomLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 10.0)
        self.cellBottomLine.autoSetDimensionsToSize(CGSizeMake(self.width-20.0, 3.0))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Functions
    
    
    func payNowAction(btn: UIButton) {
        
        // Transfer to payment page
        let paymentVC: VCPayNowViewController = VCPayNowViewController()
        paymentVC.parentNav = self.parentNav
        paymentVC.foodDetailVC = self.parentVC
        paymentVC.orderInfo = self.orderInfo
        self.parentNav?.showViewController(paymentVC, sender: self)
    }
    
    func setOrderStatus() {
        
        if self.orderInfo.orderType == "10" {
            self.orderInfo.status = VCAppLetor.OrderType.waitForPay
        } else if self.orderInfo.orderType == "20" {
            self.orderInfo.status = VCAppLetor.OrderType.paid
        } else if self.orderInfo.orderType == "21" {
            self.orderInfo.status = VCAppLetor.OrderType.paidWithoutUsed
        } else if self.orderInfo.orderType == "22" {
            self.orderInfo.status = VCAppLetor.OrderType.paidWithUsed
        } else if self.orderInfo.orderType == "30" {
            self.orderInfo.status = VCAppLetor.OrderType.refund
        } else if self.orderInfo.orderType == "31" {
            self.orderInfo.status = VCAppLetor.OrderType.refundInProgress
        } else if self.orderInfo.orderType == "32" {
            self.orderInfo.status = VCAppLetor.OrderType.refunded
        } else if self.orderInfo.orderType == "50" {
            self.orderInfo.status = VCAppLetor.OrderType.expired
        } else if self.orderInfo.orderType == "51" {
            self.orderInfo.status = VCAppLetor.OrderType.waitForPayExpired
        } else if self.orderInfo.orderType == "52" {
            self.orderInfo.status = VCAppLetor.OrderType.paidExpired
        } else if self.orderInfo.orderType == "70" {
            self.orderInfo.status = VCAppLetor.OrderType.deleted
        } else if self.orderInfo.orderType == "71" {
            self.orderInfo.status = VCAppLetor.OrderType.waitForPayDeleted
        } else if self.orderInfo.orderType == "72" {
            self.orderInfo.status = VCAppLetor.OrderType.waitForPayExpiredDeleted
        } else if self.orderInfo.orderType == "73" {
            self.orderInfo.status = VCAppLetor.OrderType.paidWithUsedDeleted
        } else if self.orderInfo.orderType == "74" {
            self.orderInfo.status = VCAppLetor.OrderType.refundedDeleted
        }
    }
    
}

