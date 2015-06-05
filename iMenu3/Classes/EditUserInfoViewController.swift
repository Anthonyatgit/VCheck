//
//  EditUserInfoViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/29.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert
import AFViewShaker
import MBProgressHUD

protocol EditUserInfoDelegate {
    func didFinishEditingMemberInfo(email: String, nickname: String)
}

class EditUserInfoViewController: VCBaseViewController, UITextFieldDelegate {
    
    var delegate: EditUserInfoDelegate?
    
    var parentNav: UINavigationController?
    
    let scrollView: UIScrollView = UIScrollView()
    
    var editType: VCAppLetor.EditType?
    
    let email: UITextField = UITextField.newAutoLayoutView()
    let nickname: UITextField = UITextField.newAutoLayoutView()
    let currentPass: UITextField = UITextField.newAutoLayoutView()
    let newPass: UITextField = UITextField.newAutoLayoutView()
    let againPass: UITextField = UITextField.newAutoLayoutView()
    
    var emailShaker: AFViewShaker?
    var nicknameShaker: AFViewShaker?
    var currentPassShacker: AFViewShaker?
    var newPassShacker: AFViewShaker?
    
    let emailUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let nicknameUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let currentPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let newPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let againPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    // MARK : - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Done, style: .Done, target: self, action: "editDone")
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        // Setup edit interface by Edit Type
        self.setupView()
        
        self.view.addSubview(self.scrollView)
        self.view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.editType == VCAppLetor.EditType.Email {
            
            self.email.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
            self.email.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.7)
            self.email.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
            self.email.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.emailUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.email, withOffset: 3.0)
            self.emailUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.email, withOffset: 20.0)
            self.emailUnderline.autoSetDimension(.Height, toSize: 3.0)
            self.emailUnderline.autoAlignAxis(.Vertical, toSameAxisOfView: self.email)
            
        }
        else if self.editType == VCAppLetor.EditType.Nickname {
            
            self.nickname.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
            self.nickname.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.7)
            self.nickname.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
            self.nickname.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.nicknameUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.nickname, withOffset: 3.0)
            self.nicknameUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.nickname, withOffset: 20.0)
            self.nicknameUnderline.autoSetDimension(.Height, toSize: 3.0)
            self.nicknameUnderline.autoAlignAxis(.Vertical, toSameAxisOfView: self.nickname)
        }
        else if self.editType == VCAppLetor.EditType.Password {
            
            self.currentPass.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
            self.currentPass.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.7)
            self.currentPass.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
            self.currentPass.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.currentPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.nickname, withOffset: 3.0)
            self.currentPassUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.nickname, withOffset: 20.0)
            self.currentPassUnderline.autoSetDimension(.Height, toSize: 3.0)
            self.currentPassUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.newPass.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.currentPassUnderline, withOffset: VCAppLetor.ConstValue.LineGap)
            self.newPass.autoMatchDimension(.Width, toDimension: .Width, ofView: self.currentPass)
            self.newPass.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
            self.newPass.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.newPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.newPass, withOffset: 3.0)
            self.newPassUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.currentPassUnderline)
            self.newPassUnderline.autoSetDimension(.Height, toSize: 3.0)
            self.newPassUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.againPass.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.newPassUnderline, withOffset: VCAppLetor.ConstValue.LineGap)
            self.againPass.autoMatchDimension(.Width, toDimension: .Width, ofView: self.currentPass)
            self.againPass.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
            self.againPass.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.againPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.againPass, withOffset: 3.0)
            self.againPassUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.currentPassUnderline)
            self.againPassUnderline.autoSetDimension(.Height, toSize: 3.0)
            self.againPassUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK : - Functions
    
    func setupView() {
        
        if self.editType == VCAppLetor.EditType.Email {
            
            self.title = VCAppLetor.StringLine.EditMemberEmail
            
            self.email.placeholder = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Email, namespace: "member")?.data as? String
            self.email.clearButtonMode = .WhileEditing
            self.email.keyboardType = UIKeyboardType.EmailAddress
            self.email.textAlignment = .Left
            self.email.font = VCAppLetor.Font.BigFont
            self.email.delegate = self
            self.scrollView.addSubview(self.email)
            
            self.emailShaker = AFViewShaker(view: self.email)
            
            self.emailUnderline.drawType = "Line"
            self.emailUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.emailUnderline)
            
            self.email.becomeFirstResponder()
            
        }
        else if self.editType == VCAppLetor.EditType.Nickname {
            
            self.title = VCAppLetor.StringLine.EditMemberNickname
            
            self.nickname.placeholder = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Nickname, namespace: "member")?.data as? String
            self.nickname.clearButtonMode = .WhileEditing
            self.nickname.keyboardType = UIKeyboardType.EmailAddress
            self.nickname.textAlignment = .Left
            self.nickname.font = VCAppLetor.Font.BigFont
            self.nickname.delegate = self
            self.scrollView.addSubview(self.nickname)
            
            self.nicknameShaker = AFViewShaker(view: self.nickname)
            
            self.nicknameUnderline.drawType = "Line"
            self.nicknameUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.nicknameUnderline)
            
            self.nickname.becomeFirstResponder()
            
        }
        else if self.editType == VCAppLetor.EditType.Password {
            
            self.title = VCAppLetor.StringLine.EditMemberPassowrd
            
            self.currentPass.placeholder = VCAppLetor.StringLine.CurrentPass
            self.currentPass.keyboardType = UIKeyboardType.EmailAddress
            self.currentPass.textAlignment = .Left
            self.currentPass.font = VCAppLetor.Font.BigFont
            self.currentPass.secureTextEntry = true
            self.scrollView.addSubview(self.currentPass)
            
            self.currentPassShacker = AFViewShaker(view: self.currentPass)
            
            self.currentPassUnderline.drawType = "Line"
            self.currentPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.currentPassUnderline)
            
            self.newPass.placeholder = VCAppLetor.StringLine.CurrentPass
            self.newPass.keyboardType = UIKeyboardType.EmailAddress
            self.newPass.textAlignment = .Left
            self.newPass.font = VCAppLetor.Font.BigFont
            self.newPass.secureTextEntry = true
            self.scrollView.addSubview(self.newPass)
            
            self.newPassUnderline.drawType = "Line"
            self.newPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.newPassUnderline)
            
            self.againPass.placeholder = VCAppLetor.StringLine.CurrentPass
            self.againPass.keyboardType = UIKeyboardType.EmailAddress
            self.againPass.textAlignment = .Left
            self.againPass.font = VCAppLetor.Font.BigFont
            self.againPass.secureTextEntry = true
            self.scrollView.addSubview(self.againPass)
            
            self.againPassUnderline.drawType = "Line"
            self.againPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.againPassUnderline)
            
            self.newPassShacker = AFViewShaker(viewsArray: [self.newPass, self.againPass])
            
            self.currentPass.becomeFirstResponder()
        }
    }
    
    func editDone() {
        
        if self.editType == VCAppLetor.EditType.Email {
            
            let email = self.email.text
            self.email.resignFirstResponder()
            
            if email == "" || !self.isEmail(email) {
                self.emailShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.EmailIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else {
                
                let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Indeterminate
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.EditMemberEmail(memberId, email, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        if json["status"]["succeed"].string == "1" {
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.EditEmailSuccess, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            self.delegate?.didFinishEditingMemberInfo(email, nickname: "")
                            self.parentNav?.popViewControllerAnimated(true)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ Request for edit member email : \(error?.localizedDescription)")
                    }
                })
                
                
                hud.hide(true)
            }
        }
        else if self.editType == VCAppLetor.EditType.Nickname {
            
            let nicknameText = self.nickname.text
            self.nickname.resignFirstResponder()
            
            if nicknameText == "" || count(nicknameText) < 3 || count(nicknameText) > 20 {
                self.nicknameShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.NicknameTooShort, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else {
                
                let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Indeterminate
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.EditMemberNickname(memberId, nicknameText, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        if json["status"]["succeed"].string == "1" {
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.EditNicknameSuccess, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            self.delegate?.didFinishEditingMemberInfo("", nickname: nicknameText)
                            self.parentNav?.popViewControllerAnimated(true)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ Request for edit member nickname : \(error?.localizedDescription)")
                    }
                })
                
                
                hud.hide(true)
            }
            
        }
        else if self.editType == VCAppLetor.EditType.Password {
            
            let currentPassText = self.currentPass.text
            let newPassText = self.newPass.text
            let againPassText = self.againPass.text
            
            self.againPass.resignFirstResponder()
            
            if  count(currentPassText) < 6 {
                self.currentPassShacker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.PasswordTooShort, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else if count(newPassText) < 6 || count(againPassText) < 6 {
                self.newPassShacker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.PasswordTooShort, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else if newPassText != againPassText {
                self.newPassShacker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.newpassNotMatch, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            else {
                
                let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Indeterminate
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.EditMemberPassword(memberId, currentPassText, newPassText, token)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        if json["status"]["succeed"].string == "1" {
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.EditPasswordSuccess, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            self.parentNav?.popViewControllerAnimated(true)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ Request for edit member password : \(error?.localizedDescription)")
                    }
                })
                
                
                hud.hide(true)
            }
            
            
        }
    }
    
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.editDone()
        return true
    }
    
    func isEmail(email: String) -> Bool {
        
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
    
}



