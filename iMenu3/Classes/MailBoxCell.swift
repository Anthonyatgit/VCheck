//
//  MailBoxCell.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/17.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class MailBoxCell: UITableViewCell {
    
    
    var identifier: String?
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
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.width, 350)
        
        
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            
            
            
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


