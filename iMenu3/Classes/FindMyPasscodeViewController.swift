//
//  FindMyPasscodeViewController.swift
//  
//
//  Created by Gabriel Anthony on 15/5/8.
//
//

import UIKit

class FindMyPasscodeViewController: UIViewController {
    
    
    let phoneNumber: FloatLabelTextField = FloatLabelTextField()
    var parentNav: UINavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.FindBackMyPassTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "getAuthCode")
        
        self.phoneNumber.frame = CGRectMake(60, 82, 200, 30)
        self.phoneNumber.placeholder = VCAppLetor.StringLine.LoginName
        self.phoneNumber.clearButtonMode = .WhileEditing
        self.phoneNumber.keyboardType = UIKeyboardType.EmailAddress
        self.view.addSubview(phoneNumber)
        
        let phoneUnderline: UIView = UIView(frame: CGRectMake(40, 114, 240, 1))
        phoneUnderline.backgroundColor = UIColor.blackColor()
        self.view.addSubview(phoneUnderline)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: Functions
    
    func getAuthCode() {

        let code = arc4random_uniform(9)
        println("\(code)")
        
        let smsCodeViewController: SMSCodeViewController = SMSCodeViewController()
        smsCodeViewController.parentNav = self.parentNav
        smsCodeViewController.view.bounds = self.view.bounds
        smsCodeViewController.phoneNumber.text = self.phoneNumber.text
        self.parentNav?.showViewController(smsCodeViewController, sender: self)
    }
    
    
    
    
}



