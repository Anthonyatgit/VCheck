//
//  VCAppViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/8.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import RKDropdownAlert
import DKChainableAnimationKit

class VCAppViewController: VCBaseViewController {
    
    var videoVC: JSVideoViewController?
    
    var launchImage: UIImageView!
    var tapBtn: UIButton!
    
    var route: String?
    var param: String?
    
    let skipButton: UIButton = UIButton.newAutoLayoutView()
    
    // MARK: - Life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoTag = Settings.findFirst(attribute: "name", value: VCAppLetor.SettingName.VideoTag, contextType: BreezeContextType.Main) as? Settings { // Get current app version
            
            if videoTag.value == "1" {
                
                self.showIndexPage()
                
            }
            else {
                
                self.showVideo()
            }
            
        }
        else { // App version DO NOT exist, create one with version "1.0"
            
            BreezeStore.saveInMain({ contextType -> Void in
                
                let videoTagToBeCreate: Settings = Settings.createInContextOfType(contextType) as! Settings
                
                videoTagToBeCreate.sid = "\(NSDate())"
                videoTagToBeCreate.name = VCAppLetor.SettingName.VideoTag
                videoTagToBeCreate.value = "0"
                videoTagToBeCreate.type = VCAppLetor.SettingType.AppConfig
                videoTagToBeCreate.data = ""
                
            })
            
            self.showVideo()
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Functions
    
    func showVideo() {
        
        // Attach Video View
        self.videoVC = JSVideoViewController()
        self.videoVC!.view.frame = self.view.frame
        self.view.addSubview(self.videoVC!.view)
        
        NSTimer.scheduledTimerWithTimeInterval(VCAppLetor.ConstValue.VideoShowTime, target: self, selector: "removeVideo", userInfo: nil, repeats: false)
        
    }
    
    func showIndexPage() {
        
        // Launch Image
        self.launchImage = UIImageView(frame: self.view.frame)
        self.launchImage.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.launchImage)
        
        self.tapBtn = UIButton(frame: self.view.frame)
        self.tapBtn.setTitle("", forState: .Normal)
        self.tapBtn.setTitleColor(UIColor.clearColor(), forState: .Normal)
        self.tapBtn.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.tapBtn)
        
        self.skipButton.setTitle(VCAppLetor.StringLine.SkipLaunchImage, forState: .Normal)
        self.skipButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.skipButton.titleLabel?.font = VCAppLetor.Font.LightSmall
        self.skipButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.skipButton.layer.cornerRadius = 6
        self.skipButton.alpha = 0.5
        self.skipButton.addTarget(self, action: "removeIndexImage", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.skipButton)
        
        self.skipButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 40.0)
        self.skipButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
        self.skipButton.autoSetDimensionsToSize(CGSizeMake(84.0, 24.0))
        
        
        var indexImageUrl: String = ""
        
        Alamofire.request(VCheckGo.Router.GetIndexImage("2")).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    indexImageUrl = json["data"]["banner_info"]["image"]["source"].string!
                    
                    Alamofire.request(.GET, indexImageUrl).validate(contentType: ["image/*"]).responseImage() {
                        (_, _, image, error) in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if error == nil && image != nil {
                                
                                let indexImage: UIImage = Toucan.Resize.resizeImage(image!, size: self.view.size, fitMode: Toucan.Resize.FitMode.Crop)
                                
                                self.launchImage.image = indexImage
                                
                                self.view.animation.makeAlpha(1.0).animate(1.0)
                                
                            }
                        })
                    }
                    
                    self.route = json["data"]["banner_info"]["link_info"]["link_route"].string!
                    self.param = json["data"]["banner_info"]["link_info"]["link_value"].string!
                    
                    if self.route == VCAppLetor.PNRoute.article.rawValue ||
                        self.route == VCAppLetor.PNRoute.orderDetail.rawValue {
                            
                            let idArr = self.param!.componentsSeparatedByString("=") as NSArray
                            self.param = idArr[1] as? String
                    }
                    
                    self.tapBtn.addTarget(self, action: "addTapAction:", forControlEvents: .TouchUpInside)
                    
                }
                else {
                    println("Get index image fail: " + json["status"]["error_desc"].string!)
                }
            }
            else {
                println("ERROR @ Request for indexImage url : \(error?.localizedDescription)")
                
            }
            
        })
        
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "removeIndexImage", userInfo: nil, repeats: false)
    }
    
    func addTapAction(tap: UIButton) {
        
        CTMemCache.sharedInstance.set(VCAppLetor.INDEX.route, data: self.route, namespace: "indexPage")
        CTMemCache.sharedInstance.set(VCAppLetor.INDEX.param, data: self.param, namespace: "indexPage")
        
        self.removeIndexImage()
        
    }
    
    func removeVideo() {
        
        self.videoVC?.view.animation.makeAlpha(0).animateWithCompletion(2.0, {
            
            self.view.removeFromSuperview()
        })
        
        
        //self.view.alpha = 0.1
        //self.showIndexPage()
        
    }
    
    
    func removeIndexImage() {
        
        performSegueWithIdentifier("showtime", sender: self)
    }
    
    
    
}
