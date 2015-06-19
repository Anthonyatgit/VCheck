//
//  FoodViewerViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/27.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import HYBLoopScrollView
import DKChainableAnimationKit

class FoodViewerViewController: VCBaseViewController, UIScrollViewDelegate, SMSegmentViewDelegate, UIActionSheetDelegate {
    
    var foodIdentifier: String?
    var foodItem: FoodItem?
    
    var parentNav: UINavigationController?
    
    let shareRightTop: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 30.0, 30.0))
    
    let scrollView: UIScrollView = UIScrollView()
    let checkView: UIView = UIView.newAutoLayoutView()
    let detailSegmentView: UIView = UIView.newAutoLayoutView()
    let detailView: UIView = UIView.newAutoLayoutView()
    var detailScrollView: FoodDetailScrollView!
    
    
    var photos: NSArray = VCAppLetor.FoodInfo.photos
    var photoViewer: HYBLoopScrollView?
    
    let originPrice: UILabel = UILabel.newAutoLayoutView()
    let originPriceStricke: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let foodUnit: UILabel = UILabel.newAutoLayoutView()
    let checkNow: UIButton = UIButton.newAutoLayoutView()
    let checkNowBg: UIView = UIView.newAutoLayoutView()
    
    let photosView: UIView = UIView.newAutoLayoutView()
    let dateTagBg: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let dateTag: UILabel = UILabel.newAutoLayoutView()
    
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let remainAmount: UILabel = UILabel.newAutoLayoutView()
    let remainTime: UILabel = UILabel.newAutoLayoutView()
    let returnable: UILabel = UILabel.newAutoLayoutView()
    let foodDesc: UILabel = UILabel.newAutoLayoutView()
    
    let shareBtn: IconButton = IconButton.newAutoLayoutView()
    let likeBtn: IconButton = IconButton.newAutoLayoutView()
    
    let segBG: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let segForeView: CustomDrawView = CustomDrawView()
    
    var detailSegmentControl: SMSegmentView!
    
    var foodDetailHeight: CGFloat!
    
    var didSetupConstraints = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.FoodViewerTitle
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "shareFood")
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.frame.size.height = self.view.bounds.height - VCAppLetor.ConstValue.CheckNowBarHeight
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        // Member Center Entrain
        self.shareRightTop.setImage(UIImage(named: VCAppLetor.IconName.ShareBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        self.shareRightTop.addTarget(self, action: "shareFood", forControlEvents: .TouchUpInside)
        self.shareRightTop.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.shareRightTop)
        
        self.setupFoodView()
        
        self.view.addSubview(self.scrollView)
        
        self.setupCheckView()
        
        self.view.setNeedsUpdateConstraints()
        
        // Segment Indicator
        self.segForeView.drawType = "segFore"
        self.scrollView.addSubview(self.segForeView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.detailSegmentControl.selectSegmentAtIndex(0)
        
        self.detailScrollView.mapView.viewWillAppear()
        self.detailScrollView.mapView.delegate = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.detailScrollView.mapView.viewWillDisappear()
        self.detailScrollView.mapView.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let segWidth: CGFloat = (self.view.width-40.0)/3.0
        let orgX: CGFloat = 20.0 + segWidth * CGFloat(self.detailSegmentControl.indexOfSelectedSegment ?? 0)
        
        self.segForeView.frame = CGRectMake(orgX, self.segBG.originY, segWidth, 40.0)
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.detailView.originY + self.detailView.height + 20.0)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
    }
    
    
    override func updateViewConstraints() {
        
        if !self.didSetupConstraints {
            
            self.checkView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Top)
            self.checkView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
            
            self.checkNow.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
            self.checkNow.autoMatchDimension(.Width, toDimension: .Width, ofView: self.checkView, withMultiplier: 0.4)
            
            self.checkNowBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.checkNow, withOffset: -1.0)
            self.checkNowBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.checkNow, withOffset: -1.0)
            self.checkNowBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.checkNow, withOffset: 2.0)
            self.checkNowBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.checkNow, withOffset: 2.0)
            
            self.price.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.checkNow)
            self.price.autoPinEdgeToSuperviewEdge(.Leading, withInset: 50.0)
            self.price.autoSetDimensionsToSize(CGSizeMake(36.0, 22.0))
            
            self.foodUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.price)
            self.foodUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price)
            self.foodUnit.autoSetDimensionsToSize(CGSizeMake(40.0, 20.0))
            
            self.originPrice.autoPinEdgeToSuperviewEdge(.Top, withInset: 16.0)
            self.originPrice.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.price, withOffset: 30.0)
            self.originPrice.autoSetDimensionsToSize(CGSizeMake(42.0, 20.0))
            
            self.originPriceStricke.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.originPrice)
            self.originPriceStricke.autoAlignAxis(.Horizontal, toSameAxisOfView: self.originPrice)
            self.originPriceStricke.autoMatchDimension(.Width, toDimension: .Width, ofView: self.originPrice)
            self.originPriceStricke.autoSetDimension(.Height, toSize: 2.0)
            
            self.photosView.autoSetDimensionsToSize(CGSizeMake(self.scrollView.bounds.width, self.scrollView.bounds.width/2))
            self.photosView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
            
            self.dateTagBg.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.photosView, withOffset: 20.0)
            self.dateTagBg.autoPinEdgeToSuperviewEdge(.Leading)
            self.dateTagBg.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
            
            self.dateTag.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.dateTagBg, withOffset: 8.0)
            self.dateTag.autoAlignAxis(.Horizontal, toSameAxisOfView: self.dateTagBg)
            self.dateTag.autoSetDimensionsToSize(CGSizeMake(64.0, 14.0))
            
            self.foodTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateTagBg, withOffset: 20.0)
            self.foodTitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
            self.foodTitle.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
            
            self.remainAmount.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 10.0)
            self.remainAmount.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.remainAmount.autoSetDimensionsToSize(CGSizeMake(68.0, 14.0))
            
            self.remainTime.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.remainAmount, withOffset: 10.0)
            self.remainTime.autoPinEdge(.Top, toEdge: .Top, ofView: self.remainAmount)
            self.remainTime.autoSetDimensionsToSize(CGSizeMake(80.0, 14.0))
            
            self.returnable.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.remainAmount, withOffset: 10.0)
            self.returnable.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.returnable.autoSetDimensionsToSize(CGSizeMake(50.0, 14.0))
            
            self.foodDesc.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.returnable, withOffset: 12.0)
            self.foodDesc.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.foodDesc.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            
            self.shareBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.shareBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodDesc, withOffset: 20.0)
            self.shareBtn.autoSetDimensionsToSize(CGSizeMake(145.0, 38.0))
            
            self.likeBtn.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.shareBtn, withOffset: 10.0)
            self.likeBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.shareBtn)
            self.likeBtn.autoSetDimensionsToSize(CGSizeMake(72.0, 38.0))
            
            self.segBG.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.segBG.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.segBG.autoSetDimension(.Height, toSize: 40.0)
            self.segBG.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.shareBtn, withOffset: 30.0)
            
            self.detailSegmentControl?.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.detailSegmentControl?.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.detailSegmentControl?.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.shareBtn, withOffset: 30.0)
            self.detailSegmentControl?.autoSetDimension(.Height, toSize: 40.0)
            
            self.detailView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.detailSegmentControl, withOffset: 30.0)
            self.detailView.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.detailView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
            self.detailView.autoSetDimension(.Height, toSize: self.foodDetailHeight)
            
            self.didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Functions
    
    func setupCheckView() {
        
        self.checkNowBg.backgroundColor = UIColor.pumpkinColor()
        self.checkView.addSubview(self.checkNowBg)
        
        self.checkNow.backgroundColor = UIColor.pumpkinColor()
        self.checkNow.setTitle(VCAppLetor.StringLine.CheckNow, forState: UIControlState.Normal)
        self.checkNow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.checkNow.layer.borderWidth = 1.0
        self.checkNow.layer.borderColor = UIColor.whiteColor().CGColor
        self.checkNow.addTarget(self, action: "checkNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.checkView.addSubview(self.checkNow)
        
        self.price.text = "288"
        self.price.textAlignment = .Center
        self.price.textColor = UIColor.orangeColor()
        self.price.font = VCAppLetor.Font.XLarge
        self.checkView.addSubview(self.price)
        
        self.foodUnit.text = "元/2位"
        self.foodUnit.textAlignment = .Center
        self.foodUnit.textColor = UIColor.orangeColor()
        self.foodUnit.font = VCAppLetor.Font.SmallFont
        self.checkView.addSubview(self.foodUnit)
        
        self.originPrice.text = "388元"
        self.originPrice.textAlignment = .Left
        self.originPrice.textColor = UIColor.grayColor()
        self.originPrice.font = VCAppLetor.Font.SmallFont
        self.checkView.addSubview(self.originPrice)
        
        self.originPriceStricke.drawType = "GrayLine"
        self.originPriceStricke.lineWidth = 1.0
        self.checkView.addSubview(self.originPriceStricke)
        
        self.checkView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        
        let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
        topBorder.drawType = "GrayLine"
        topBorder.lineWidth = 1.0
        self.checkView.addSubview(topBorder)
        
        topBorder.autoSetDimension(.Height, toSize: 1.0)
        topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        self.view.addSubview(self.checkView)
    }
    
    func setupFoodView() {
        
        // Food photos
        self.photoViewer = HYBLoopScrollView(frame: CGRectMake(0, 0, self.scrollView.bounds.width, self.scrollView.bounds.width / 2), imageUrls: self.photos as [AnyObject]) as HYBLoopScrollView
        self.photoViewer!.alignment = HYBPageControlAlignment.PageControlAlignCenter
        self.photoViewer?.timeInterval = 60
        self.photoViewer!.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.photosView.addSubview(self.photoViewer!)
        self.scrollView.addSubview(self.photosView)
        
        // Date Tag
        self.dateTagBg.drawType = "DateTag"
        self.dateTagBg.alpha = 0.8
        self.scrollView.addSubview(self.dateTagBg)
        
        self.dateTag.text = "2015.06.01"
        self.dateTag.textAlignment = .Left
        self.dateTag.textColor = UIColor.whiteColor()
        self.dateTag.font = VCAppLetor.Font.SmallFont
        self.scrollView.addSubview(self.dateTag)
        
        // Food title
        self.foodTitle.text = self.foodItem!.title
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.numberOfLines = 2
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.scrollView.addSubview(self.foodTitle)
        
        // Remainings
        self.remainAmount.text = "剩余 17 份"
        self.remainAmount.font = VCAppLetor.Font.SmallFont
        self.remainAmount.textAlignment = .Left
        self.remainAmount.textColor = UIColor.lightGrayColor()
        self.scrollView.addSubview(self.remainAmount)
        
        self.remainTime.text = "剩余 1 周以上"
        self.remainTime.font = VCAppLetor.Font.SmallFont
        self.remainTime.textAlignment = .Left
        self.remainTime.textColor = UIColor.lightGrayColor()
        self.scrollView.addSubview(self.remainTime)
        
        self.returnable.text = "可退款"
        self.returnable.font = VCAppLetor.Font.SmallFont
        self.returnable.textAlignment = .Left
        self.returnable.textColor = UIColor.nephritisColor()
        self.scrollView.addSubview(self.returnable)
        
        // Food Description
        self.foodDesc.text = self.foodItem?.desc
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.foodItem!.desc)
        let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
        parag.lineSpacing = 5
        attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.foodItem!.desc)))
        self.foodDesc.attributedText = attrString
        self.foodDesc.sizeToFit()
        self.foodDesc.font = VCAppLetor.Font.NormalFont
        self.foodDesc.textAlignment = .Left
        self.foodDesc.textColor = UIColor.grayColor()
        self.foodDesc.numberOfLines = 0
        self.foodDesc.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.scrollView.addSubview(self.foodDesc)
        
        // Share Button
        self.shareBtn.icon.image = UIImage(named: VCAppLetor.IconName.ShareBlack)
        self.shareBtn.titleStr.text = VCAppLetor.StringLine.ShareToGetCoupon
        self.shareBtn.addTarget(self, action: "shareFood", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.shareBtn)
        
        // Like
        self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteBlack)
        self.likeBtn.titleStr.text = "17"
        self.scrollView.addSubview(self.likeBtn)
        
        self.segBG.drawType = "segBG"
        self.scrollView.addSubview(self.segBG)
        
        // Detail segment control
        self.detailSegmentControl = SMSegmentView(frame: CGRectMake(0, 0, self.scrollView.frame.width - 40.0, 40.0), separatorColour: UIColor.clearColor(), separatorWidth: 0, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(16.0), keySegmentOnSelectionColour: UIColor.clearColor(), keySegmentOffSelectionColour: UIColor.clearColor(), keyContentVerticalMargin: Float(10.0)])
        self.detailSegmentControl.delegate = self
        self.detailSegmentControl.layer.borderWidth = 0
        
        self.detailSegmentControl.addSegmentWithTitle("亮点", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControl.addSegmentWithTitle("菜单", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControl.addSegmentWithTitle("须知", onSelectionImage: nil, offSelectionImage: nil)
        
        self.scrollView.addSubview(self.detailSegmentControl)
        
        self.detailScrollView = FoodDetailScrollView(frame: CGRectMake(0, 0, self.scrollView.width-40, 400))
        self.detailScrollView.segmentedControl = self.detailSegmentControl
        self.foodDetailHeight = detailScrollView.height
        self.detailView.addSubview(self.detailScrollView)
        self.scrollView.addSubview(self.detailView)
        
    }
    
    // Submit order action
    func checkNowAction() {
        
        let orderCheckViewController: VCCheckNowViewController = VCCheckNowViewController()
        orderCheckViewController.parentNav = self.parentNav
        orderCheckViewController.foodItem = self.foodItem
        self.parentNav?.showViewController(orderCheckViewController, sender: self)
    }
    
    // Share 
    func shareFood() {
        
        let shareView: VCShareActionView = VCShareActionView(frame: self.view.frame)
        shareView.foodItem = self.foodItem
        self.view.addSubview(shareView)
        
        self.detailSegmentControl.selectSegmentAtIndex(self.detailSegmentControl.indexOfSelectedSegment)
        
    }
    
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    
    // MARK: - SMSegmentView Delegate
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        
        let segItemWidth: CGFloat = (self.view.width-40.0)/3.0
        
        var indexPage: CGFloat = 0.0
        
        if index == 1 {
            indexPage = 1.0
            self.detailScrollView.viewType = VCAppLetor.FoodInfoType.menu
            
        }
        else if index == 2 {
            indexPage = 2.0
            self.detailScrollView.viewType = VCAppLetor.FoodInfoType.info
        }
        else {
            self.detailScrollView.viewType = VCAppLetor.FoodInfoType.spot
        }
        
        self.segForeView.animation.animationCompletion = {
            self.segForeView.originX = 20.0 + segItemWidth * indexPage
        }
        self.segForeView.animation.makeOrigin(20.0 + segItemWidth * indexPage, self.segBG.originY).animate(0.2)
        
        self.detailView.height = self.detailScrollView.height
        self.scrollView.contentSize.height = self.detailView.originY + self.detailView.height + 20.0
        self.detailScrollView.scrollRectToVisible(CGRectMake(self.detailScrollView.width * indexPage, 0, self.detailScrollView.width, 200), animated: true)
        
        
    }
    
}

// MARK: - IconButton
// Button with icon@left & text@right
class IconButton: UIButton {
    
    let icon: UIImageView = UIImageView.newAutoLayoutView()
    let titleStr: UILabel = UILabel.newAutoLayoutView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.icon)
        
        self.titleStr.textAlignment = .Center
        self.titleStr.textColor = UIColor.blackColor()
        self.titleStr.font = VCAppLetor.Font.SmallFont
        self.addSubview(self.titleStr)
        
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.icon.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 10.0, 10.0, 0.0), excludingEdge: .Trailing)
        self.icon.autoMatchDimension(.Width, toDimension: .Height, ofView: self, withOffset: -20.0)
        
        self.titleStr.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.icon, withOffset: 10.0)
        self.titleStr.autoAlignAxisToSuperviewAxis(.Horizontal)
        self.titleStr.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10.0)
        self.titleStr.autoMatchDimension(.Height, toDimension: .Height, ofView: self.icon, withMultiplier: 0.6)
    }
    
}




