//
//  VCBaseViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/27.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import RKDropdownAlert
import MBProgressHUD

class VCBaseViewController: UIViewController {
    
    
    // Internet connection Reachability
    let reachability = Reachability.reachabilityForInternetConnection()
    
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
    
    
}