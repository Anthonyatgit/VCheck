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

class FavoritesViewCell: UITableViewCell {
    
    var favInfo: FoodInfo!
    
    var imageCache: NSCache?
    
    var parentNav: UINavigationController?
    
    let title: UILabel = UILabel.newAutoLayoutView()
    let onSale: UILabel = UILabel.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let checkButton: UIButton = UIButton.newAutoLayoutView()
    
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
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.foodImageView)
        
        let imageURL: String = self.favInfo.foodImage!
        
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

        if self.favInfo.remainder != "0" { // onSale
            
            self.onSale.textColor = UIColor.orangeColor()
            self.onSale.text = VCAppLetor.StringLine.FavOnSale
        }
        else { // not onSale
            self.onSale.textColor = UIColor.lightGrayColor()
            self.onSale.text = VCAppLetor.StringLine.FavOffSale
        }
        
        self.onSale.textAlignment = .Left
        self.onSale.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.onSale)
        
        self.title.text = self.favInfo.subTitle!
        self.title.textAlignment = .Left
        self.title.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.title.font = VCAppLetor.Font.BigFont
        self.addSubview(self.title)
        
        self.price.text = VCAppLetor.StringLine.PricePU + round_price(self.favInfo.price!) + self.favInfo.priceUnit!
        self.price.textAlignment = .Left
        self.price.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        self.price.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.price)
        
        if self.favInfo.remainder != "0" { // onSale
            
            self.checkButton.backgroundColor = UIColor.whiteColor()
            self.checkButton.setTitle(VCAppLetor.StringLine.CheckNow, forState: UIControlState.Normal)
            self.checkButton.setTitleColor(UIColor.pumpkinColor(), forState: UIControlState.Normal)
            self.checkButton.titleLabel?.font = VCAppLetor.Font.SmallFont
            self.checkButton.layer.borderWidth = 1.0
            self.checkButton.layer.borderColor = UIColor.orangeColor().CGColor
            self.addSubview(self.checkButton)
        }
        
        self.cellBottomLine.drawType = "GrayLine"
        self.cellBottomLine.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.addSubview(self.cellBottomLine)
        
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.foodImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            self.foodImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10.0)
            self.foodImageView.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
            
            if self.favInfo.remainder != "0" {
                self.onSale.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImageView)
            }
            else {
                self.onSale.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImageView, withOffset: 10.0)
            }
            self.onSale.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodImageView, withOffset: 10.0)
            self.onSale.autoSetDimensionsToSize(CGSizeMake(self.width-120-30, 18.0))
            
            self.title.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
            self.title.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.onSale, withOffset: 6.0)
            self.title.autoSetDimensionsToSize(CGSizeMake(self.width-120-30, 20.0))
            
            self.price.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
            self.price.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.title, withOffset: 8.0)
            self.price.autoSetDimensionsToSize(CGSizeMake(self.width-120-30, 16.0))
            
            if self.favInfo.remainder != "0" {
                
                self.checkButton.autoSetDimensionsToSize(CGSizeMake(80.0, 26.0))
                self.checkButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
                self.checkButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 6.0)
            }
            
            self.cellBottomLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImageView)
            self.cellBottomLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImageView, withOffset: 10.0)
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
    
    
}
