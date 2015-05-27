//
//  CustomDrawView.swift
//  iMenu3
//  
//  Factory Class for Custom UIView Rendering
//
//  Created by Gabriel Anthony on 15/5/12.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import QuartzCore
import PureLayout

class CustomDrawView: UIView {
    
    
    var drawType: String?
    var withTitle: String?
    var lineWidth: CGFloat?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        
        if (self.drawType == "RegStep1") {
            
            CGContextSetLineCap(context, kCGLineCapRound)
            CGContextSetLineWidth(context, 1)
            
            CGContextSetStrokeColorWithColor(context, FlatUIColors.nephritisColor(alpha: 1.0).CGColor)
            CGContextAddArc(context, 26, 22, 20, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            var lengths: [CGFloat] = [1,10]
            CGContextSetLineWidth(context, 2)
            CGContextSetStrokeColorWithColor(context, UIColor.grayColor().colorWithAlphaComponent(0.6).CGColor)
            CGContextSetLineDash(context, 0, lengths, 2)
            CGContextMoveToPoint(context, 80, 22)
            CGContextAddLineToPoint(context, 140, 25)
            CGContextStrokePath(context)
            
            lengths = [1,2]
            CGContextSetLineWidth(context, 1)
            CGContextSetLineDash(context, 0, lengths, 2)
            CGContextAddArc(context, 193, 22, 20, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            let firstStep: UILabel = UILabel.newAutoLayoutView()
            firstStep.text = "1"
            firstStep.font = UIFont.systemFontOfSize(24)
            firstStep.textColor = FlatUIColors.nephritisColor(alpha: 1.0)
            self.addSubview(firstStep)
            firstStep.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            firstStep.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 18.0)
            
            
            let secStep: UILabel = UILabel.newAutoLayoutView()
            secStep.text = "2"
            secStep.font = firstStep.font
            secStep.textColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
            self.addSubview(secStep)
            secStep.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
            secStep.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 20.0)
        }
        else if (self.drawType == "Line") {
            
            CGContextSetLineWidth(context, self.lineWidth!)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextMoveToPoint(context, 0, 1.0)
            CGContextAddLineToPoint(context, self.bounds.width, 1.0)
            CGContextStrokePath(context)
        }
        else if (self.drawType == "LogoutButton") {
            
            println("render")
            
            let logoutButton: UIButton = UIButton.newAutoLayoutView()
            logoutButton.setTitle(self.withTitle, forState: .Normal)
            logoutButton.titleLabel?.font = VCAppLetor.Font.BigFont
            logoutButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            logoutButton.backgroundColor = UIColor.pomegranateColor()
            logoutButton.addTarget(self, action: "Logout", forControlEvents: .TouchUpInside)
            logoutButton.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
            self.addSubview(logoutButton)
            
            logoutButton.autoAlignAxisToSuperviewAxis(.Vertical)
            logoutButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 30.0, relation: NSLayoutRelation.GreaterThanOrEqual)
            logoutButton.autoSetDimensionsToSize(CGSizeMake(280.0, 30.0))
        }
        
        
        
    }
    
    override func updateConstraints() {
        
        
        super.updateConstraints()
    }
    
    
    
}




