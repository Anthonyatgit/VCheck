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
    
    var panelIcon: UIImageView = UIImageView.newAutoLayoutView()
    var panelTitle: UILabel = UILabel.newAutoLayoutView()
    
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
        
        self.panelIcon.layer.cornerRadius = VCAppLetor.ConstValue.ImageCornerRadius
        self.panelIcon.alpha = 1.0
        self.contentView.addSubview(self.panelIcon)
        
        self.panelTitle.font = VCAppLetor.Font.BigFont
        self.panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contentView.addSubview(self.panelTitle)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
//            UIView.autoSetPriority(1000) {
//                self.panelIcon.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
//                self.panelTitle.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
//            }
            
            self.panelIcon.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.panelIcon.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            self.panelIcon.autoSetDimensionsToSize(CGSizeMake(VCAppLetor.ConstValue.UserPanelCellIconWidth, VCAppLetor.ConstValue.UserPanelCellIconWidth))
            
            
            self.panelTitle.autoSetDimensionsToSize(CGSizeMake(160.0, 20.0))
            self.panelTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.panelIcon, withOffset: 14.0)
            self.panelTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            
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
