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
import DKChainableAnimationKit

class FoodListTableViewCell: UITableViewCell {
    
    var foodInfo: FoodInfo!
    
    var imageCache: NSCache?
    
    let foodImagePlaceholder: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let foodImageView: UIImageView = UIImageView.newAutoLayoutView()
    let foodBrandImageView: UIImageView = UIImageView.newAutoLayoutView()
    let brandName: UILabel = UILabel.newAutoLayoutView()
    let shimmerView: FBShimmeringView = FBShimmeringView.newAutoLayoutView()
    let foodDate: UILabel = UILabel.newAutoLayoutView()
    let foodDateBg: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let foodDateBg2: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let foodDesc: UILabel = UILabel.newAutoLayoutView()
    let foodSubTitle: UILabel = UILabel.newAutoLayoutView()
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
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.width, 350)
        
        self.foodImagePlaceholder.drawType = "imageplcadeholder"
        self.contentView.addSubview(self.foodImagePlaceholder)
        
        
        self.foodDateBg.drawType = "DateTagLong"
        self.foodDateBg.alpha = 0.4 //0.4
        self.contentView.addSubview(self.foodDateBg)
        
        self.foodDateBg2.drawType = "DateTag"
        self.foodDateBg2.alpha = 0.8 // 0.8
        self.contentView.addSubview(self.foodDateBg2)
        
        //        self.shimmerView.shimmering = true
        //        self.shimmerView.shimmeringOpacity = 1.0
        //        self.shimmerView.shimmeringPauseDuration = 3.0
        //        self.shimmerView.shimmeringSpeed = 100
        //        self.foodDateBg2.addSubview(self.shimmerView)
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateWithoutTimeFormat
        
        self.foodDate.text = dateFormatter.stringFromDate(self.foodInfo.addDate!)
        self.foodDate.font = VCAppLetor.Font.XSmall
        self.foodDate.textAlignment = .Left
        self.foodDate.textColor = UIColor.whiteColor()
        self.foodDate.alpha = 1.0 // 1.0
        self.foodDateBg2.addSubview(self.foodDate)
        
        let imageURL = self.foodInfo.foodImage!
        
        self.foodImageView.backgroundColor = UIColor.clearColor()
        //self.foodImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(self.foodImageView)
        
        
        if let image = self.imageCache!.objectForKey(imageURL) as? UIImage {
            self.foodImageView.image = image
        }
        else {
            
            self.foodImageView.image = nil
            
            Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                
                (_, _, image, error) in
                
                if error == nil && image != nil {
                    
                    let imageHeight: CGFloat = (self.contentView.width-20.0) * 0.54
                    let foodImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.contentView.width - 20.0, height: imageHeight), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    self.imageCache!.setObject(foodImage, forKey: imageURL)
                    
                    self.foodImageView.image = foodImage
                }
            }
            
            
        }
        
//        self.foodImageView.animation.makeAlpha(1.0).animate(1.0)
        
        
        
        self.foodBrandImageView.backgroundColor = UIColor.whiteColor()
        self.foodBrandImageView.layer.cornerRadius = 25.0
        self.foodBrandImageView.layer.masksToBounds = true
        let storeImageURL = self.foodInfo.memberIcon!
        
        self.contentView.addSubview(self.foodBrandImageView)
        
        if let brandImage = self.imageCache!.objectForKey(storeImageURL) as? UIImage {
            self.foodBrandImageView.image = brandImage
        }
        else {
            
            self.foodBrandImageView.image = nil
            
            Alamofire.request(.GET, storeImageURL).validate(contentType: ["image/*"]).responseImage() {
                
                (_, _, image, error) in
                
                if error == nil && image != nil {
                    
                    let storeIcon: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: 40.0, height: 40.0), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    self.imageCache!.setObject(storeIcon, forKey: storeImageURL)
                    
                    self.foodBrandImageView.image = storeIcon
                }
            }
        }
        
        self.brandName.text = self.foodInfo.memberName!
        self.brandName.textAlignment = .Center
        self.brandName.textColor = UIColor.whiteColor()
        self.brandName.font = VCAppLetor.Font.NormalFont
        self.brandName.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.brandName.shadowOffset = CGSizeMake(1.0, 1.0)
        self.brandName.sizeToFit()
        self.contentView.addSubview(self.brandName)
        
        self.foodBrandImageView.layer.borderWidth = 1.0
        self.foodBrandImageView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor
        
        self.foodTitle.text = self.foodInfo.title
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.numberOfLines = 2
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contentView.addSubview(self.foodTitle)
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.foodInfo.subTitle!)
        let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
        parag.lineSpacing = 5
        attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.foodInfo.subTitle!)))
        self.foodSubTitle.attributedText = attrString
        self.foodSubTitle.sizeToFit()
        
        self.foodSubTitle.text = self.foodInfo.subTitle
        self.foodSubTitle.textAlignment = .Left
        self.foodSubTitle.textColor = UIColor.grayColor()
        self.foodSubTitle.font = VCAppLetor.Font.NormalFont
        self.contentView.addSubview(self.foodSubTitle)
        
//        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.foodInfo.desc!)
//        let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
//        parag.lineSpacing = 5
//        attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.foodInfo.desc!)))
//        self.foodDesc.attributedText = attrString
//        self.foodDesc.sizeToFit()
//        
//        self.foodDesc.font = VCAppLetor.Font.NormalFont
//        self.foodDesc.textColor = UIColor.grayColor()
//        self.foodDesc.numberOfLines = 0
//        self.foodDesc.lineBreakMode = NSLineBreakMode.ByTruncatingTail
//        self.contentView.addSubview(self.foodDesc)
        
        if self.foodInfo.price! != "0" && self.foodInfo.price! != "" {
            
            self.foodPrice.font = VCAppLetor.Font.Light
            self.foodPrice.text = round_price(self.foodInfo.price!)
            self.foodPrice.textAlignment = .Right
            self.foodPrice.textColor = UIColor.pumpkinColor()
            self.foodPrice.sizeToFit()
            self.contentView.addSubview(self.foodPrice)
            
            self.foodUnit.font = VCAppLetor.Font.SmallFont
            self.foodUnit.text = "\(self.foodInfo.priceUnit!)/\(self.foodInfo.unit!)"
            self.foodUnit.textAlignment = .Right
            self.foodUnit.textColor = UIColor.pumpkinColor()
            self.foodUnit.sizeToFit()
            self.contentView.addSubview(self.foodUnit)
            
            self.foodOriginPrice.font = VCAppLetor.Font.LightXSmall
            self.foodOriginPrice.text = round_price(self.foodInfo.originalPrice!) + self.foodInfo.priceUnit!
            self.foodOriginPrice.textAlignment = .Center
            self.foodOriginPrice.textColor = UIColor.lightGrayColor()
            self.foodOriginPrice.sizeToFit()
            self.contentView.addSubview(self.foodOriginPrice)
            
            self.foodOriginPriceStricke.drawType = "GrayLine"
            self.foodOriginPriceStricke.lineWidth = 1.0
            self.contentView.addSubview(self.foodOriginPriceStricke)
        }
        else {
            
            self.foodPrice.font = VCAppLetor.Font.Light
            self.foodPrice.text = round_price(self.foodInfo.originalPrice!)
            self.foodPrice.textAlignment = .Right
            self.foodPrice.textColor = UIColor.pumpkinColor()
            self.foodPrice.sizeToFit()
            self.contentView.addSubview(self.foodPrice)
            
            self.foodUnit.font = VCAppLetor.Font.SmallFont
            self.foodUnit.text = "\(self.foodInfo.priceUnit!)/\(self.foodInfo.unit!)"
            self.foodUnit.textAlignment = .Right
            self.foodUnit.textColor = UIColor.pumpkinColor()
            self.foodUnit.sizeToFit()
            self.contentView.addSubview(self.foodUnit)
            
            self.foodOriginPrice.font = VCAppLetor.Font.LightXSmall
            self.foodOriginPrice.text = round_price(self.foodInfo.originalPrice!) + self.foodInfo.priceUnit!
            self.foodOriginPrice.textAlignment = .Center
            self.foodOriginPrice.textColor = UIColor.lightGrayColor()
            self.foodOriginPrice.sizeToFit()
            self.foodOriginPrice.alpha = 0
            self.contentView.addSubview(self.foodOriginPrice)
            
            self.foodOriginPriceStricke.drawType = "GrayLine"
            self.foodOriginPriceStricke.lineWidth = 1.0
            self.foodOriginPriceStricke.alpha = 0
            self.contentView.addSubview(self.foodOriginPriceStricke)
        }
        
        
        
        var displayAmount: String = ""
        self.foodRemainAmount.textColor = UIColor.lightGrayColor()
        
        if self.foodInfo.remainingCount! == "0" {
            displayAmount = self.foodInfo.outOfStock!
        }
        else {
            displayAmount = "剩余 \(self.foodInfo.remainingCount!) \(self.foodInfo.remainingCountUnit!)"
            if (self.foodInfo.remainingCount! as NSString).integerValue <= VCAppLetor.ConstValue.StockAlertPoint {
                
                self.foodRemainAmount.textColor = UIColor.orangeColor()
            }
        }
        
        if self.foodInfo.remainder == "0" {
            displayAmount = VCAppLetor.StringLine.isClose
        }
        
        
        self.foodRemainAmount.font = VCAppLetor.Font.SmallFont
        self.foodRemainAmount.text = displayAmount
        self.foodRemainAmount.textAlignment = .Left
        self.foodRemainAmount.sizeToFit()
        self.contentView.addSubview(self.foodRemainAmount)
        
        self.foodSeparator.drawType = "DoubleLine"
        self.contentView.addSubview(self.foodSeparator)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            let imageHeight: CGFloat = (self.contentView.width-20.0) * 0.66
            
            self.foodImagePlaceholder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10, 10, 0, 10), excludingEdge: .Bottom)
            self.foodImagePlaceholder.autoSetDimension(.Height, toSize: imageHeight)
            
            self.foodImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10, 10, 0, 10), excludingEdge: .Bottom)
            self.foodImageView.autoSetDimension(.Height, toSize: imageHeight)
            
            self.foodDateBg.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
            self.foodDateBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.foodDateBg.autoSetDimensionsToSize(CGSizeMake(90.0, 28.0))
            
            self.foodDateBg2.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
            self.foodDateBg2.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.foodDateBg2.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
            
            self.foodDate.autoPinEdgeToSuperviewEdge(.Leading, withInset: 4.0)
            self.foodDate.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.foodDate.autoSetDimensionsToSize(CGSizeMake(68.0, 14.0))
            
//            self.shimmerView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 4.0)
//            self.shimmerView.autoAlignAxisToSuperviewAxis(.Horizontal)
//            self.shimmerView.autoSetDimensionsToSize(CGSizeMake(68.0, 14.0))
            
            self.foodBrandImageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 10.0)
            self.foodBrandImageView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView, withOffset: -10.0)
            self.foodBrandImageView.autoSetDimensionsToSize(CGSizeMake(50.0, 50.0))
            
            self.brandName.autoAlignAxis(.Horizontal, toSameAxisOfView: self.foodBrandImageView)
            self.brandName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.foodBrandImageView, withOffset: -10.0)
            
            self.foodTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 20.0)
            self.foodTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView, withOffset: 10.0)
            self.foodTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView, withOffset: -10.0)
            
            self.foodSubTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 10.0)
            self.foodSubTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.foodSubTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.foodSubTitle.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50.0)
            
//            self.foodDesc.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 10.0)
//            self.foodDesc.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
//            self.foodDesc.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
//            self.foodDesc.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50.0)
            
            self.foodSeparator.autoPinEdgeToSuperviewEdge(.Bottom)
            self.foodSeparator.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.foodSeparator.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodImageView)
            self.foodSeparator.autoSetDimension(.Height, toSize: 5.0)
            
            self.foodRemainAmount.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.foodRemainAmount.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.foodSeparator, withOffset: -10.0)
            
            self.foodUnit.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.foodUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodRemainAmount)
            
            self.foodPrice.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodRemainAmount, withOffset: 2.0)
            self.foodPrice.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.foodUnit, withOffset: -2.0)
            
            self.foodOriginPrice.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.foodPrice, withOffset: -16.0)
            self.foodOriginPrice.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodRemainAmount)
            
            self.foodOriginPriceStricke.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoAlignAxis(.Horizontal, toSameAxisOfView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoMatchDimension(.Width, toDimension: .Width, ofView: self.foodOriginPrice)
            self.foodOriginPriceStricke.autoSetDimension(.Height, toSize: 2.0)
            
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



