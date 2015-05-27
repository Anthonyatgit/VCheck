//
//  ResetMyPasscodeViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/9.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit


class ResetMyPasscodeViewController: UIViewController {
    
    
    let newPasscode: UITextField = UITextField()
    let againPasscode: UITextField = UITextField()
    
    var phoneNumber: String?
    
    var parentNav: UINavigationController?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.ResetYourPasscode
        self.view.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Done, style: .Done, target: self, action: "resetPasscode")
        
        self.newPasscode.frame = CGRectMake(60, 82, 200, 30)
        self.newPasscode.font = VCAppLetor.Font.NormalFont
        self.newPasscode.secureTextEntry = true
        self.newPasscode.placeholder = VCAppLetor.StringLine.NewPasscode
        self.view.addSubview(self.newPasscode)
        
        let newPassUnderline: UIView = UIView(frame: CGRectMake(40, 114, 240, 1))
        newPassUnderline.backgroundColor = UIColor.blackColor()
        self.view.addSubview(newPassUnderline)
        
        self.againPasscode.frame = CGRectMake(60, 132, 200, 30)
        self.againPasscode.font = VCAppLetor.Font.NormalFont
        self.againPasscode.secureTextEntry = true
        self.againPasscode.placeholder = VCAppLetor.StringLine.AgainPasscode
        self.view.addSubview(self.againPasscode)
        
        let againPassUnderline: UIView = UIView(frame: CGRectMake(40, 164, 240, 1))
        againPassUnderline.backgroundColor = UIColor.blackColor()
        self.view.addSubview(againPassUnderline)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // Functions
    
    func resetPasscode() {
        
        // Reset Passcode for phone number: self.phoneNumber
        
        // Return to Login Page
        parentNav?.popToRootViewControllerAnimated(true)
    }
    
    
    
    
    
}
