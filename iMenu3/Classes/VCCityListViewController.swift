//
//  VCCityListViewController.swift
//  iMenu3
//  NOT IN USE ===================
//
//  Created by Gabriel Anthony on 15/6/12.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout


class VCCityListViewController: VCBaseViewController {
    
    let scrollView: UIScrollView = UIScrollView()
    
    var cityList: NSMutableArray?
    var cityNames: NSMutableArray = NSMutableArray()
    
    let serviceCityTitle: UILabel = UILabel.newAutoLayoutView()
    let serviceCityTitleUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let serviceCityNote: UILabel = UILabel.newAutoLayoutView()
    
    let cityListView: UIView = UIView.newAutoLayoutView()
    
    let closeButton: UIButton = UIButton.newAutoLayoutView()
    
    var tapGuesture: UITapGestureRecognizer!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.darkGrayColor()
        
        self.setupCityList()
//        self.setupVSView()
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
        self.tapGuesture = UITapGestureRecognizer(target: self, action: "viewDidTap:")
        self.tapGuesture.numberOfTapsRequired = 1
        self.tapGuesture.numberOfTouchesRequired = 1
        
        self.scrollView.addGestureRecognizer(self.tapGuesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.serviceCityTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 80.0)
        self.serviceCityTitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 40.0)
        self.serviceCityTitle.autoSetDimensionsToSize(CGSizeMake(self.scrollView.width - 80.0, 30.0))
        
        self.serviceCityTitleUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.serviceCityTitle)
        self.serviceCityTitleUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.serviceCityTitle, withOffset: 10.0)
        self.serviceCityTitleUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.serviceCityTitle)
        self.serviceCityTitleUnderline.autoSetDimension(.Height, toSize: 5.0)
        
        self.serviceCityNote.autoPinEdgeToSuperviewEdge(.Top, withInset: self.scrollView.height - 50.0)
        self.serviceCityNote.autoAlignAxisToSuperviewAxis(.Vertical)
        self.serviceCityNote.autoSetDimension(.Width, toSize: self.scrollView.width-80.0)
        self.serviceCityNote.autoSetDimension(.Height, toSize: 20.0)
        
        println("not: \(self.serviceCityNote.frame)")
        
        self.cityListView.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.serviceCityTitle)
        self.cityListView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.serviceCityTitleUnderline, withOffset: 20.0)
        self.cityListView.autoSetDimensionsToSize(CGSizeMake(self.scrollView.width - 80.0, 160.0))
        
        for (var i=0; i<self.cityNames.count; i++) {
            self.cityNames[i].autoPinEdge(.Leading, toEdge: .Leading, ofView: self.serviceCityTitle)
            if i>0 {
                self.cityNames[i].autoPinEdge(.Top, toEdge: .Bottom, ofView: self.cityNames[i-1] as! UIView, withOffset: 40.0)
            }
            else {
                self.cityNames[i].autoPinEdge(.Top, toEdge: .Bottom, ofView: self.serviceCityTitleUnderline, withOffset: 40.0)
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Functions
    
    func setupVSView() {
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.scrollView.frame
        
        
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = self.scrollView.frame
        
        vibrancyView.contentView.addSubview(self.closeButton)
        visualEffectView.contentView.addSubview(vibrancyView)
        
        
        self.scrollView.addSubview(visualEffectView)
    }
    
    func setupCityList() {
        
        self.serviceCityTitle.text = VCAppLetor.StringLine.ServiceCityTitle
        self.serviceCityTitle.font = VCAppLetor.Font.NormalFont
        self.serviceCityTitle.textAlignment = .Left
        self.serviceCityTitle.textColor = UIColor.whiteColor()
        self.scrollView.addSubview(self.serviceCityTitle)
        
        self.serviceCityTitleUnderline.drawType = "DoubleLine"
        self.serviceCityTitleUnderline.lineColor = UIColor.whiteColor()
        self.scrollView.addSubview(self.serviceCityTitleUnderline)
        
        self.serviceCityNote.text = VCAppLetor.StringLine.ServiceCityNote
        self.serviceCityNote.font = VCAppLetor.Font.SmallFont
        self.serviceCityNote.textAlignment = .Center
        self.serviceCityNote.textColor = UIColor.lightGrayColor()
        self.scrollView.addSubview(self.serviceCityNote)
        
        if self.cityList?.count > 0 {
            
            for (var i=0; i<self.cityList!.count; i++) {
                
                var cityItem: CityInfo = self.cityList?.objectAtIndex(i) as! CityInfo
                
                let cityNameLabel: UILabel = UILabel.newAutoLayoutView()
                cityNameLabel.text = cityItem.city_name
                cityNameLabel.textAlignment = .Left
                cityNameLabel.textColor = UIColor.whiteColor()
                cityNameLabel.font = VCAppLetor.Font.XXXLarge
                self.cityListView.addSubview(cityNameLabel)
                
                self.cityNames.addObject(cityNameLabel)
                
            }
        }
        
        
        self.scrollView.addSubview(self.cityListView)
        
//        self.closeButton.setImage(UIImage(named: VCAppLetor.IconName.ClearIconBlack), forState: .Normal)
//        self.closeButton.addTarget(self, action: "didCloseButtonTouch", forControlEvents: .TouchUpInside)
//        
//        self.scrollView.addSubview(self.closeButton)
        
    }
    
    func viewDidTap(gesture: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func didCloseButtonTouch() {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            // Do something after close the city list view
        })
    }
    
}
