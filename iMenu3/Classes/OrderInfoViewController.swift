//
//  OrderInfoViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import HYBLoopScrollView
import DKChainableAnimationKit

class OrderInfoViewController: VCBaseViewController, UIScrollViewDelegate {
    
    var foodItem: FoodItem?
    
    var orderInfo: OrderInfo?
    
    var parentNav: UINavigationController?
    
    var didSetupConstraints = false
    
    
    // MARK: - LifetimeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func updateViewConstraints() {
        
        if !self.didSetupConstraints {
            
            self.didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}
