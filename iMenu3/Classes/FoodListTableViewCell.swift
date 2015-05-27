//
//  FoodListTableViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire

class FoodListTableViewCell: UITableViewCell {
    
    let foodImageView: UIImageView = UIImageView()
    let foodTitle = UILabel()
    let foodDesc = UILabel()
    
    var identifier: String?
    
    var request: Alamofire.Request?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        foodImageView.frame = CGRectMake(0, 0, self.bounds.width, 100)
        foodImageView.bounds = foodImageView.frame
//        foodImageView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
        self.addSubview(foodImageView)
        
        
        foodTitle.frame = CGRectMake(0.0, 110.0, self.bounds.width, 20.0)
        foodTitle.font = VCAppLetor.Font.BigFont
        foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.addSubview(foodTitle)
        
        foodDesc.frame = CGRectMake(0.0, 135.0, self.bounds.width, 65.0)
        foodDesc.font = VCAppLetor.Font.NormalFont
        foodDesc.textColor = UIColor.grayColor()
        foodDesc.numberOfLines = 5
        self.addSubview(foodDesc)
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
