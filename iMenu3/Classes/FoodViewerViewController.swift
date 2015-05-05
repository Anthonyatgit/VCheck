//
//  FoodViewerViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/27.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit

class FoodViewerViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate {
    
    var foodIdentifier: String?
    
    let scrollView = UIScrollView()
    
    var foodInfo: FoodItem?
    
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // A scroll view is used to show all content
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: CGRectGetWidth(scrollView.frame), height: CGRectGetHeight(scrollView.frame)*2)
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        let otherText: UILabel = UILabel()
        otherText.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        otherText.text = self.foodIdentifier
        scrollView.addSubview(otherText)
        println(self.foodIdentifier)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
}
