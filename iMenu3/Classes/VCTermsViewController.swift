//
//  VCTermsViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/15.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout

class VCTermsViewController: VCBaseViewController, UIScrollViewDelegate {
    
    let contentView: UIWebView = UIWebView.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = UIView.new()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.UserTerms
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.contentView.loadRequest(NSURLRequest(URL: NSURL(string: VCAppLetor.StringLine.TermsURL)!))
        self.contentView.scalesPageToFit = true
        self.contentView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.contentView)
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
        self.contentView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 5.0, 10.0, 5.0), excludingEdge: .Top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
