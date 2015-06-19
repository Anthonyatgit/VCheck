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


class FoodDetailScrollView: UIScrollView, UIScrollViewDelegate {
    
    var segmentedControl: SMSegmentView!
    
    var viewType: VCAppLetor.FoodInfoType! {
        didSet {
            self.updateView()
        }
    }
    
    var mapView: BMKMapView!
    
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
        self.bottomLineMenu.autoPinEdgeToSuperviewEdge(.Top, withInset: 200)
        
        self.bottomLineInfo.autoSetDimensionsToSize(CGSizeMake(self.frame.width, 5.0))
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Leading, withInset: self.frame.width * 2)
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Top, withInset: 160)
        
    }
    
    
    func setupView() {
        
        self.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.contentSize.width = self.frame.size.width * 3
        self.contentSize.height = self.frame.size.height
        self.delegate = self
        
        // Map Test
        self.mapView = BMKMapView(frame: CGRectMake(self.width, 0, self.width, 150))
        self.addSubview(self.mapView)
        
        
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
        
        if self.viewType == VCAppLetor.FoodInfoType.spot {
            self.height = self.bottomLineSpot.originY + 20.0
        }
        else if self.viewType == VCAppLetor.FoodInfoType.menu {
            self.height = self.bottomLineMenu.originY + 20.0
        }
        else {
            self.height = self.bottomLineInfo.originY + 20.0
        }
        
        self.contentSize.height = self.height
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageWidth: CGFloat = self.frame.size.width
        let page: CGFloat = self.contentOffset.x / pageWidth
        var pageIndex: Int = 0
        
        if page == 1.0 {
            pageIndex = 1
        }
        else if page == 2.0 {
            pageIndex = 2
        }
        
        self.segmentedControl.selectSegmentAtIndex(pageIndex)
    }
    
    
}
