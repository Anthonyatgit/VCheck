//
//  VCGalleryView.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/22.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore
import PureLayout
import DKChainableAnimationKit
import RKDropdownAlert
import HYBLoopScrollView

class VCGalleryView: UIView {
    
    
    var isShow: Bool?
    
    var photos: NSMutableArray = NSMutableArray()
    var photoViewer: HYBLoopScrollView?
    var photoView: UIView = UIView.newAutoLayoutView()
    
    let blackBG: UIView = UIView.newAutoLayoutView()
    var visualEffectView: UIVisualEffectView?
    
    var tapGuestureBG: UITapGestureRecognizer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        
    }
    
    func setupView() {
        
        self.isShow = true
        
        //self.blackBG.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        //self.addSubview(self.blackBG)
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.visualEffectView!.frame = self.frame
        self.visualEffectView!.alpha = 0.1
        
        self.addSubview(self.visualEffectView!)
        
        self.visualEffectView!.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        
        self.photoViewer = HYBLoopScrollView(frame: CGRectMake(0, 0, self.width, self.width), imageUrls: self.photos as [AnyObject]) as HYBLoopScrollView
        self.photoViewer?.alignment = HYBPageControlAlignment.PageControlAlignCenter
        self.photoViewer?.timeInterval = 60
        self.photoViewer?.alpha = 0.1
        self.photoView.addSubview(self.photoViewer!)
        
        self.photoView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.photoView)
        
        self.photoView.autoPinEdgeToSuperviewEdge(.Top, withInset: (self.height-self.width)/2.0)
        self.photoView.autoAlignAxisToSuperviewAxis(.Vertical)
        self.photoView.autoSetDimensionsToSize(CGSizeMake(self.width, self.width))
        
        self.tapGuestureBG = UITapGestureRecognizer(target: self, action: "viewDidTaped:")
        self.tapGuestureBG.numberOfTapsRequired = 1
        self.tapGuestureBG.numberOfTouchesRequired = 1
        
        
        self.visualEffectView!.addGestureRecognizer(self.tapGuestureBG)
        
        self.photoViewer!.animation.makeAlpha(1.0).animate(0.3)
        self.visualEffectView!.animation.makeAlpha(1.0).animate(0.3)
        
    }
    
    func viewDidTaped(tapGuesture: UITapGestureRecognizer) {
        
        self.removeFromSuperview()
    }
    
    
}




