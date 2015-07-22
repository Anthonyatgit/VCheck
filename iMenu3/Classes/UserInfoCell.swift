//
//  UserInfoCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/15.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class UserInfoCell: UITableViewCell {
    
    var title: UILabel = UILabel.newAutoLayoutView()
    var subTitle: UILabel = UILabel.newAutoLayoutView()
    var avatar: UIImageView = UIImageView.newAutoLayoutView()
    
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
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.backgroundColor = UIColor.clearColor()
        
        self.title.font = VCAppLetor.Font.BigFont
        self.title.textAlignment = .Left
        self.title.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.addSubview(self.title)
        
        
        self.subTitle.font = VCAppLetor.Font.NormalFont
        self.subTitle.textAlignment = .Right
        self.subTitle.textColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        self.addSubview(self.subTitle)
        
        self.avatar.layer.cornerRadius = 22.5
        self.avatar.layer.masksToBounds = true
        self.avatar.hidden = true
        self.addSubview(self.avatar)
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.title.autoSetDimensionsToSize(CGSizeMake(100.0, 20.0))
            self.title.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.title.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.subTitle.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
            self.subTitle.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 32.0)
            self.subTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.avatar.autoSetDimensionsToSize(CGSizeMake(45, 45))
            self.avatar.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 42.0)
            self.avatar.autoAlignAxisToSuperviewAxis(.Horizontal)
            
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