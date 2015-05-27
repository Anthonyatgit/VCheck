//
//  VCTermsViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/15.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class VCTermsViewController: UIViewController {
    
    let scrollView: UIScrollView = UIScrollView.newAutoLayoutView()
    
    let contentView: UIWebView = UIWebView.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserTerms
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
//        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.contentView.loadRequest(NSURLRequest(URL: NSURL(string: VCAppLetor.StringLine.TermsURL)!))
        self.contentView.scalesPageToFit = true
        self.contentView.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(self.contentView)
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 5.0, 10.0, 5.0), excludingEdge: ALEdge.Top)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
