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
import MBProgressHUD
import RKDropdownAlert

class FoodViewerViewController: VCBaseViewController, UIScrollViewDelegate, SMSegmentViewDelegate, UIPopoverPresentationControllerDelegate, MemberSigninDelegate, MemberRegisterDelegate {
    
    
    let imageCache = NSCache()
    
    var foodIdentifier: String?
    var foodInfo: FoodInfo!
    
    var parentNav: UINavigationController?
    
    let shareRightTop: UIButton = UIButton(frame: CGRectMake(6.0, 6.0, 26.0, 26.0))
    
    let scrollView: UIScrollView = UIScrollView()
    let checkView: UIView = UIView.newAutoLayoutView()
    let payView: UIView = UIView.newAutoLayoutView()
    let detailView: UIView = UIView.newAutoLayoutView()
    let detailScrollView: FoodDetailScrollView = FoodDetailScrollView()
    
    
    var photos: NSMutableArray = NSMutableArray()
    var photoViewer: HYBLoopScrollView?
    var photoViewerMenu: HYBLoopScrollView?
    
    let originPrice: UILabel = UILabel.newAutoLayoutView()
    let originPriceStricke: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let price: UILabel = UILabel.newAutoLayoutView()
    let foodUnit: UILabel = UILabel.newAutoLayoutView()
    let checkNow: UIButton = UIButton.newAutoLayoutView()
    let checkNowBg: UIView = UIView.newAutoLayoutView()
    
    let payNow: UIButton = UIButton.newAutoLayoutView()
    let payNowBg: UIView = UIView.newAutoLayoutView()
    
    let photosView: UIView = UIView.newAutoLayoutView()
    let dateTagBg: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let dateTagBg2: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let dateTag: UILabel = UILabel.newAutoLayoutView()
    
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let remainAmount: UILabel = UILabel.newAutoLayoutView()
    let remainTime: UILabel = UILabel.newAutoLayoutView()
    let returnable: UILabel = UILabel.newAutoLayoutView()
    let foodDesc: UILabel = UILabel.newAutoLayoutView()
    
    let shareBtn: IconButton = IconButton.newAutoLayoutView()
    let likeBtn: IconButton = IconButton.newAutoLayoutView()
    
    var segBG: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let segForeView: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var segBGCopy: CustomDrawView = CustomDrawView()
    let segForeViewCopy: CustomDrawView = CustomDrawView()
    
    var detailSegmentControl: SMSegmentView!
    var detailSegmentControlCopy: SMSegmentView!
    
    var foodDetailHeight: CGFloat!
    
    let spotLabel: TYAttributedLabel = TYAttributedLabel()
    let menuLabel: TYAttributedLabel = TYAttributedLabel()
    
    var lastEl: UILabel = UILabel()
    let bottomLineSpot: CustomDrawView = CustomDrawView()
    
    var lastMenuEl: UILabel = UILabel()
    let bottomLineMenu: CustomDrawView = CustomDrawView()
    let bottomLineInfo: CustomDrawView = CustomDrawView()
    
    var shareView: VCShareActionView?
    var galleryView: VCGalleryView?
    
    var didSetupConstraints = false
    
    var segIndex: Int = -1
    
    var hud: MBProgressHUD!
    
    var isInitLoad: Bool = true
    
    var slideDone: Bool = false
    
    var scrollContentSize: CGSize = CGSizeMake(0, 0)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.FoodViewerTitle
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "shareFood")
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.height = self.view.height - VCAppLetor.ConstValue.CheckNowBarHeight - 62.0
        self.scrollView.originY = 62.0
        self.scrollView.alpha = 0.1
        self.scrollView.delegate = self
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsVerticalScrollIndicator = false
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        // Member Center Entrain
        self.shareRightTop.setImage(UIImage(named: VCAppLetor.IconName.ShareBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        self.shareRightTop.addTarget(self, action: "shareFood", forControlEvents: .TouchUpInside)
        self.shareRightTop.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.shareRightTop)
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        
        self.getProductDetail()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isInitLoad {
            let hudAppear = MBProgressHUD.showHUDAddedTo(self.view, animated: false)
            hudAppear.mode = MBProgressHUDMode.Indeterminate
        }
        
        
        // Check if member have order session
        if self.isLogin() && !self.isInitLoad {
            
            self.updateFoodInfo()
        }
        else {
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
        
        self.isInitLoad = false
        
        if CTMemCache.sharedInstance.exists("Product", namespace: "outcall") {
            CTMemCache.sharedInstance.cleanNamespace("outcall")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.slideDone = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.detailSegmentControl != nil && self.segIndex >= 0 {
            
            self.detailSegmentControl.selectSegmentAtIndex(self.segIndex)
        }
        
        if self.slideDone {
            self.payView.originY = self.view.height - 60.0
            
        }
        
    }
    
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Functions
    
    func addSegCopy() {
        
        self.segBGCopy.frame = CGRectMake(20, 62, self.view.width-40.0, 40.0)
        self.segBGCopy.drawType = "segBG"
        self.segBGCopy.backgroundColor = UIColor.whiteColor()
        self.segBGCopy.alpha = 0
        self.view.addSubview(self.segBGCopy)
        
        self.segForeViewCopy.frame = CGRectMake(0, 0, (self.view.width-40.0) / 3.0, 40.0)
        self.segForeViewCopy.drawType = "segFore"
        self.segBGCopy.addSubview(self.segForeViewCopy)
        
        // Detail segment control
        self.detailSegmentControlCopy = SMSegmentView(frame: CGRectMake(0, 0, self.scrollView.frame.width - 40.0, 40.0), separatorColour: UIColor.clearColor(), separatorWidth: 0, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(16.0), keySegmentOnSelectionColour: UIColor.clearColor(), keySegmentOffSelectionColour: UIColor.clearColor(), keyContentVerticalMargin: Float(10.0)])
        self.detailSegmentControlCopy.delegate = self
        self.detailSegmentControlCopy.layer.borderWidth = 0
        
        self.detailSegmentControlCopy.addSegmentWithTitle("亮点", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControlCopy.addSegmentWithTitle("菜单", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControlCopy.addSegmentWithTitle("须知", onSelectionImage: nil, offSelectionImage: nil)
        
        self.segBGCopy.addSubview(self.detailSegmentControlCopy)
    }
    
    func getProductDetail() {
        
        Alamofire.request(VCheckGo.Router.GetProductDetail(self.foodInfo.id)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        // Slide images
                        let foodSlideImages = json["data"]["article_info"]["article_image_list"].arrayValue
                        self.foodInfo.slideImages = NSMutableArray()
                        
                        for image in foodSlideImages {
                            
                            self.foodInfo.slideImages?.addObject(image["image"]["source"].string!)
                        }
                        
                        // Summary
                        self.foodInfo.desc = json["data"]["article_info"]["summary"].string!
                        
                        // Collection
                        self.foodInfo.favoriteCount = json["data"]["article_info"]["collection_info"]["collection_count"].string!
                        self.foodInfo.isCollected = json["data"]["article_info"]["collection_info"]["is_collected"].string!
                        
                        // Spot Part
                        let foodSpots = json["data"]["article_info"]["article_content_list"].arrayValue
                        self.foodInfo.contentImages = NSMutableArray()
                        self.foodInfo.contentTitles = NSMutableArray()
                        self.foodInfo.contentDesc = NSMutableArray()
                        
                        for cont in foodSpots {
                            self.foodInfo.contentImages?.addObject(cont["image"]["source"].string!)
                            self.foodInfo.contentTitles?.addObject(cont["title"].string!)
                            self.foodInfo.contentDesc?.addObject(cont["content"].string!)
                        }
                        
                        // Menu Part
                        let foodMenus = json["data"]["article_info"]["article_menu_list"].arrayValue
                        self.foodInfo.menuTitles = NSMutableArray()
                        self.foodInfo.menuContents = NSMutableArray()
                        
                        for item in foodMenus {
                            self.foodInfo.menuTitles?.addObject(item["title"].string!)
                            
                            let contents = item["content"].arrayValue
                            let submenus: NSMutableArray = NSMutableArray()
                            
                            for con in contents {
                                submenus.addObject(con.string!)
                            }
                            
                            self.foodInfo.menuContents?.addObject(submenus)
                        }
                        
                        // Info Part
                        let foodTips = json["data"]["article_info"]["article_tips_info"]["content"].arrayValue
                        
                        self.foodInfo.tips = NSMutableArray()
                        
                        for tip in foodTips {
                            
                            self.foodInfo.tips?.addObject(tip.string!)
                        }
                        
                        
                        // Views
                        self.setupFoodView()
                        
                        if self.isLogin() {
                            
                            self.updateFoodInfo()
                        }
                        else {
                            self.setupCheckView()
                            self.setupCheckViewConstraints()
                            
                            if self.foodInfo.remainingCount! == "0" {
                                
                                self.checkNowBg.backgroundColor = UIColor.lightGrayColor()
                                self.checkNow.backgroundColor = UIColor.lightGrayColor()
                                self.checkNow.setTitle(self.foodInfo.outOfStock!, forState: .Normal)
                                self.checkNow.removeTarget(self, action: "checkNowAction", forControlEvents: .TouchUpInside)
                            }
                            
                            if self.foodInfo.remainder! == "0" {
                                
                                self.checkNowBg.backgroundColor = UIColor.lightGrayColor()
                                self.checkNow.backgroundColor = UIColor.lightGrayColor()
                                self.checkNow.setTitle(VCAppLetor.StringLine.isClose, forState: .Normal)
                                self.checkNow.removeTarget(self, action: "checkNowAction", forControlEvents: .TouchUpInside)
                            }
                            
                        }
                        
                        
                        self.addSegCopy()
                        
                        //self.hud.hide(true)
                        
                        self.detailSegmentControl.selectSegmentAtIndex(0)
                        self.scrollView.animation.makeAlpha(1.0).animate(0.4)
                        
                        
                        
                        //self.resetDetailFrame()
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                })
                
            }
            else {
                
                println("ERROR @ Request for Product Detail : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        })
        
        
    }
    
    
    
    func setupCheckViewConstraints() {
        
        
        
    }
    
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
        
        self.price.text = round_price(self.foodInfo.price!)
        self.price.textAlignment = .Center
        self.price.textColor = UIColor.orangeColor()
        self.price.font = VCAppLetor.Font.XXLight
        self.checkView.addSubview(self.price)
        
        self.foodUnit.text = "\(self.foodInfo.priceUnit!)/\(self.foodInfo.unit!)"
        self.foodUnit.textAlignment = .Center
        self.foodUnit.textColor = UIColor.orangeColor()
        self.foodUnit.font = VCAppLetor.Font.NormalFont
        self.checkView.addSubview(self.foodUnit)
        
        self.originPrice.text = "\(round_price(self.foodInfo.originalPrice!))\(self.foodInfo.priceUnit!)"
        self.originPrice.textAlignment = .Center
        self.originPrice.textColor = UIColor.grayColor()
        self.originPrice.font = VCAppLetor.Font.LightXSmall
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
        
        self.checkView.autoPinEdgeToSuperviewEdge(.Top, withInset: self.view.height-60.0)
        self.checkView.autoPinEdgeToSuperviewEdge(.Leading)
        self.checkView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
        self.checkView.autoSetDimension(.Width, toSize: self.view.width)
        
        self.checkNow.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
        self.checkNow.autoMatchDimension(.Width, toDimension: .Width, ofView: self.checkView, withMultiplier: 0.4)
        
        self.checkNowBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.checkNow, withOffset: -1.0)
        self.checkNowBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.checkNow, withOffset: -1.0)
        self.checkNowBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.checkNow, withOffset: 2.0)
        self.checkNowBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.checkNow, withOffset: 2.0)
        
        self.price.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.checkNow)
        self.price.autoPinEdgeToSuperviewEdge(.Leading, withInset: 60.0)
        self.price.autoSetDimensionsToSize(CGSizeMake(56.0, 22.0))
        
        self.foodUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.price)
        self.foodUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price)
        self.foodUnit.autoSetDimensionsToSize(CGSizeMake(48.0, 20.0))
        
        self.originPrice.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
        self.originPrice.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.price, withOffset: 24.0)
        self.originPrice.autoSetDimensionsToSize(CGSizeMake(54.0, 20.0))
        
        self.originPriceStricke.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.originPrice)
        self.originPriceStricke.autoAlignAxis(.Horizontal, toSameAxisOfView: self.originPrice)
        self.originPriceStricke.autoMatchDimension(.Width, toDimension: .Width, ofView: self.originPrice)
        self.originPriceStricke.autoSetDimension(.Height, toSize: 2.0)
        
    }
    
    func setupPayView() {
        
        self.payNowBg.backgroundColor = UIColor.nephritisColor()
        self.payView.addSubview(self.payNowBg)
        
        self.payNow.backgroundColor = UIColor.nephritisColor()
        self.payNow.setTitle(VCAppLetor.StringLine.PayNow, forState: UIControlState.Normal)
        self.payNow.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.payNow.layer.borderWidth = 1.0
        self.payNow.layer.borderColor = UIColor.whiteColor().CGColor
        self.payNow.addTarget(self, action: "payNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.payView.addSubview(self.payNow)
        
        self.price.text = round_price(self.foodInfo.price!)
        self.price.textAlignment = .Center
        self.price.textColor = UIColor.orangeColor()
        self.price.font = VCAppLetor.Font.XXLight
        self.payView.addSubview(self.price)
        
        self.foodUnit.text = "\(self.foodInfo.priceUnit!)/\(self.foodInfo.unit!)"
        self.foodUnit.textAlignment = .Center
        self.foodUnit.textColor = UIColor.orangeColor()
        self.foodUnit.font = VCAppLetor.Font.NormalFont
        self.payView.addSubview(self.foodUnit)
        
        self.originPrice.text = "\(round_price(self.foodInfo.originalPrice!))\(self.foodInfo.priceUnit!)"
        self.originPrice.textAlignment = .Center
        self.originPrice.textColor = UIColor.grayColor()
        self.originPrice.font = VCAppLetor.Font.LightXSmall
        self.payView.addSubview(self.originPrice)
        
        self.originPriceStricke.drawType = "GrayLine"
        self.originPriceStricke.lineWidth = 1.0
        self.payView.addSubview(self.originPriceStricke)
        
        self.payView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        
        
        let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
        topBorder.drawType = "GrayLine"
        topBorder.lineWidth = 1.0
        self.payView.addSubview(topBorder)
        
        topBorder.autoSetDimension(.Height, toSize: 1.0)
        topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        
        self.view.addSubview(self.payView)
        
        
        self.payView.autoPinEdgeToSuperviewEdge(.Top, withInset: self.view.height)
        self.payView.autoPinEdgeToSuperviewEdge(.Leading)
        self.payView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
        self.payView.autoSetDimension(.Width, toSize: self.view.width)
        
        self.payNow.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
        self.payNow.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payView, withMultiplier: 0.4)
        
        self.payNowBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.payNow, withOffset: -1.0)
        self.payNowBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.payNow, withOffset: -1.0)
        self.payNowBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.payNow, withOffset: 2.0)
        self.payNowBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payNow, withOffset: 2.0)
        
        self.price.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payNow)
        self.price.autoPinEdgeToSuperviewEdge(.Leading, withInset: 60.0)
        self.price.autoSetDimensionsToSize(CGSizeMake(56.0, 22.0))
        
        self.foodUnit.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.price)
        self.foodUnit.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.price)
        self.foodUnit.autoSetDimensionsToSize(CGSizeMake(48.0, 20.0))
        
        self.originPrice.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
        self.originPrice.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.price, withOffset: 24.0)
        self.originPrice.autoSetDimensionsToSize(CGSizeMake(54.0, 20.0))
        
        self.originPriceStricke.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.originPrice)
        self.originPriceStricke.autoAlignAxis(.Horizontal, toSameAxisOfView: self.originPrice)
        self.originPriceStricke.autoMatchDimension(.Width, toDimension: .Width, ofView: self.originPrice)
        self.originPriceStricke.autoSetDimension(.Height, toSize: 2.0)
        
        // Animation out
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.payView.animation.moveY(-60).animateWithCompletion(0.3, {
                
                self.payView.originY = self.view.height - 60.0
                self.slideDone = true
                
            })
            
        })
    }
    
    func photosDidTaped(gesture: UITapGestureRecognizer) {
        
        self.galleryView?.removeFromSuperview()
        
        self.galleryView = VCGalleryView(frame: self.view.frame)
        self.galleryView?.photos = self.photos
        self.galleryView?.setupView()
        self.view.addSubview(self.galleryView!)
        
    }
    
    func topPhotoDidTaped(btn: UIButton) {
        
        self.galleryView?.removeFromSuperview()
        
        self.galleryView = VCGalleryView(frame: self.view.frame)
        self.galleryView?.photos = self.photos
        self.galleryView?.setupView()
        self.view.addSubview(self.galleryView!)
        
    }
    
    func setupFoodView() {
        
        // Food photos
        for image in self.foodInfo.slideImages! {
            
            self.photos.addObject(image)
        }
        
        self.photoViewer = HYBLoopScrollView(frame: CGRectMake(0, 0, self.view.width, VCAppLetor.ConstValue.FoodImageHeight), imageUrls: self.photos as [AnyObject]) as HYBLoopScrollView
        self.photoViewer?.alignment = HYBPageControlAlignment.PageControlAlignCenter
        self.photoViewer?.timeInterval = 60
        self.photosView.addSubview(self.photoViewer!)
        self.scrollView.addSubview(self.photosView)
        
        var tapGuesturePhotos: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "photosDidTaped:")
        tapGuesturePhotos.numberOfTapsRequired = 1
        tapGuesturePhotos.numberOfTouchesRequired = 1
        self.photoViewer!.addGestureRecognizer(tapGuesturePhotos)
        
        // Date Tag
        self.dateTagBg.drawType = "DateTagLong"
        self.dateTagBg.alpha = 0.6
        self.scrollView.addSubview(self.dateTagBg)
        
        self.dateTagBg2.drawType = "DateTag"
        self.dateTagBg2.alpha = 0.6
        self.scrollView.addSubview(self.dateTagBg2)
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateWithoutTimeFormat
        
        self.dateTag.text = dateFormatter.stringFromDate(self.foodInfo.addDate!)
        self.dateTag.textAlignment = .Left
        self.dateTag.textColor = UIColor.whiteColor()
        self.dateTag.font = VCAppLetor.Font.SmallFont
        self.scrollView.addSubview(self.dateTag)
        
        // Food title
        self.foodTitle.text = self.foodInfo.title!
        self.foodTitle.font = VCAppLetor.Font.XLarge
        self.foodTitle.numberOfLines = 2
        self.foodTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.scrollView.addSubview(self.foodTitle)
        
        // Remainings
        
        var displayAmount: String = ""
        self.remainAmount.textColor = UIColor.lightGrayColor()
        
        if self.foodInfo.remainingCount! == "0" {
            displayAmount = self.foodInfo.outOfStock!
        }
        else {
            displayAmount = "剩余 \(self.foodInfo.remainingCount!)\(self.foodInfo.remainingCountUnit!)"
            if (self.foodInfo.remainingCount! as NSString).integerValue <= VCAppLetor.ConstValue.StockAlertPoint {
                
                self.remainAmount.textColor = UIColor.orangeColor()
            }
        }
        
        if self.foodInfo.remainder == "0" {
            displayAmount = VCAppLetor.StringLine.isClose
        }
        
        
        self.remainAmount.text = displayAmount
        self.remainAmount.font = VCAppLetor.Font.SmallFont
        self.remainAmount.textAlignment = .Left
        self.scrollView.addSubview(self.remainAmount)
        
        
        let remainder = ("\(self.foodInfo.remainder!)" as NSString).floatValue
        
        self.remainTime.textColor = UIColor.lightGrayColor()
        
        var timeTag = ""
        if remainder/(3600*24) > 7 {
            timeTag = "1周以上"
        }
        else if remainder/(3600*24) > 1 {
            let days = floor(remainder/(3600*24))
            timeTag = "\(days)天"
        }
        else {
            timeTag = "少于24小时"
            self.remainTime.textColor = UIColor.alizarinColor()
        }
        
        self.remainTime.text = "剩余 \(timeTag)"
        self.remainTime.font = VCAppLetor.Font.SmallFont
        self.remainTime.textAlignment = .Left
        self.remainTime.sizeToFit()
        self.scrollView.addSubview(self.remainTime)
        
        self.returnable.text = "可退款"
        self.returnable.font = VCAppLetor.Font.SmallFont
        self.returnable.textAlignment = .Left
        self.returnable.textColor = UIColor.nephritisColor()
        self.scrollView.addSubview(self.returnable)
        
        // Food Description
        self.foodDesc.text = self.foodInfo?.desc
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: self.foodInfo.desc!)
        let parag: NSMutableParagraphStyle = NSMutableParagraphStyle()
        parag.lineSpacing = 5
        attrString.addAttribute(NSParagraphStyleAttributeName, value: parag, range: NSMakeRange(0, count(self.foodInfo.desc!)))
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
        if self.foodInfo.isCollected != "0" {
            
            self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteRed)
        }
        else {
            self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteBlack)
        }
        
        self.likeBtn.titleStr.text = self.foodInfo.favoriteCount!
        self.likeBtn.addTarget(self, action: "toggleFav", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.likeBtn)
        
        self.segBG.drawType = "segBG"
        self.scrollView.addSubview(self.segBG)
        
        self.segForeView.drawType = "segFore"
        self.segForeView.alpha = 0.0
        self.segBG.addSubview(self.segForeView)
        
        // Detail segment control
        self.detailSegmentControl = SMSegmentView(frame: CGRectMake(0, 0, self.scrollView.frame.width - 40.0, 40.0), separatorColour: UIColor.clearColor(), separatorWidth: 0, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(16.0), keySegmentOnSelectionColour: UIColor.clearColor(), keySegmentOffSelectionColour: UIColor.clearColor(), keyContentVerticalMargin: Float(10.0)])
        self.detailSegmentControl.delegate = self
        self.detailSegmentControl.layer.borderWidth = 0
        
        self.detailSegmentControl.addSegmentWithTitle("亮点", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControl.addSegmentWithTitle("菜单", onSelectionImage: nil, offSelectionImage: nil)
        self.detailSegmentControl.addSegmentWithTitle("须知", onSelectionImage: nil, offSelectionImage: nil)
        
        self.segBG.addSubview(self.detailSegmentControl)
        
        
        self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, 400.0)
        self.detailScrollView.segmentedControl = self.detailSegmentControl
        self.detailScrollView.foodInfo = self.foodInfo
        self.detailView.addSubview(self.detailScrollView)
        //        self.detailView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        self.scrollView.addSubview(self.detailView)
        
        self.view.addSubview(self.scrollView)
        
        self.setupViewConstraints()
        
        self.setupDetailView()
        
    }
    
    func setupDetailView() {
        
        self.detailScrollView.pagingEnabled = true
        self.detailScrollView.scrollEnabled = false
        self.detailScrollView.showsHorizontalScrollIndicator = false
        self.detailScrollView.contentSize.width = self.detailScrollView.width * 3
        self.detailScrollView.contentSize.height = self.detailScrollView.height
        
        
        // Spot
        self.detailScrollView.addSubview(self.spotLabel)
        
        let totalCount = self.foodInfo.contentImages?.count
        
        for var i=0; i<totalCount; i++ {
            
            if i > 0 {
                
                let blank: UIView = UIView(frame: CGRectMake(0, 0, self.detailScrollView.width, 20))
                blank.backgroundColor = UIColor.whiteColor()
                self.spotLabel.appendView(blank)
            }
            
            let slideImageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.detailScrollView.width, 200))
            
            let imageURL = self.foodInfo.contentImages?.objectAtIndex(i) as! String
            
            self.spotLabel.appendView(slideImageView)
            
            if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
                slideImageView.image = image
            }
            else {
                
                slideImageView.image = nil
                
                Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                    
                    (_, _, image, error) in
                    
                    if error == nil && image != nil {
                        
                        let slideImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.view.width - 40.0, height: 200), fitMode: Toucan.Resize.FitMode.Crop)
                        
                        self.imageCache.setObject(slideImage, forKey: imageURL)
                        
                        slideImageView.image = slideImage
                    }
                }
            }
            
            
            let blankTitle: UIView = UIView(frame: CGRectMake(0, 0, self.detailScrollView.width, 10))
            blankTitle.backgroundColor = UIColor.whiteColor()
            self.spotLabel.appendView(blankTitle)
            
            let titleX: TYAttributedLabel = TYAttributedLabel()
            
            titleX.characterSpacing = 1
            titleX.linesSpacing = 4
            
            titleX.text = self.foodInfo.contentTitles?.objectAtIndex(i) as? String
            
            titleX.lineBreakMode = CTLineBreakMode.ByTruncatingTail
            titleX.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            titleX.font = VCAppLetor.Font.XLarge
            titleX.setFrameWithOrign(CGPointMake(0, 30), width: self.detailScrollView.width)
            self.spotLabel.appendView(titleX, alignment: TYDrawAlignmentCenter)
            
            
            let descX: TYAttributedLabel = TYAttributedLabel()
            descX.characterSpacing = 0
            descX.linesSpacing = 4
            
            descX.text = self.foodInfo.contentDesc?.objectAtIndex(i) as! String
            
            descX.lineBreakMode = CTLineBreakMode.ByTruncatingTail
            descX.font = VCAppLetor.Font.NormalFont
            descX.textColor = UIColor.grayColor()
            descX.setFrameWithOrign(CGPointMake(0, 60), width: self.detailScrollView.width)
            
            self.spotLabel.appendView(descX, alignment: TYDrawAlignmentButtom)
            
            if i < (totalCount! - 1) {
                
                let grayLine: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 10, self.detailScrollView.width, 10))
                grayLine.drawType = "GrayLineSpot"
                grayLine.lineWidth = 1.0
                self.spotLabel.appendView(grayLine, alignment: TYDrawAlignmentTop)
            }
            
        }
        
        self.spotLabel.setFrameWithOrign(CGPointMake(0, 0), width: self.detailScrollView.width)
        
        
        // Menu
        let menuTopImage: UIImageView = UIImageView(frame: CGRectMake(self.detailScrollView.width, 15, self.detailScrollView.width, VCAppLetor.ConstValue.FoodImageHeight-30.0))
        let imageURL = self.photos.objectAtIndex(0) as? String
        
        Alamofire.request(.GET, imageURL!).validate(contentType: ["image/*"]).responseImage() {
            
            (_, _, image, error) in
            
            if error == nil && image != nil {
                
                let topImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.detailScrollView.width, height: VCAppLetor.ConstValue.FoodImageHeight-30.0), fitMode: Toucan.Resize.FitMode.Crop)
                
                menuTopImage.image = topImage
            }
        }
        
        self.detailScrollView.addSubview(menuTopImage)
        
        let topBtn: UIButton = UIButton(frame: CGRectMake(self.detailScrollView.width, 15, self.detailScrollView.width, VCAppLetor.ConstValue.FoodImageHeight-30.0))
        topBtn.backgroundColor = UIColor.clearColor()
        topBtn.setTitle("", forState: .Normal)
        topBtn.layer.borderWidth = 0
        topBtn.addTarget(self, action: "topPhotoDidTaped:", forControlEvents: .TouchUpInside)
        self.detailScrollView.addSubview(topBtn)
        
        
        let photoLabelBG: UIView = UIView(frame: CGRectMake(self.detailScrollView.width*2.0-60.0, VCAppLetor.ConstValue.FoodImageHeight-30.0-20.0, 50.0, 21.0))
        photoLabelBG.backgroundColor = UIColor.blackColor()
        photoLabelBG.alpha = 0.4
        self.detailScrollView.addSubview(photoLabelBG)
        
        let photosIcon: UIImageView = UIImageView(frame: CGRectMake(photoLabelBG.originX+4, photoLabelBG.originY+3, 16, 14))
        photosIcon.tintColor = UIColor.whiteColor()
        photosIcon.image = UIImage(named: VCAppLetor.IconName.PhotosBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.detailScrollView.addSubview(photosIcon)
        
        let photosCount: UILabel = UILabel(frame: CGRectMake(photosIcon.originX+22, photosIcon.originY, 22, 16))
        photosCount.text = "\(self.photos.count)"
        photosCount.textAlignment = .Center
        photosCount.textColor = UIColor.whiteColor()
        photosCount.font = VCAppLetor.Font.SmallFont
        self.detailScrollView.addSubview(photosCount)
        
        
        let menuTag: CustomDrawView = CustomDrawView(frame: CGRectMake(self.detailScrollView.width * 1.5 - 52.0, 200.0, 104.0, 42.0))
        menuTag.drawType = "menuTag"
        self.detailScrollView.addSubview(menuTag)
        
        self.menuLabel.backgroundColor = UIColor.clearColor()
        self.detailScrollView.addSubview(self.menuLabel)
        
        let menuCount: Int = self.foodInfo.menuTitles!.count
        
        for var i=0; i<menuCount; i++ {
            
            let titleLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.detailScrollView.width, 20))
            titleLabel.text = self.foodInfo.menuTitles?.objectAtIndex(i) as? String
            titleLabel.textAlignment = .Center
            titleLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.font = VCAppLetor.Font.NormalFont
            self.menuLabel.appendView(titleLabel)
            
            let menuContent: TYAttributedLabel = TYAttributedLabel()
            
            menuContent.characterSpacing = 0
            menuContent.linesSpacing = 4
            menuContent.backgroundColor = UIColor.clearColor()
            
            var text = ""
            
            menuContent.font = VCAppLetor.Font.NormalFont
            menuContent.textColor = UIColor.grayColor()
            menuContent.textAlignment = CTTextAlignment.TextAlignmentCenter
            
            let submenuCount: Int = (self.foodInfo.menuContents?.objectAtIndex(i) as! NSMutableArray).count
            
            for var j=0; j<submenuCount; j++ {
                
                text = text + ((self.foodInfo.menuContents?.objectAtIndex(i) as! NSMutableArray).objectAtIndex(j) as! String) as String + "\n"
                
            }
            
            menuContent.text = text
            
            let itemBottom: UIView = UIView(frame: CGRectMake(0, 0, self.detailScrollView.width, 10))
            itemBottom.backgroundColor = UIColor.clearColor()
            menuContent.appendView(itemBottom)
            
            
            menuContent.setFrameWithOrign(CGPointMake(0, 10), width: self.detailScrollView.width)
            self.menuLabel.appendView(menuContent)
            
        }
        
        self.menuLabel.setFrameWithOrign(CGPointMake(self.detailScrollView.width, 252), width: self.detailScrollView.width)
        
        let menuGrayBG: UIView = UIView(frame: CGRectMake(self.detailScrollView.width, VCAppLetor.ConstValue.FoodImageHeight-30+15, self.detailScrollView.width, self.menuLabel.height+60))
        menuGrayBG.backgroundColor = UIColor.exLightGrayColor(alpha: 0.1)
        self.detailScrollView.insertSubview(menuGrayBG, belowSubview: menuTag)
        
        
        // Info
        
        let infoX = self.detailScrollView.width * 2.0
        var infoHeight: CGFloat = 0.0
        
        infoHeight += 15.0
        let storeIcon: UIImageView = UIImageView(frame: CGRectMake(infoX, infoHeight, 40, 40))
        self.detailScrollView.addSubview(storeIcon)
        let storeIconImageURL = self.foodInfo.icon_source! as String
        
        Alamofire.request(.GET, storeIconImageURL).validate(contentType: ["image/*"]).responseImage() {
            
            (_, _, image, error) in
            
            if error == nil && image != nil {
                
                let storeIconImage: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: 40, height: 40), fitMode: Toucan.Resize.FitMode.Crop)
                
                storeIcon.image = storeIconImage
            }
        }
        
        let storeName: UILabel = UILabel(frame: CGRectMake(infoX+50, 25, self.detailScrollView.width-50, 20))
        storeName.text = self.foodInfo.storeName!
        storeName.textAlignment = .Left
        storeName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        storeName.font = VCAppLetor.Font.XLarge
        self.detailScrollView.addSubview(storeName)
        
        infoHeight += 40 + 10
        let nameUnderline: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 5))
        nameUnderline.drawType = "DoubleLine"
        self.detailScrollView.addSubview(nameUnderline)
        
        infoHeight += 5 + 14
        let rateName: UILabel = UILabel(frame: CGRectMake(infoX, infoHeight, 80, 20))
        rateName.text = VCAppLetor.StringLine.rateName
        rateName.textAlignment = .Left
        rateName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        rateName.font = VCAppLetor.Font.NormalFont
        self.detailScrollView.addSubview(rateName)
        
        for var i=0; i<5; i++ {
            
            let heartImageView: UIImageView = UIImageView(frame: CGRectMake(self.detailScrollView.width*3.0-CGFloat(("\(18*(i+1))" as NSString).floatValue), infoHeight, 18, 18))
            heartImageView.image = UIImage(named: VCAppLetor.IconName.FavoriteRed)
            self.detailScrollView.addSubview(heartImageView)
            
        }
        
        infoHeight += 20 + 14
        let rateUnderline: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 3.0))
        rateUnderline.drawType = "GrayLine"
        rateUnderline.lineWidth = 1.0
        self.detailScrollView.addSubview(rateUnderline)
        
        infoHeight += 3.0 + 14
        let addName: UILabel = UILabel(frame: CGRectMake(infoX, infoHeight, 40, 20))
        addName.text = VCAppLetor.StringLine.addressName
        addName.textAlignment = .Left
        addName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        addName.font = VCAppLetor.Font.NormalFont
        addName.sizeToFit()
        self.detailScrollView.addSubview(addName)
        
        //        let addString: TYAttributedLabel = TYAttributedLabel()
        //        addString.characterSpacing = 0
        //        addString.linesSpacing = 2
        //        addString.backgroundColor = UIColor.clearColor()
        //        addString.text = self.foodInfo.address
        //        addString.font = VCAppLetor.Font.NormalFont
        //        addString.textColor = UIColor.grayColor()
        //        addString.textAlignment = CTTextAlignment.TextAlignmentLeft
        //        addString.setFrameWithOrign(CGPointMake(infoX+45, infoHeight-12), width: self.detailScrollView.width-50-50)
        //        self.detailScrollView.addSubview(addString)
        
        let address: UILabel = UILabel(frame: CGRectMake(infoX+45, infoHeight, self.detailScrollView.width-50-50, 20))
        address.text = self.foodInfo.address
        address.textAlignment = .Left
        address.textColor = UIColor.grayColor()
        address.numberOfLines = 2
        address.font = VCAppLetor.Font.NormalFont
        address.sizeToFit()
        self.detailScrollView.addSubview(address)
        
        let addIcon: UIImageView = UIImageView(frame: CGRectMake(self.detailScrollView.width*3.0-26, infoHeight-2, 24, 24))
        addIcon.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        addIcon.image = UIImage(named: VCAppLetor.IconName.PlaceBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.detailScrollView.addSubview(addIcon)
        
        let addMapButton: UIButton = UIButton(frame: CGRectMake(infoX+20, infoHeight-14.0, self.detailScrollView.width, 40))
        addMapButton.setTitle("", forState: .Normal)
        addMapButton.backgroundColor = UIColor.clearColor()
        addMapButton.addTarget(self, action: "showStoreMap", forControlEvents: .TouchUpInside)
        self.detailScrollView.addSubview(addMapButton)
        
        infoHeight += address.height + 14
        let addUnderline: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 3.0))
        addUnderline.drawType = "GrayLine"
        addUnderline.lineWidth = 1.0
        self.detailScrollView.addSubview(addUnderline)
        
        infoHeight += 3.0 + 14
        let telName: UILabel = UILabel(frame: CGRectMake(infoX, infoHeight, 65, 20))
        telName.text = VCAppLetor.StringLine.contectTelName
        telName.textAlignment = .Left
        telName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        telName.font = VCAppLetor.Font.NormalFont
        self.detailScrollView.addSubview(telName)
        
        let telString: UILabel = UILabel(frame: CGRectMake(infoX+70, infoHeight, self.detailScrollView.width-50-50, 20))
        telString.backgroundColor = UIColor.clearColor()
        telString.text = self.foodInfo.tel1
        telString.font = VCAppLetor.Font.NormalFont
        telString.textColor = UIColor.grayColor()
        telString.textAlignment = .Left
        self.detailScrollView.addSubview(telString)
        
        let telIcon: UIImageView = UIImageView(frame: CGRectMake(self.detailScrollView.width*3.0-26, infoHeight, 24, 24))
        telIcon.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        telIcon.image = UIImage(named: VCAppLetor.IconName.telBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.detailScrollView.addSubview(telIcon)
        
        let callButton: UIButton = UIButton(frame: CGRectMake(infoX, infoHeight-14.0, self.detailScrollView.width, 40))
        callButton.setTitle("", forState: .Normal)
        callButton.backgroundColor = UIColor.clearColor()
        callButton.addTarget(self, action: "callStore", forControlEvents: .TouchUpInside)
        self.detailScrollView.addSubview(callButton)
        
        infoHeight += 20 + 14
        let telUnderline: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 3.0))
        telUnderline.drawType = "GrayLine"
        telUnderline.lineWidth = 1.0
        self.detailScrollView.addSubview(telUnderline)
        
        infoHeight += 3.0 + 25
        let tipLabel: UILabel = UILabel(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 26))
        tipLabel.text = VCAppLetor.StringLine.tipsName
        tipLabel.textAlignment = .Left
        tipLabel.font = VCAppLetor.Font.XLarge
        tipLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.detailScrollView.addSubview(tipLabel)
        
        infoHeight += 26 + 10
        let tipTitleUnderline: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 5))
        tipTitleUnderline.drawType = "DoubleLine"
        self.detailScrollView.addSubview(tipTitleUnderline)
        
        infoHeight += 5 + 10
        
        let tipsBlock: TYAttributedLabel = TYAttributedLabel()
        tipsBlock.linesSpacing = 4
        tipsBlock.backgroundColor = UIColor.clearColor()
        tipsBlock.font = VCAppLetor.Font.NormalFont
        tipsBlock.textColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
        tipsBlock.textAlignment = CTTextAlignment.TextAlignmentLeft
        
        var tipString: String = ""
        
        for var i=0; i<self.foodInfo.tips!.count; i++ {
            
            tipString += "• \(self.foodInfo.tips!.objectAtIndex(i) as! String) \n"
        }
        
        tipsBlock.text = tipString
        tipsBlock.setFrameWithOrign(CGPointMake(infoX, infoHeight-12), width: self.detailScrollView.width-10)
        self.detailScrollView.addSubview(tipsBlock)
        
        
        infoHeight += tipsBlock.height + 10
        self.bottomLineInfo.frame = CGRectMake(infoX, infoHeight, self.detailScrollView.width, 3.0)
        self.bottomLineInfo.drawType = "GrayLine"
        self.bottomLineInfo.lineWidth = 1.0
        self.detailScrollView.addSubview(self.bottomLineInfo)
        
        infoHeight += 3.0 + 10
        let wechatService: CustomDrawView = CustomDrawView(frame: CGRectMake(infoX, infoHeight, self.detailScrollView.width, 60))
        wechatService.drawType = "wechatService"
        self.detailScrollView.addSubview(wechatService)
        
        
        
        // Bottom Line
        self.bottomLineSpot.drawType = "DoubleLine"
        self.bottomLineSpot.frame = CGRectMake(0, self.spotLabel.height + 20.0, self.detailScrollView.width, 5.0)
        self.detailScrollView.addSubview(self.bottomLineSpot)
        
        let noMoreSpotView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, self.spotLabel.height + 30.0, self.detailScrollView.width, 60.0))
        noMoreSpotView.drawType = "noMore"
        noMoreSpotView.backgroundColor = UIColor.whiteColor()
        self.detailScrollView.addSubview(noMoreSpotView)
        
        
        self.bottomLineMenu.drawType = "DoubleLine"
        self.bottomLineMenu.frame = CGRectMake(self.detailScrollView.width, self.menuLabel.height + 240 + 20.0, self.detailScrollView.width, 5.0)
        self.detailScrollView.addSubview(self.bottomLineMenu)
        
        
        let noMoreMenuView: CustomDrawView = CustomDrawView(frame: CGRectMake(self.detailScrollView.width, self.menuLabel.height + 240 + 30.0, self.detailScrollView.width, 60.0))
        noMoreMenuView.drawType = "noMore"
        noMoreMenuView.backgroundColor = UIColor.whiteColor()
        self.detailScrollView.addSubview(noMoreMenuView)
        
        
        
    }
    
    func callStore() {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://\(self.foodInfo.tel1!)")!)
    }
    
    func showStoreMap() {
        
        let mapViewVC: VCMapViewController = VCMapViewController()
        mapViewVC.latitude = self.foodInfo.latitude!
        mapViewVC.longtitude = self.foodInfo.longitude!
        mapViewVC.pinTitle = self.foodInfo.storeName!
        mapViewVC.parentNav = self.parentNav!
        
        //        self.parentNav?.showViewController(mapViewVC, sender: self)
        self.parentNav?.pushViewController(mapViewVC, animated: true)
    }
    
    func setupViewConstraints() {
        
        self.photosView.autoSetDimensionsToSize(CGSizeMake(self.view.width, VCAppLetor.ConstValue.FoodImageHeight))
        self.photosView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        self.dateTagBg.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.photosView, withOffset: 20.0)
        self.dateTagBg.autoPinEdgeToSuperviewEdge(.Leading)
        self.dateTagBg.autoSetDimensionsToSize(CGSizeMake(90.0, 28.0))
        
        self.dateTagBg2.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.photosView, withOffset: 20.0)
        self.dateTagBg2.autoPinEdgeToSuperviewEdge(.Leading)
        self.dateTagBg2.autoSetDimensionsToSize(CGSizeMake(80.0, 28.0))
        
        self.dateTag.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.dateTagBg, withOffset: 4.0)
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
        //        self.remainTime.autoSetDimensionsToSize(CGSizeMake(80.0, 14.0))
        
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
        
        self.segForeView.autoPinEdgeToSuperviewEdge(.Top)
        self.segForeView.autoPinEdgeToSuperviewEdge(.Leading)
        self.segForeView.autoSetDimensionsToSize(CGSizeMake((self.view.width-40.0) / 3.0, 40.0))
        
        //self.detailSegmentControl?.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
        //self.detailSegmentControl?.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodTitle)
        //self.detailSegmentControl?.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.shareBtn, withOffset: 30.0)
        //self.detailSegmentControl?.autoSetDimension(.Height, toSize: 40.0)
        
        self.detailView.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.segBG)
        self.detailView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.segBG, withOffset: 10.0)
        self.detailView.autoSetDimension(.Width, toSize: self.view.width - 40.0)
        self.detailView.autoSetDimension(.Height, toSize: 200.0)
        
    }
    
    // Submit order action
    func checkNowAction() {
        
        let orderCheckViewController: VCCheckNowViewController = VCCheckNowViewController()
        orderCheckViewController.parentNav = self.parentNav
        orderCheckViewController.foodDetailVC = self
        orderCheckViewController.foodInfo = self.foodInfo
        self.parentNav!.showViewController(orderCheckViewController, sender: self)
    }
    
    func payNowAction() {
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let orderId = self.foodInfo.orderExist!
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetOrderDetail(memberId, orderId, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    let order: OrderInfo = OrderInfo(id: json["data"]["member_order_info"]["order_info"]["order_id"].string!, no: json["data"]["member_order_info"]["order_info"]["order_no"].string!)
                    
                    
                    order.title = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                    order.pricePU = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["special_price"].string!
                    order.priceUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["price"]["price_unit"].string!
                    order.totalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["special_price"].string!
                    order.originalTotalPrice = json["data"]["member_order_info"]["order_info"]["total_price"]["original_price"].string!
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                    order.createDate = dateFormatter.dateFromString(json["data"]["member_order_info"]["order_info"]["create_date"].string!)
                    order.createByMobile = json["data"]["member_order_info"]["order_info"]["mobile"].string!
                    
                    order.menuId = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_id"].string!
                    order.menuTitle = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_name"].string!
                    order.menuUnit = json["data"]["member_order_info"]["order_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                    order.itemCount = json["data"]["member_order_info"]["order_info"]["menu_info"]["count"].string!
                    
                    order.orderType = json["data"]["member_order_info"]["order_info"]["order_type"].string!
                    order.typeDescription = json["data"]["member_order_info"]["order_info"]["order_type_description"].string!
                    order.orderImageURL = json["data"]["member_order_info"]["article_info"]["article_image"]["source"].string!
                    order.foodId = json["data"]["member_order_info"]["article_info"]["article_id"].string!
                    
                    order.voucherId = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_member_id"].string!
                    order.voucherName = json["data"]["member_order_info"]["order_info"]["voucher_info"]["voucher_name"].string!
                    
                    
                    // Transfer to payment page
                    let paymentVC: VCPayNowViewController = VCPayNowViewController()
                    paymentVC.parentNav = self.parentNav
                    paymentVC.foodDetailVC = self
                    paymentVC.orderInfo = order
                    self.parentNav!.showViewController(paymentVC, sender: self)
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                
                println("ERROR @ Request for order detail with pay action in food view : \(error?.localizedDescription)")
            }
            
        })
        
    }
    
    // Share
    func shareFood() {
        
        self.shareView?.removeFromSuperview()
        
        self.shareView = VCShareActionView(frame: self.view.frame)
        self.shareView!.shareType = VCAppLetor.ShareToType.food
        self.shareView!.foodInfo = self.foodInfo
        self.view.addSubview(self.shareView!)
        
    }
    
    // add to OR remove from MY FAVORITE LIST
    func toggleFav() {
        
        if self.isLogin() {
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            
            var type = VCheckGo.CollectionEditType.add
            if self.foodInfo.isCollected! != "0" {
                type = VCheckGo.CollectionEditType.remove
            }
            
            let articleId = "\(self.foodInfo.id)"
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            Alamofire.request(VCheckGo.Router.EditMyCollection(memberId, type, articleId, token)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        if type == VCheckGo.CollectionEditType.add {
                            
                            self.likeBtn.titleStr.text = "\((self.foodInfo.favoriteCount! as NSString).integerValue + 1)"
                            self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteRed)
                            self.foodInfo.favoriteCount = self.likeBtn.titleStr.text
                            self.foodInfo.isCollected = "1"
                        }
                        else {
                            self.likeBtn.titleStr.text = "\((self.foodInfo.favoriteCount! as NSString).integerValue - 1)"
                            self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteBlack)
                            self.foodInfo.favoriteCount = self.likeBtn.titleStr.text
                            self.foodInfo.isCollected = "0"
                        }
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                    
                }
                else {
                    
                    println("ERROR @ Request to edit collection")
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            })
        }
        else {
            
            self.presentLoginPanel()
        }
        
        
    }
    
    func presentLoginPanel() {
        
        let userLoginController: VCMemberLoginViewController = VCMemberLoginViewController()
        userLoginController.modalPresentationStyle = .Popover
        userLoginController.modalTransitionStyle = .CoverVertical
        userLoginController.popoverPresentationController?.delegate = self
        userLoginController.delegate = self
        
        presentViewController(userLoginController, animated: true, completion: nil)
    }
    
    // if member sign in
    func isLogin() -> Bool {
        
        if let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as? String {
            
            if token != "0" {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
        
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.scrollView.contentOffset.y >= self.segBG.originY {
            
            self.segBGCopy.alpha = 1.0
        }
        else {
            self.segBGCopy.alpha = 0.0
        }
        
    }
    
    
    // MARK: - SMSegmentView Delegate
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        
        let segItemWidth: CGFloat = (self.view.width-40.0)/3.0
        
        self.segIndex = index
        
        var indexPage: CGFloat = 0.0
        
        if index == 1 {
            indexPage = 1.0
            
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineMenu.originY + 60.0)
        }
        else if index == 2 {
            indexPage = 2.0
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineInfo.originY + 80.0)
        }
        else {
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineSpot.originY + 60.0)
        }
        
        self.detailScrollView.contentSize = CGSizeMake(self.detailScrollView.width*3, self.detailScrollView.height)
        
        self.segForeView.animation.animationCompletion = {
            
            self.segForeView.alpha = 1.0
        }
        self.segForeView.animation.makeOrigin(segItemWidth * indexPage, 0).animate(0.2)
        self.segForeViewCopy.animation.makeOrigin(segItemWidth * indexPage, 0).animate(0.2)
        
        //        self.detailView.autoSetDimension(.Height, toSize: self.detailScrollView.height)
        self.scrollView.contentSize.width = self.view.width
        self.scrollView.contentSize.height = self.detailView.originY + self.detailScrollView.height + 10.0
        self.detailScrollView.scrollRectToVisible(CGRectMake(self.detailScrollView.width * indexPage, 0, self.detailScrollView.width, 400), animated: true)
        
        if self.scrollView.contentOffset.y >= self.segBG.originY {
            self.scrollView.contentOffset.y = segBG.originY
        }
        
        
        //        println("S:scroll: \(self.scrollView.contentSize)")
    }
    
    func resetDetailFrame() {
        
        let segItemWidth: CGFloat = (self.view.width-40.0)/3.0
        
        var page: Int = self.segIndex
        
        if page == 1 {
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineMenu.originY + 60.0)
        }
        else if page == 2 {
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineInfo.originY + 60.0)
        }
        else {
            self.detailScrollView.frame = CGRectMake(0, 0, self.view.width - 40.0, self.bottomLineSpot.originY + 60.0)
        }
        
        self.detailScrollView.contentSize = CGSizeMake(self.detailScrollView.width*3, self.detailScrollView.height)
        
        //self.detailView.autoSetDimension(.Height, toSize: self.detailScrollView.height)
        self.scrollView.contentSize.width = self.view.width
        self.scrollView.contentSize.height = self.detailView.originY + self.detailScrollView.height + 10.0
        self.detailScrollView.scrollRectToVisible(CGRectMake(self.detailScrollView.width * CGFloat(page), 0, self.detailScrollView.width, 400), animated: true)
        
        self.scrollContentSize = self.scrollView.contentSize
        
        
        println("R:scroll: \(self.scrollView.contentSize)")
    }
    
    // MARK: - Member register delegate
    
    func memberDidFinishRegister(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                    
                    
                    memberInfo.email = json["data"]["member_info"]["email"].string!
                    memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                    memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                    memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                    
                    // Listing Info
                    memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                    memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                    memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                    memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                    
                    // Share Info
                    memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                    memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                    memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                    memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                    
                    memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                    memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                    memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                    memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                    
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    // Get member info and refresh userinterface
                    BreezeStore.saveInMain({ (contextType) -> Void in
                        
                        let member = Member.createInContextOfType(contextType) as! Member
                        
                        member.mid = mid
                        member.email = memberInfo.email!
                        member.phone = memberInfo.mobile!
                        member.nickname = memberInfo.nickname!
                        member.iconURL = memberInfo.icon!
                        member.lastLog = NSDate()
                        member.token = token
                        
                    })
                    
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                println("ERROR @ Request for member info : \(error?.localizedDescription)")
            }
        })
        
        
    }
    
    func updateFoodInfo() {
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetProductDetailWithMember(self.foodInfo.id, memberId)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    // Unpaid order exist?
                    let foodOrder = json["data"]["article_info"]["order_info"]
                    
                    self.checkView.removeFromSuperview()
                    self.payView.removeFromSuperview()
                    
                    if foodOrder != "" {
                        
                        RKDropdownAlert.title(VCAppLetor.StringLine.HaveOrderWaitForPay, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                        self.foodInfo.orderExist = json["data"]["article_info"]["order_info"]["order_id"].string!
                        
                        self.setupPayView()
                        
                    }
                    else {
                        self.foodInfo.orderExist = "0"
                        self.setupCheckView()
                        self.setupCheckViewConstraints()
                        
                        if self.foodInfo.remainingCount! == "0" {
                            
                            self.checkNowBg.backgroundColor = UIColor.lightGrayColor()
                            self.checkNow.backgroundColor = UIColor.lightGrayColor()
                            self.checkNow.setTitle(self.foodInfo.outOfStock!, forState: .Normal)
                            self.checkNow.removeTarget(self, action: "checkNowAction", forControlEvents: .TouchUpInside)
                        }
                        
                        if self.foodInfo.remainder! == "0" {
                            
                            self.checkNowBg.backgroundColor = UIColor.lightGrayColor()
                            self.checkNow.backgroundColor = UIColor.lightGrayColor()
                            self.checkNow.setTitle(VCAppLetor.StringLine.isClose, forState: .Normal)
                            self.checkNow.removeTarget(self, action: "checkNowAction", forControlEvents: .TouchUpInside)
                        }
                    }
                    
                    
                    // Collection
                    self.foodInfo.favoriteCount = json["data"]["article_info"]["collection_info"]["collection_count"].string!
                    self.foodInfo.isCollected = json["data"]["article_info"]["collection_info"]["is_collected"].string!
                    
                    self.likeBtn.titleStr.text = "\(self.foodInfo.favoriteCount!)"
                    if self.foodInfo.isCollected != "0" {
                        
                        self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteRed)
                    }
                    else {
                        self.likeBtn.icon.image = UIImage(named: VCAppLetor.IconName.FavoriteBlack)
                    }
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
            }
            else {
                
                println("ERROR @ Request for Product Detail[Refresh] : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        })
        
        
    }
    
    
    // MARK: - Member Signin Delegate
    
    func memberDidSigninWithWechatSuccess(mid: String, token: String) {
        
    }
    
    func memberDidSigninSuccess(mid: String, token: String) {
        
        // Get member info which just finish register
        Alamofire.request(VCheckGo.Router.GetMemberInfo(token, mid)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    let memberInfo: MemberInfo = MemberInfo(mid: json["data"]["member_info"]["member_id"].string!)
                    
                    memberInfo.email = json["data"]["member_info"]["email"].string!
                    memberInfo.mobile = json["data"]["member_info"]["mobile"].string!
                    memberInfo.nickname = json["data"]["member_info"]["member_name"].string!
                    memberInfo.icon = json["data"]["member_info"]["icon_image"]["source"].string!
                    
                    // Listing Info
                    memberInfo.orderCount = json["data"]["order_info"]["order_total_count"].string!
                    memberInfo.orderPending = json["data"]["order_info"]["order_pending_count"].string!
                    memberInfo.collectionCount = json["data"]["collection_info"]["collection_total_count"].string!
                    memberInfo.voucherCount = json["data"]["voucher_info"]["voucher_total_count"].string!
                    memberInfo.voucherValid = json["data"]["voucher_info"]["voucher_use_count"].string!
                    
                    // Share Info
                    memberInfo.inviteCode = json["data"]["share_info"]["invite_code"].string!
                    memberInfo.inviteCount = json["data"]["share_info"]["invite_total_count"].string!
                    memberInfo.inviteTip = json["data"]["share_info"]["invite_people_tips"].string!
                    memberInfo.inviteRewards = json["data"]["share_info"]["invite_code_tips"].string!
                    
                    memberInfo.pushSwitch = json["data"]["push_info"]["push_switch"].string!
                    memberInfo.pushOrder = json["data"]["push_info"]["consume_msg"].string!
                    memberInfo.pushRefund = json["data"]["push_info"]["refund_msg"].string!
                    memberInfo.pushVoucher = json["data"]["push_info"]["voucher_msg"].string!
                    
                    // update local data
                    self.updateSettings(token, currentMid: mid)
                    
                    if let member = Member.findFirst(attribute: "mid", value: memberInfo.memberId, contextType: BreezeContextType.Main) as? Member {
                        
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            member.email = memberInfo.email!
                            member.phone = memberInfo.mobile!
                            member.nickname = memberInfo.nickname!
                            member.iconURL = memberInfo.icon!
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                    }
                    else { // Member login for the first time without register on the device
                        // Get member info and refresh userinterface
                        BreezeStore.saveInMain({ (contextType) -> Void in
                            
                            let member = Member.createInContextOfType(contextType) as! Member
                            
                            member.mid = memberInfo.memberId
                            member.email = memberInfo.email!
                            member.phone = memberInfo.mobile!
                            member.nickname = memberInfo.nickname!
                            member.iconURL = memberInfo.icon!
                            member.lastLog = NSDate()
                            member.token = token
                            
                        })
                        
                    }
                    
                    // Push user device token
                    pushDeviceToken(VCheckGo.PushDeviceType.add)
                    
                    
                    // setup cache & user panel interface
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                    //self.updateFoodInfo()
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
            }
            else {
                println("ERROR @ Request for member info : \(error?.localizedDescription)")
            }
        })
    }
    
    func updateSettings(tokenStr: String, currentMid: String) {
        
        // Cache token
        
        if  let token = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optToken, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                token.sid = "\(NSDate())"
                token.value = tokenStr
                
                println("update token after login \(token.value)")
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optToken, data: tokenStr, namespace: "token")
            
        }
        
        // update local data
        if let isLogin = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameIsLogin, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                isLogin.sid = "\(NSDate())"
                isLogin.value = "1"
                
            })
            
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameIsLogin, data: true, namespace: "member")
        }
        
        if let cMid = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameCurrentMid, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                cMid.sid = "\(NSDate())"
                cMid.value = currentMid
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameCurrentMid, data: currentMid, namespace: "member")
        }
        
        if let loginType = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.optNameLoginType, contextType: BreezeContextType.Main) as? Settings {
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                loginType.sid = "\(NSDate())"
                loginType.value = VCAppLetor.LoginType.PhoneReg
                
            })
            
            CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optNameLoginType, data: VCAppLetor.LoginType.PhoneReg, namespace: "member")
        }
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
    
    var didSetConstraints = false
    
    func setupView() {
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.icon)
        
        self.titleStr.textAlignment = .Center
        self.titleStr.textColor = UIColor.blackColor()
        self.titleStr.font = VCAppLetor.Font.LightXSmall
        self.addSubview(self.titleStr)
        
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        
        if !self.didSetConstraints {
            
            self.icon.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 10.0, 10.0, 0.0), excludingEdge: .Trailing)
            self.icon.autoMatchDimension(.Width, toDimension: .Height, ofView: self, withOffset: -20.0)
            
            self.titleStr.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.icon, withOffset: 10.0)
            self.titleStr.autoAlignAxisToSuperviewAxis(.Horizontal)
            self.titleStr.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10.0)
            self.titleStr.autoMatchDimension(.Height, toDimension: .Height, ofView: self.icon, withMultiplier: 0.6)
            
            self.didSetConstraints = true
        }
        
        super.updateConstraints()
        
    }
    
}




