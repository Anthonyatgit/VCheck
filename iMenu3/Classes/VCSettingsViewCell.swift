//
//  FoodListTableViewself.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class VCSettingsViewCell: UITableViewCell {
    
    let panelTitle: UILabel = UILabel.newAutoLayoutView()
    let descLabel: UILabel = UILabel.newAutoLayoutView()
    
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
        
        self.panelTitle.font = VCAppLetor.Font.BigFont
        self.panelTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.panelTitle.sizeToFit()
        self.contentView.addSubview(self.panelTitle)
        
        self.descLabel.text = ""
        self.descLabel.font = VCAppLetor.Font.NormalFont
        self.descLabel.textColor = UIColor.lightGrayColor()
        self.descLabel.sizeToFit()
        self.contentView.addSubview(self.descLabel)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.panelTitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 18.0)
            self.panelTitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            self.descLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
            self.descLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
            
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
