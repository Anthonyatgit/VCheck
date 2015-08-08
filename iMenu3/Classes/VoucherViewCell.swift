//
//  FavoritesViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/19.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import DKChainableAnimationKit

class VoucherViewCell: UITableViewCell {
    
    var voucher: Voucher!
    
    var parentNav: UINavigationController?
    
    let title: UILabel = UILabel.newAutoLayoutView()
    let limitDesc: UILabel = UILabel.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let priceUnit: UILabel = UILabel.newAutoLayoutView()
    let validDateString: UILabel = UILabel.newAutoLayoutView()
    
    let VouImageView: UIImageView = UIImageView.newAutoLayoutView()
    
    let usedTag: UIImageView = UIImageView.newAutoLayoutView()
    let expiredTag: UIImageView = UIImageView.newAutoLayoutView()
    
    let voucherBg: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        
        let goldColor: UIColor = UIColor.goldColor(alpha: 1.0)
        
        
        self.VouImageView.image = nil
        self.VouImageView.backgroundColor = UIColor.cloudsColor()
        
        self.voucherBg.drawType = "voucherBG"
        self.voucherBg.lineColor = UIColor.lightGrayColor()
        
        if self.voucher.status == "1" {
            self.VouImageView.image = UIImage(named: "voucher_black.jpg")
            self.voucherBg.lineColor = goldColor.colorWithAlphaComponent(0.3)
        }
        
        self.addSubview(self.VouImageView)
        self.addSubview(self.voucherBg)
        
        self.price.text = round_price(self.voucher.price!)
        self.price.textAlignment = .Center
        self.price.textColor = UIColor.lightGrayColor()
        self.price.font = VCAppLetor.Font.XXXUltraLight
        self.price.sizeToFit()
        self.addSubview(self.price)
        
        self.priceUnit.text = "元"
        self.priceUnit.textAlignment = .Left
        self.priceUnit.textColor = UIColor.lightGrayColor()
        self.priceUnit.font = VCAppLetor.Font.BigFont
        self.addSubview(self.priceUnit)
        
        self.title.text = self.voucher.title!
        self.title.textAlignment = .Center
        self.title.textColor = UIColor.lightGrayColor()
        self.title.font = VCAppLetor.Font.XSmall
        self.title.sizeToFit()
        self.addSubview(self.title)
        
        self.limitDesc.text = self.voucher.limitDesc
        self.limitDesc.textAlignment = .Center
        self.limitDesc.textColor = UIColor.lightGrayColor()
        self.limitDesc.font = VCAppLetor.Font.XSmall
        self.limitDesc.sizeToFit()
        self.addSubview(self.limitDesc)
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateWithoutTimeFormat
        
        var validStr: String = "有效期"
        validStr += dateFormatter.stringFromDate(self.voucher.startDate!) + "至"
        validStr += dateFormatter.stringFromDate(self.voucher.endDate!)
        
        self.validDateString.text = validStr
        self.validDateString.textAlignment = .Center
        self.validDateString.textColor = UIColor.lightGrayColor()
        self.validDateString.font = VCAppLetor.Font.XSmall
        self.validDateString.sizeToFit()
        self.addSubview(self.validDateString)
        
        
        if self.voucher.status == "1" {
            self.price.textColor = goldColor
            self.priceUnit.textColor = goldColor.colorWithAlphaComponent(0.5)
            self.title.textColor = goldColor.colorWithAlphaComponent(0.5)
            self.limitDesc.textColor = goldColor.colorWithAlphaComponent(0.5)
            self.validDateString.textColor = goldColor.colorWithAlphaComponent(0.5)
        }
        
        if self.voucher.status == "2" {
            
            self.usedTag.image = UIImage(named: "used_tag.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.usedTag.tintColor = UIColor.lightGrayColor()
            self.addSubview(self.usedTag)
        }
        
        if self.voucher.status == "0" {
            
            self.expiredTag.image = UIImage(named: "expired_tag.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.expiredTag.tintColor = UIColor.lightGrayColor()
            self.addSubview(self.expiredTag)
        }
        
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.VouImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10, 20, 10, 20))
            
            self.voucherBg.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0, 0, 0, 0))
            
            self.price.autoPinEdgeToSuperviewEdge(.Top, withInset: 32.0)
            self.price.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.priceUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price, withOffset: 0)
            self.priceUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.price)
            
            self.title.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 10.0)
            self.title.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.limitDesc.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.title, withOffset: 3.0)
            self.limitDesc.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.validDateString.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.limitDesc, withOffset: 3.0)
            self.validDateString.autoAlignAxisToSuperviewAxis(.Vertical)
            
            if self.voucher.status == "2" {
                
                self.usedTag.autoPinEdge(.Top, toEdge: .Top, ofView: self.VouImageView)
                self.usedTag.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.VouImageView)
                self.usedTag.autoSetDimensionsToSize(CGSizeMake(70.0, 65.0))
            }
            
            if self.voucher.status == "0" {
                
                self.expiredTag.autoPinEdge(.Top, toEdge: .Top, ofView: self.VouImageView)
                self.expiredTag.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.VouImageView)
                self.expiredTag.autoSetDimensionsToSize(CGSizeMake(70.0, 65.0))
            }
            
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
    
    
}
