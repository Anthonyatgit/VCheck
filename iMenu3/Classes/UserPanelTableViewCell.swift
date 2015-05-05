//
//  FoodListTableViewCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit

class UserPanelTableViewCell: UITableViewCell {
    
    var panelIcon: UIImageView = UIImageView()
    var panelTitle: UILabel = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        panelIcon.frame = CGRectMake(18.0, 13.0, 24.0, 24.0)
        self.addSubview(panelIcon)
        
        panelTitle.frame = CGRectMake(56.0, 15.0, 100.0, 20.0)
        panelTitle.font = BIGFONT
        panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.addSubview(panelTitle)
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
