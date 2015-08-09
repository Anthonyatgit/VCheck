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
    
    var msgInfo: MessageInfo!
    
    let msgIcon: UIImageView = UIImageView.newAutoLayoutView()
    let msgContent: UILabel = UILabel.newAutoLayoutView()
    let msgDate: UILabel = UILabel.newAutoLayoutView()
    let msgUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var identifier: String?
    var didSetupConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupViews() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.width, 350)
        
        self.msgIcon.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.contentView.addSubview(self.msgIcon)
        if self.msgInfo.type! == "2" {
            self.msgIcon.image = UIImage(named: VCAppLetor.IconName.OrderBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
        else if self.msgInfo.type! == "3" {
            self.msgIcon.image = UIImage(named: VCAppLetor.IconName.AlarmBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
        else if self.msgInfo.type! == "4" {
            self.msgIcon.image = UIImage(named: VCAppLetor.IconName.GiftBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
        
        
        self.msgContent.text = self.msgInfo.content!
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.msgInfo.content!)
        let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
        parag.lineSpacing = 5
        attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.msgInfo.content!)))
        
        self.msgContent.attributedText = attrString
        self.msgContent.sizeToFit()
        self.msgContent.font = VCAppLetor.Font.NormalFont
        self.msgContent.textAlignment = .Left
        self.msgContent.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.msgContent.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.msgContent.numberOfLines = 0
        self.contentView.addSubview(self.msgContent)
        
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateFormatWithoutSeconds
        
        self.msgDate.text = dateFormatter.stringFromDate(self.msgInfo.addDate!)
        self.msgDate.font = VCAppLetor.Font.LightXXSmall
        self.msgDate.textAlignment = .Left
        self.msgDate.textColor = UIColor.lightGrayColor()
        self.msgDate.sizeToFit()
        self.contentView.addSubview(self.msgDate)
        
        if self.msgInfo.is_open == "1" {
            
            self.msgContent.textColor = UIColor.lightGrayColor()
            self.msgDate.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        }
        
        self.msgUnderline.drawType = "GrayLine"
        self.msgUnderline.lineWidth = 1.0
        self.contentView.addSubview(self.msgUnderline)
        
        self.contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            
            self.msgIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            self.msgIcon.autoPinEdgeToSuperviewEdge(.Leading, withInset: 30.0)
            self.msgIcon.autoSetDimensionsToSize(CGSizeMake(20.0, 20.0))
            
            self.msgContent.autoPinEdge(.Top, toEdge: .Top, ofView: self.msgIcon)
            self.msgContent.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.msgIcon, withOffset: 10.0)
            self.msgContent.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
            self.msgContent.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 38.0)
            
            self.msgDate.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.msgContent, withOffset: 10.0)
            self.msgDate.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.msgContent)
            
            self.msgUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.msgDate, withOffset: 10.0)
            self.msgUnderline.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10.0)
            self.msgUnderline.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 14.0)
            self.msgUnderline.autoSetDimension(.Height, toSize: 3.0)
            
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


