//
//  ResetMyPasscodeViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/9.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert
import AFViewShaker
import MBProgressHUD

class ResetMyPasscodeViewController: VCBaseViewController, UITextFieldDelegate {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let newPasscode: UITextField = UITextField.newAutoLayoutView()
    let againPasscode: UITextField = UITextField.newAutoLayoutView()
    let newPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let againPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var passSacker: AFViewShaker?
    
    var parentNav: UINavigationController?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.ResetYourPasscode
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Done, style: .Done, target: self, action: "resetPasscode")
        
        self.newPasscode.font = VCAppLetor.Font.NormalFont
        self.newPasscode.secureTextEntry = true
        self.newPasscode.clearsOnBeginEditing = true
        self.newPasscode.textAlignment = .Left
        self.newPasscode.keyboardType = UIKeyboardType.EmailAddress
        self.newPasscode.returnKeyType = UIReturnKeyType.Next
        self.newPasscode.tag = 1
        self.newPasscode.placeholder = VCAppLetor.StringLine.NewPasscode
        self.scrollView.addSubview(self.newPasscode)
        
        self.newPassUnderline.drawType = "Line"
        self.newPassUnderline.lineWidth = 1.0
        self.scrollView.addSubview(newPassUnderline)
        
        self.againPasscode.font = VCAppLetor.Font.NormalFont
        self.againPasscode.secureTextEntry = true
        self.againPasscode.clearsOnBeginEditing = true
        self.againPasscode.textAlignment = .Left
        self.againPasscode.keyboardType = UIKeyboardType.EmailAddress
        self.againPasscode.returnKeyType = UIReturnKeyType.Done
        self.againPasscode.placeholder = VCAppLetor.StringLine.AgainPasscode
        self.scrollView.addSubview(self.againPasscode)
        
        self.againPassUnderline.drawType = "Line"
        self.againPassUnderline.lineWidth = 1.0
        self.scrollView.addSubview(againPassUnderline)
        
        self.passSacker = AFViewShaker(viewsArray: [self.newPasscode, self.againPasscode])
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.newPasscode.autoPinEdgeToSuperviewEdge(.Top, withInset: 40.0)
        self.newPasscode.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.newPasscode.autoAlignAxisToSuperviewAxis(.Vertical)
        self.newPasscode.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        
        self.newPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.newPasscode, withOffset: 3.0)
        self.newPassUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.newPasscode, withOffset: -10.0)
        self.newPassUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.newPasscode, withOffset: 10.0)
        self.newPassUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.againPasscode.autoMatchDimension(.Width, toDimension: .Width, ofView: self.newPasscode)
        self.againPasscode.autoMatchDimension(.Height, toDimension: .Height, ofView: self.newPasscode)
        self.againPasscode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.newPasscode, withOffset: VCAppLetor.ConstValue.LineGap)
        self.againPasscode.autoAlignAxis(.Vertical, toSameAxisOfView: self.newPasscode)
        
        self.againPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.againPasscode, withOffset: 3.0)
        self.againPassUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.newPassUnderline)
        self.againPassUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.newPassUnderline)
        self.againPassUnderline.autoSetDimension(.Height, toSize: 3.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: - Functions
    
    func resetPasscode() {
        
        self.newPasscode.resignFirstResponder()
        self.againPasscode.resignFirstResponder()
        
        let newPass = self.newPasscode.text
        let againPass = self.againPasscode.text
        // Reset Passcode for phone number: self.phoneNumber
        if newPass == "" || againPass == "" || newPass != againPass || count(newPass) < 6 {
            self.passSacker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.PassNotMatch, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else {
            
            if self.reachability.isReachable() {
                
                let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Determinate
                
                let mobile = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
                let code = (CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.SaltCode, namespace: "member")?.data as! String + VCAppLetor.StringLine.SaltKey).md5
                
                Alamofire.request(VCheckGo.Router.ResetPassword(mobile, newPass, VCheckGo.LoginType.Mobile, code)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string == "1" {
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.ResetPassDone, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            // Return to Login Page
                            self.parentNav?.popToRootViewControllerAnimated(true)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        RKDropdownAlert.title(error?.localizedDescription, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                })
                
                hud.hide(true)
            }
            else {
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        }
        
    }
    
    
    // MARK: - UITextFiledDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            self.againPasscode.becomeFirstResponder()
        }
        else {
            self.resetPasscode()
        }
        return true
    }
    
    
}
