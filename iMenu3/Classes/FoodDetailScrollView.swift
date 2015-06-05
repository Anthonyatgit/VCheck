//
//  FoodDetailScrollView.swift
//  
//
//  Created by Gabriel Anthony on 15/6/4.
//
//

import UIKit
import PureLayout
import Alamofire
import HMSegmentedControl


class FoodDetailScrollView: UIScrollView, UIScrollViewDelegate {
    
    var segmentedControl: SMSegmentView!
    var viewType: VCAppLetor.FoodInfoType! {
        didSet {
            
        }
    }
    
    let bottomLineSpot: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let bottomLineMenu: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let bottomLineInfo: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var spotsContent: [NSDictionary]?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.bottomLineSpot.autoSetDimensionsToSize(CGSizeMake(self.frame.width, 5.0))
        self.bottomLineSpot.autoPinEdgeToSuperviewEdge(.Leading)
        self.bottomLineSpot.autoPinEdgeToSuperviewEdge(.Top, withInset: 180)
        
        self.bottomLineMenu.autoSetDimensionsToSize(CGSizeMake(self.frame.width, 5.0))
        self.bottomLineMenu.autoPinEdgeToSuperviewEdge(.Leading, withInset: self.frame.width)
        self.bottomLineMenu.autoPinEdgeToSuperviewEdge(.Top, withInset: 180)
        
        self.bottomLineInfo.autoSetDimensionsToSize(CGSizeMake(self.frame.width, 5.0))
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Trailing)
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Top, withInset: 180)
        
        
        println("bottom line frame: \(self.bottomLineSpot.frame)")
        
        
        self.autoSetDimension(.Height, toSize: self.bottomLineSpot.originY + 20.0)
        self.contentSize.height = self.frame.size.height
        
        println("detailScroll: \(self.frame) | \(self.contentSize)")
        
    }
    
    
    func setupView() {
        
        self.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.contentSize = self.frame.size
        self.delegate = self
        
        
        
        // Bottom Line
        self.bottomLineSpot.drawType = "DoubleLine"
        self.addSubview(self.bottomLineSpot)
        self.bottomLineMenu.drawType = "DoubleLine"
        self.addSubview(self.bottomLineMenu)
        self.bottomLineInfo.drawType = "DoubleLine"
        self.addSubview(self.bottomLineInfo)
        
        self.setNeedsUpdateConstraints()
        
        
    }
    
    func updateView() {
        
    }
    
    // MARK: - UIScrollView Delegate
    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let pageWidth: CGFloat = self.frame.size.width
//        let page: CGFloat = self.contentOffset.x / pageWidth
//        var pageIndex: Int = 0
//        
//        if page == 1.0 {
//            pageIndex = 1
//        }
//        else if page == 2.0 {
//            pageIndex = 2
//        }
//        
//        self.segmentedControl.selectSegmentAtIndex(pageIndex)
//    }
    
    
}
