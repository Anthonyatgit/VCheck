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
        
        self.setNeedsUpdateConstraints()
        
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.title.autoSetDimensionsToSize(CGSizeMake(100.0, 20.0))
            self.title.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.title.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            
            
            self.subTitle.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
            self.subTitle.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 32.0)
            self.subTitle.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            
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