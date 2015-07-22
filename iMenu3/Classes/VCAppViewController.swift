//
//  VCAppViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/8.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire


class VCAppViewController: VCBaseViewController {
    
    
    var launchImage: UIImageView!
    
    // MARK: - Life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Launch Image
        self.launchImage = UIImageView(frame: self.view.frame)
        self.launchImage.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.launchImage)
        
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
                                
                            }
                        })
                    }
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
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Functions
    
    
    func removeIndexImage() {
        
        performSegueWithIdentifier("showtime", sender: self)
    }
    
    
    
}
