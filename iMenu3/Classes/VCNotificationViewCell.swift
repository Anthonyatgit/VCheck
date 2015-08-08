//
//  FoodListTableViewself.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class VCNotificationViewCell: UITableViewCell {
    
    let panelTitle: UILabel = UILabel.newAutoLayoutView()
    let checkBox: ZFCheckbox = ZFCheckbox.newAutoLayoutView()
    
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
        self.accessoryType = UITableViewCellAccessoryType.None
        self.backgroundColor = UIColor.whiteColor()
        
        self.panelTitle.font = VCAppLetor.Font.NormalFont
        self.panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.panelTitle.sizeToFit()
        self.contentView.addSubview(self.panelTitle)
        
        self.checkBox.animateDuration = 0.4
        self.checkBox.lineWidth = 2
        self.checkBox.selected = true
        self.checkBox.lineColor = UIColor.nephritisColor().colorWithAlphaComponent(0.8)
        self.checkBox.lineBackgroundColor = UIColor.nephritisColor().colorWithAlphaComponent(0.8)
        self.checkBox.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.checkBox)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.panelTitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.panelTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.checkBox.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 34.0)
            self.checkBox.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.checkBox.autoSetDimensionsToSize(CGSizeMake(28.0, 28.0))
            
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
