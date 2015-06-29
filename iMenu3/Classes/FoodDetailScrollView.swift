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


class FoodDetailScrollView: UIScrollView{
    
    var foodInfo: FoodInfo!
    
    var segmentedControl: SMSegmentView!
    
    var viewType: VCAppLetor.FoodInfoType! {
        didSet {
            self.updateView()
        }
    }
    
    let imageCache = NSCache()
    
    let spotView: UIView = UIView.newAutoLayoutView()
    
    var mapView: BMKMapView!
    
    var spotHeight: CGFloat = 0.0
    
    var lastEl: UILabel = UILabel.newAutoLayoutView()
    let bottomLineSpot: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var lastMenuEl: UILabel = UILabel.newAutoLayoutView()
    let bottomLineMenu: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let bottomLineInfo: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var didSetConstraints = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func updateConstraints() {
        
        if !self.didSetConstraints {
            self.didSetConstraints = true
        }
        
        super.updateConstraints()
        
        
    }
    
    
    func setupView() {
        
        self.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.pagingEnabled = true
        self.scrollEnabled = false
        self.showsHorizontalScrollIndicator = false
//        self.contentSize.width = self.width * 3
//        self.contentSize.height = self.height
        
        self.addSubview(self.spotView)
        
        self.spotView.autoSetDimensionsToSize(CGSizeMake(self.width, self.height))
        self.spotView.autoPinEdgeToSuperviewEdge(.Top)
        self.spotView.autoPinEdgeToSuperviewEdge(.Leading)
        
        // Spot
        for var i=0; i<self.foodInfo.contentImages?.count; i++ {
            
            
            let slideImageView: UIImageView = UIImageView(frame: CGRectMake(0, self.spotHeight, self.width, 200))
            
            let imageURL = self.foodInfo.contentImages?.objectAtIndex(i) as! String
            
            self.addSubview(slideImageView)
            
            if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
                slideImageView.image = image
            }
            else {
                
                slideImageView.image = nil
                
                Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                    
                    (_, _, image, error) in
                    
                    if error == nil && image != nil {
                        
                        let slideImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.width - 40.0, height: 200), fitMode: Toucan.Resize.FitMode.Crop)
                        
                        self.imageCache.setObject(slideImage, forKey: imageURL)
                        
                        slideImageView.image = slideImage
                    }
                }
            }
            
            self.spotHeight += 220
            
            let titleX: UILabel = UILabel(frame: CGRectMake(0, self.spotHeight, self.width, 24.0))
            titleX.text = self.foodInfo.contentTitles?.objectAtIndex(i) as? String
            titleX.textAlignment = .Left
            titleX.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            titleX.font = VCAppLetor.Font.BigFont
            titleX.numberOfLines = 2
            self.addSubview(titleX)
            
            self.spotHeight += 44
            
            
            let descX: UILabel = UILabel.newAutoLayoutView()
            
            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.foodInfo.contentDesc?.objectAtIndex(i) as! String)
            let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
            parag.lineSpacing = 5
            attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.foodInfo.contentDesc?.objectAtIndex(i) as! String)))
            descX.attributedText = attrString
            descX.sizeToFit()
            
//            descX.text = self.foodInfo.subTitle
            descX.textAlignment = .Left
            descX.textColor = UIColor.grayColor()
            descX.font = VCAppLetor.Font.NormalFont
            self.addSubview(descX)
            
            self.lastEl = descX
            
            
            // Layout
//            if i == 0 {
//                slideImageView.autoPinEdgeToSuperviewEdge(.Top)
//            }
//            else {
//                slideImageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.lastEl, withOffset: 20.0)
//            }
//            
//            slideImageView.autoPinEdgeToSuperviewEdge(.Leading)
//            slideImageView.autoSetDimensionsToSize(CGSizeMake(self.width, 200.0))
//            
//            titleX.autoPinEdge(.Leading, toEdge: .Leading, ofView: slideImageView)
//            titleX.autoPinEdge(.Top, toEdge: .Bottom, ofView: slideImageView, withOffset: 20.0)
//            titleX.autoSetDimensionsToSize(CGSizeMake(self.width, 24.0))
//            
//            descX.autoPinEdge(.Leading, toEdge: .Leading, ofView: slideImageView)
//            descX.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleX, withOffset: 20.0)
//            descX.autoSetDimension(.Width, toSize: self.width)
//            descX.autoSetDimension(.Height, toSize: 50.0, relation: NSLayoutRelation.GreaterThanOrEqual)
            
        }
        
        
        
        // Bottom Line
        self.bottomLineSpot.drawType = "DoubleLine"
        self.addSubview(self.bottomLineSpot)
        self.bottomLineMenu.drawType = "DoubleLine"
        self.addSubview(self.bottomLineMenu)
        self.bottomLineInfo.drawType = "DoubleLine"
        self.addSubview(self.bottomLineInfo)
        
        self.setupBottomConstraints()
        
    }
    
    func setupBottomConstraints() {
        
        self.bottomLineSpot.autoSetDimensionsToSize(CGSizeMake(self.width, 5.0))
        self.bottomLineSpot.autoPinEdgeToSuperviewEdge(.Leading)
        self.bottomLineSpot.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.lastEl, withOffset: 20.0)
        
        self.bottomLineMenu.autoSetDimensionsToSize(CGSizeMake(self.width, 5.0))
        self.bottomLineMenu.autoPinEdgeToSuperviewEdge(.Leading, withInset: self.frame.width)
        self.bottomLineMenu.autoPinEdgeToSuperviewEdge(.Top, withInset: 200)
        
        self.bottomLineInfo.autoSetDimensionsToSize(CGSizeMake(self.width, 5.0))
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Leading, withInset: self.frame.width * 2)
        self.bottomLineInfo.autoPinEdgeToSuperviewEdge(.Top, withInset: 160)
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
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        
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
//        println("page: \(page)")
//        
//        self.segmentedControl.selectSegmentAtIndex(pageIndex)
//    }
    
    
}
