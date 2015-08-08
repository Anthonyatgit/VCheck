//
//  VCBaseViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/27.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import RKDropdownAlert

class VCBaseViewController: UIViewController {
    
    
    // Internet connection Reachability
    let reachability = Reachability.reachabilityForInternetConnection()
    
    // Detection of loading action
    let isInitReady: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Reachablity Observer
        if VCAppLetor.ConstValue.ReachableClosures {
            reachability.whenReachable = { reachability in
                
            }
            reachability.whenUnreachable = { reachability in
                
            }
        }
        else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        }
        
        reachability.startNotifier()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reachabilityChanged(notification: NSNotification) {
        
        var internetStat: String = ""
        var bgColor: UIColor = UIColor.nephritisColor()
        if self.reachability.isReachableViaWiFi() {
            internetStat = "Connection: Via WIFI"
        }
        else if self.reachability.isReachableViaWWAN() {
            internetStat = "Connection: Via Cellular"
        }
        else if !self.reachability.isReachable() {
            internetStat = "NO Internet"
            bgColor = UIColor.alizarinColor()
            //RKDropdownAlert.title(internetStat, backgroundColor: bgColor, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
        
        //RKDropdownAlert.title(internetStat, backgroundColor: bgColor, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
    }
    
    
}