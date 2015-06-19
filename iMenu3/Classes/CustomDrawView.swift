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
    var lineColor: UIColor?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        var context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        
        if (self.drawType == "RegStep1") {
            
            CGContextSetLineCap(context, kCGLineCapRound)
            CGContextSetLineWidth(context, 1)
            
            CGContextSetStrokeColorWithColor(context, UIColor.nephritisColor().CGColor)
            CGContextAddArc(context, 26, 22, 12, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            var lengths: [CGFloat] = [1,10]
            CGContextSetLineWidth(context, 2)
            CGContextSetStrokeColorWithColor(context, UIColor.grayColor().colorWithAlphaComponent(0.6).CGColor)
            CGContextSetLineDash(context, 0, lengths, 2)
            CGContextMoveToPoint(context, 80, 22)
            CGContextAddLineToPoint(context, 140, 22)
            CGContextStrokePath(context)
            
            lengths = [1,2]
            CGContextSetLineWidth(context, 1)
            CGContextSetLineDash(context, 0, lengths, 2)
            CGContextAddArc(context, 193, 22, 12, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            let firstStep: UILabel = UILabel.newAutoLayoutView()
            firstStep.text = "1"
            firstStep.font = VCAppLetor.Font.NormalFont
            firstStep.textColor = FlatUIColors.nephritisColor()
            self.addSubview(firstStep)
            firstStep.autoAlignAxisToSuperviewAxis(.Horizontal)
            firstStep.autoPinEdgeToSuperviewEdge(.Leading, withInset: 22.0)
            
            
            let secStep: UILabel = UILabel.newAutoLayoutView()
            secStep.text = "2"
            secStep.font = firstStep.font
            secStep.textColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
            self.addSubview(secStep)
            secStep.autoAlignAxisToSuperviewAxis(.Horizontal)
            secStep.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 23.0)
        }
        else if (self.drawType == "Line") {
            
            CGContextSetLineWidth(context, self.lineWidth!)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextMoveToPoint(context, 0.0, 1.0)
            CGContextAddLineToPoint(context, self.bounds.width, 1.0)
            CGContextStrokePath(context)
        }
        else if (self.drawType == "GrayLine") {
            
            CGContextSetLineWidth(context, self.lineWidth!)
            CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor)
            CGContextMoveToPoint(context, 0.0, 1.0)
            CGContextAddLineToPoint(context, self.bounds.width, 1.0)
            CGContextStrokePath(context)
        }
        else if (self.drawType == "DoubleLine") {
            
            CGContextSetLineWidth(context, 2)
            if self.lineColor != nil {
                CGContextSetStrokeColorWithColor(context, self.lineColor?.CGColor)
            }
            else {
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            }
            
            CGContextMoveToPoint(context, 0.0, 1.0)
            CGContextAddLineToPoint(context, self.bounds.width, 1.0)
            CGContextStrokePath(context)
            
            CGContextSetLineWidth(context, 1)
            CGContextMoveToPoint(context, 0.0, 4.0)
            CGContextAddLineToPoint(context, self.bounds.width, 3.0)
            CGContextStrokePath(context)
        }
        else if (self.drawType == "LogoutButton") {
            
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
        else if (self.drawType == "DateTag") {
            
            CGContextSetLineWidth(context, 28.0)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextMoveToPoint(context, 0.0, 14.0)
            CGContextAddLineToPoint(context, 80.0, 14.0)
            CGContextStrokePath(context)
            
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
            CGContextMoveToPoint(context, 80.0, 0.0)
            CGContextAddLineToPoint(context, 70.0, 14.0)
            CGContextAddLineToPoint(context, 80.0, 28.0)
            CGContextClosePath(context)
            CGContextSetBlendMode(context, kCGBlendModeClear)
            CGContextFillPath(context)
            
        }
        else if (self.drawType == "SubmitTopTip") {
            
            CGContextSetLineWidth(context, 1)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor)
            CGContextAddArc(context, 34, 16, 6, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            let tip: UILabel = UILabel.newAutoLayoutView()
            tip.text = "!"
            tip.textAlignment = .Center
            tip.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            tip.font = VCAppLetor.Font.XSmall
            self.addSubview(tip)
            
            tip.autoPinEdgeToSuperviewEdge(.Leading, withInset: 28.0)
            tip.autoSetDimensionsToSize(CGSizeMake(12.0, 12.0))
            tip.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            
            let tipText: UILabel = UILabel.newAutoLayoutView()
            tipText.text = VCAppLetor.StringLine.CheckNowTip
            tipText.textAlignment = .Center
            tipText.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            tipText.font = VCAppLetor.Font.SmallFont
            self.addSubview(tipText)
            
            tipText.autoPinEdgeToSuperviewEdge(.Leading, withInset: 36.0)
            tipText.autoSetDimensionsToSize(CGSizeMake(200.0, 14.0))
            tipText.autoPinEdgeToSuperviewEdge(.Top, withInset: 8.0)
        }
        else if (self.drawType == "SelectedCircle") {
            
            CGContextSetLineWidth(context, 1)
            CGContextSetFillColorWithColor(context, UIColor.orangeColor().CGColor)
            CGContextAddArc(context, 13, 13, 12, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextFillPath(context)
            
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextMoveToPoint(context, 7, 14)
            CGContextAddLineToPoint(context, 10, 17)
            CGContextAddLineToPoint(context, 19, 10)
            CGContextStrokePath(context)
        }
        else if (self.drawType == "PayTopTip") {
            
            CGContextSetLineWidth(context, 1)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor)
            CGContextAddArc(context, 34, 16, 6, 0, CGFloat(2*VCAppLetor.ConstValue.PI), 0)
            CGContextStrokePath(context)
            
            let tip: UILabel = UILabel.newAutoLayoutView()
            tip.text = "!"
            tip.textAlignment = .Center
            tip.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            tip.font = VCAppLetor.Font.XSmall
            self.addSubview(tip)
            
            tip.autoPinEdgeToSuperviewEdge(.Leading, withInset: 28.0)
            tip.autoSetDimensionsToSize(CGSizeMake(12.0, 12.0))
            tip.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            
            let tipText: UILabel = UILabel.newAutoLayoutView()
            tipText.text = VCAppLetor.StringLine.PayNowTip
            tipText.textAlignment = .Center
            tipText.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            tipText.font = VCAppLetor.Font.SmallFont
            self.addSubview(tipText)
            
            tipText.autoPinEdgeToSuperviewEdge(.Leading, withInset: 36.0)
            tipText.autoSetDimensionsToSize(CGSizeMake(200.0, 14.0))
            tipText.autoPinEdgeToSuperviewEdge(.Top, withInset: 8.0)
        }
        else if self.drawType == "segBG" {
            
            CGContextSetLineWidth(context, 2.0)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor)
            CGContextMoveToPoint(context, 0, 1)
            CGContextAddLineToPoint(context, self.width, 1)
            CGContextStrokePath(context)
            
            CGContextMoveToPoint(context, 0, self.height-1)
            CGContextAddLineToPoint(context, self.width, self.height-1)
            CGContextStrokePath(context)
            
        }
        else if self.drawType == "segFore" {
            
            CGContextSetLineWidth(context, 2.0)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor)
            CGContextMoveToPoint(context, 0, 1)
            CGContextAddLineToPoint(context, self.width, 1)
            CGContextStrokePath(context)
            
            CGContextMoveToPoint(context, 0, self.height-1)
            CGContextAddLineToPoint(context, self.width, self.height-1)
            CGContextStrokePath(context)
            
        }
        
        
        
    }
    
    override func updateConstraints() {
        
        
        super.updateConstraints()
    }
    
    
    
}




