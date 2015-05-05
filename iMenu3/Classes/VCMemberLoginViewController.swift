//
//  VCMemberLoginViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/5.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit

class VCMemberLoginViewController: UIViewController {
    
    let scrollView: UIScrollView = UIScrollView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        
        let loginTitle: UILabel = UILabel()
        loginTitle.text = VCAppLetor.LOGINTITLE
        loginTitle.font = UIFont.systemFontOfSize(16.0)
        loginTitle.textColor = UIColor.blackColor()
        loginTitle.center = CGPointMake(view.bounds.width / 2, 30.0)
        loginTitle.frame.size = CGSizeMake(300.0, 20.0)
        self.scrollView.addSubview(loginTitle)
        
        let loginName: UITextField = UITextField()
        let loginPass: UITextField = UITextField()
        let signUpText: UILabel = UILabel()
        let signUpButton: UIButton = UIButton()
        
        let socialSignInTitle: UILabel = UILabel()
        let sinaSignInButton: UIButton = UIButton()
        let weichatSignInButton: UIButton = UIButton()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Do some cleanup when dealloc
        
    }
    
    
    
    
    
    
    
    
}
