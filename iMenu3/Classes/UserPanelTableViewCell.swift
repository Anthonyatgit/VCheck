//
//  FoodListTableViewself.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class UserPanelTableViewCell: UITableViewCell {
    
    let panelIcon: UIImageView = UIImageView.newAutoLayoutView()
    let panelTitle: UILabel = UILabel.newAutoLayoutView()
    let countLabel: UILabel = UILabel.newAutoLayoutView()
    let tipLabel: UILabel = UILabel.newAutoLayoutView()
    
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
        self.backgroundColor = UIColor.whiteColor()
        
        self.panelIcon.layer.cornerRadius = VCAppLetor.ConstValue.ImageCornerRadius
        self.panelIcon.alpha = 1.0
        self.contentView.addSubview(self.panelIcon)
        
        self.panelTitle.font = VCAppLetor.Font.BigFont
        self.panelTitle.textAlignment = .Left
        self.panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contentView.addSubview(self.panelTitle)
        
        self.countLabel.text = ""
        self.countLabel.textAlignment = .Right
        self.countLabel.font = VCAppLetor.Font.NormalFont
        self.countLabel.textColor = UIColor.lightGrayColor()
        self.countLabel.sizeToFit()
        self.contentView.addSubview(self.countLabel)
        
        self.tipLabel.text = ""
        self.tipLabel.textAlignment = .Right
        self.tipLabel.font = VCAppLetor.Font.NormalFont
        self.tipLabel.textColor = UIColor.alizarinColor(alpha: 0.6)
        self.tipLabel.sizeToFit()
        self.contentView.addSubview(self.tipLabel)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.panelIcon.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.panelIcon.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.panelIcon.autoSetDimensionsToSize(CGSizeMake(VCAppLetor.ConstValue.UserPanelCellIconWidth, VCAppLetor.ConstValue.UserPanelCellIconWidth))
            
            self.panelTitle.autoSetDimensionsToSize(CGSizeMake(160.0, 20.0))
            self.panelTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.panelIcon, withOffset: 14.0)
            self.panelTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.countLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            self.countLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.tipLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.countLabel, withOffset: -12.0)
            self.tipLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
            
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
