//
//  FoodCollectionsViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/29.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit

class FoodCollectionsViewCell: UICollectionViewCell {
    
    var foodImageView: UIImageView = UIImageView()
    var iconImageView: UIImageView = UIImageView()
    var foodTitle: UILabel = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        foodImageView.frame = CGRectMake(10.0, 10.0, self.bounds.width - 20.0, self.bounds.width - 20.0)
        self.addSubview(foodImageView)
        
        let transBG = UIView(frame: foodImageView.frame)
        transBG.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.addSubview(transBG)
        
        iconImageView.center = foodImageView.center
        iconImageView.bounds.size = CGSizeMake(50.0, 50.0)
        self.addSubview(iconImageView)
        
        foodTitle.frame = CGRectMake(10.0, 10.0+self.bounds.width-20.0+10.0, self.bounds.width-20.0, 30.0)
        foodTitle.numberOfLines = 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
