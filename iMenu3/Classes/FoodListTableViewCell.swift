//
//  FoodListTableViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class FoodListTableViewCell: UITableViewCell {
    
    let foodImageView: UIImageView = UIImageView.newAutoLayoutView()
    let foodBrandImageView: UIImageView = UIImageView.newAutoLayoutView()
    let foodDate: UILabel = UILabel.newAutoLayoutView()
    let foodDateBg: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let foodDesc: UILabel = UILabel.newAutoLayoutView()
    let foodPrice: UILabel = UILabel.newAutoLayoutView()
    let foodUnit: UILabel = UILabel.newAutoLayoutView()
    let foodOriginPrice: UILabel = UILabel.newAutoLayoutView()
    let foodOriginPriceStricke: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let foodRemainAmount: UILabel = UILabel.newAutoLayoutView()
    let foodSeparator: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var identifier: String?
    
    var request: Alamofire.Request?
    
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.width, 350)
        
        self.contentView.addSubview(self.foodImageView)
        
        self.foodDateBg.drawType = "DateTag"
        self.foodDateBg.alpha = 0.6
        self.contentView.addSubview(self.foodDateBg)
        
        self.foodDate.text = "2015.06.01"
        self.foodDate.font = VCAppLetor.Font.SmallFont
        self.foodDate.textAlignment = .Left
        self.foodDate.textColor = UIColor.whiteColor()
        self.contentView.addSubview(self.foodDate)
        
        self.foodBrandImageView.backgroundColor = UIColor.whiteColor()
        self.foodBrandImageView.image = UIImage(named: "brand.jpg")
        self.foodBrandImageView.layer.borderWidth = 1.0
        self.foodBrandImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.contentView.addSubview(self.foodBrandImageView)
        
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.numberOfLines = 2
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contentView.addSubview(self.foodTitle)
        
        self.foodDesc.font = VCAppLetor.Font.NormalFont
        self.foodDesc.textColor = UIColor.grayColor()
        self.foodDesc.numberOfLines = 0
        self.foodDesc.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.contentView.addSubview(self.foodDesc)
        
        self.foodPrice.font = VCAppLetor.Font.XLarge
        self.foodPrice.text = "128"
        self.foodPrice.textAlignment = .Left
        self.foodPrice.textColor = UIColor.pumpkinColor()
        self.contentView.addSubview(self.foodPrice)
        
        self.foodUnit.font = VCAppLetor.Font.SmallFont
        self.foodUnit.text = "元/位"
        self.foodUnit.textAlignment = .Left
        self.foodUnit.textColor = UIColor.pumpkinColor()
        self.contentView.addSubview(self.foodUnit)
        
        self.foodOriginPrice.font = VCAppLetor.Font.SmallFont
        self.foodOriginPrice.text = "158元"
        self.foodOriginPrice.textAlignment = .Center
        self.foodOriginPrice.textColor = UIColor.lightGrayColor()
        self.foodOriginPrice.sizeToFit()
        self.contentView.addSubview(self.foodOriginPrice)
        
        self.foodOriginPriceStricke.drawType = "GrayLine"
        self.foodOriginPriceStricke.lineWidth = 1.0
        self.contentView.addSubview(self.foodOriginPriceStricke)
        
        self.foodRemainAmount.font = VCAppLetor.Font.SmallFont
        self.foodRemainAmount.text = "剩余 17 份"
        self.foodRemainAmount.textAlignment = .Left
        self.foodRemainAmount.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(self.foodRemainAmount)
        
        self.foodSeparator.drawType = "DoubleLine"
        self.contentView.addSubview(self.foodSeparator)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.foodImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            self.foodImageView.autoMatchDimension(.Width, toDimension: .Width, ofView: self.contentView, withOffset: -20.0)
            self.foodImageView.autoAlignAxisToSuperviewAxis(.Vertical)
            self.foodImageView.autoSetDimension(.Height, toSize: 150.0)
            
            self.foodDateBg.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
            self.foodDateBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.foodDateBg.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
            
            self.foodDate.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodDateBg, withOffset: 8.0)
            self.foodDate.autoAlignAxis(.Horizontal, toSameAxisOfView: self.foodDateBg)
            self.foodDate.autoSetDimensionsToSize(CGSizeMake(64.0, 14.0))
            
            self.foodBrandImageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 10.0)
            self.foodBrandImageView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView, withOffset: -10.0)
            self.foodBrandImageView.autoSetDimensionsToSize(CGSizeMake(40.0, 40.0))
            
            self.foodTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 20.0)
            self.foodTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView, withOffset: 10.0)
            self.foodTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView, withOffset: -10.0)
            
            self.foodDesc.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 10.0, relation: .GreaterThanOrEqual)
            self.foodDesc.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.foodDesc.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.foodDesc.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50.0)
            
            self.foodSeparator.autoPinEdgeToSuperviewEdge(.Bottom)
            self.foodSeparator.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.foodSeparator.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView)
            self.foodSeparator.autoSetDimension(.Height, toSize: 5.0)
            
            self.foodPrice.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.foodSeparator, withOffset: -10.0)
            self.foodPrice.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodDesc)
            self.foodPrice.autoSetDimensionsToSize(CGSizeMake(38.0, 22.0))
            
            self.foodUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodPrice, withOffset: 4.0)
            self.foodUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodPrice)
            self.foodUnit.autoSetDimensionsToSize(CGSizeMake(34.0, 20.0))
            
            self.foodOriginPrice.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodUnit, withOffset: 26.0)
            self.foodOriginPrice.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodPrice)
            self.foodOriginPrice.autoSetDimensionsToSize(CGSizeMake(42.0, 20.0))
            
            self.foodOriginPriceStricke.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoAlignAxis(.Horizontal, toSameAxisOfView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoMatchDimension(.Width, toDimension: .Width, ofView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoSetDimension(.Height, toSize: 2.0)
            
            self.foodRemainAmount.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodDesc)
            self.foodRemainAmount.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodPrice)
            self.foodRemainAmount.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
            
            
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
    
    
}



