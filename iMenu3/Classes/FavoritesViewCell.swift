//
//  FavoritesViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/19.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class FavoritesViewCell: UITableViewCell {
    
    var foodItem: FoodItem!
    
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
        
        setupViews()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        self.backgroundColor = UIColor.whiteColor()
        
        self.onSale.text = self.foodItem.status
        self.onSale.textAlignment = .Left
        self.onSale.textColor = UIColor.orangeColor()
        self.onSale.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.onSale)
        
        self.title.text = self.foodItem.title
        self.title.textAlignment = .Left
        self.title.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.title.font = VCAppLetor.Font.BigFont
        self.addSubview(self.title)
        
        self.price.text = VCAppLetor.StringLine.PricePU + "\(self.foodItem.title)"
        self.price.textAlignment = .Left
        self.price.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        self.price.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.price)
        
        self.checkButton.backgroundColor = UIColor.whiteColor()
        self.checkButton.setTitle(VCAppLetor.StringLine.CheckNow, forState: UIControlState.Normal)
        self.checkButton.setTitleColor(UIColor.pumpkinColor(), forState: UIControlState.Normal)
        self.checkButton.layer.borderWidth = 1.0
        self.checkButton.layer.borderColor = UIColor.pumpkinColor().CGColor
        self.checkButton.addTarget(self, action: "checkNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.checkButton)
        
        self.cellBottomLine.drawType = "GrayLine"
        self.cellBottomLine.lineWidth = 1.0
        self.addSubview(self.cellBottomLine)
        
        self.addSubview(self.foodImageView)
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.foodImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            self.foodImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10.0)
            self.foodImageView.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
            
            self.onSale.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImageView)
            self.onSale.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodImageView, withOffset: 10.0)
            self.onSale.autoSetDimensionsToSize(CGSizeMake(self.width/4.0, 20.0))
            
            self.title.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
            self.title.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.onSale, withOffset: 10.0)
            self.title.autoSetDimensionsToSize(CGSizeMake(self.width/2.0, 26.0))
            
            self.price.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
            self.price.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.title, withOffset: 10.0)
            self.price.autoSetDimensionsToSize(CGSizeMake(self.width/4.0, 20.0))
            
            self.checkButton.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
            self.checkButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.onSale)
            self.checkButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.price, withOffset: 10.0)
            
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
    
    // Submit order action
    func checkNowAction() {
        
        let orderCheckViewController: VCCheckNowViewController = VCCheckNowViewController()
        orderCheckViewController.parentNav = self.parentNav
        orderCheckViewController.foodItem = self.foodItem
        self.parentNav?.showViewController(orderCheckViewController, sender: self)
    }
    
    
}
