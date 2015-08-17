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

protocol MemberAuthDelegate {
    func didMemberFinishAuthMobile(mid: String, token: String)
}

class EditUserInfoViewController: VCBaseViewController, UITextFieldDelegate {
    
    var delegate: EditUserInfoDelegate?
    
    var mobileDelegate: MemberAuthDelegate?
    
    var parentNav: UINavigationController?
    
    var memberInfo: MemberInfo?
    
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
    
    let requireMobile: UILabel = UILabel.newAutoLayoutView()
    let mobile: UITextField = UITextField.newAutoLayoutView()
    let mobileUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let sendVerifyBtn: UIButton = UIButton.newAutoLayoutView()
    let verifyCode: UITextField = UITextField.newAutoLayoutView()
    let verifyCodeUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var mobileShaker: AFViewShaker?
    var verifyCodeShaker: AFViewShaker?
    
    var remainingSecond: Int = VCAppLetor.ConstValue.SMSRemainingSeconds {
        willSet(newSecond) {
            self.sendVerifyBtn.titleLabel?.text = "\(newSecond)"
        }
    }
    
    var timer: NSTimer?
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            }
            else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    // MARK: - LifeCycle
    
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
        
        if self.editType == VCAppLetor.EditType.Mobile {
            
            self.requireMobile.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
            self.requireMobile.autoAlignAxisToSuperviewAxis(.Vertical)
            
            self.mobile.autoPinEdgeToSuperviewEdge(.Leading, withInset: 30.0)
            self.mobile.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.requireMobile, withOffset: 24.0)
            self.mobile.autoSetDimension(.Width, toSize: self.view.width - 60 - 80 - 10)
            self.mobile.autoSetDimension(.Height, toSize: 30.0)
            
            self.sendVerifyBtn.autoSetDimensionsToSize(CGSizeMake(80.0, 32.0))
            self.sendVerifyBtn.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.mobile, withOffset: 10.0)
            self.sendVerifyBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.mobile, withOffset: 0.0)
            
            self.mobileUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.mobile, withOffset: -10.0)
            self.mobileUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.mobile, withOffset: 5.0)
            self.mobileUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.mobile)
            self.mobileUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.verifyCode.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.mobile)
            self.verifyCode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.mobileUnderline, withOffset: 10.0)
            self.verifyCode.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.sendVerifyBtn)
            self.verifyCode.autoSetDimension(.Height, toSize: 30.0)
            
            self.verifyCodeUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.verifyCode, withOffset: -10.0)
            self.verifyCodeUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.sendVerifyBtn, withOffset: 10.0)
            self.verifyCodeUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.verifyCode, withOffset: 5.0)
            self.verifyCodeUnderline.autoSetDimension(.Height, toSize: 3.0)
            
        }
        else if self.editType == VCAppLetor.EditType.Email {
            
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
            
            self.currentPassUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.currentPass, withOffset: 3.0)
            self.currentPassUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.currentPass, withOffset: 20.0)
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
    
    // MARK: - Functions
    
    func setupView() {
        
        if self.editType == VCAppLetor.EditType.Mobile {
            
            self.title = VCAppLetor.StringLine.BindMobile
            
            self.requireMobile.text = VCAppLetor.StringLine.RequireMobileString
            self.requireMobile.textAlignment = .Center
            self.requireMobile.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.requireMobile.font = VCAppLetor.Font.NormalFont
            self.requireMobile.sizeToFit()
            self.scrollView.addSubview(self.requireMobile)
            
            self.mobile.placeholder = VCAppLetor.StringLine.MobilePlease
            self.mobile.clearButtonMode = .WhileEditing
            self.mobile.keyboardType = UIKeyboardType.DecimalPad
            self.mobile.textAlignment = .Left
            self.mobile.font = VCAppLetor.Font.BigFont
            self.mobile.delegate = self
            self.scrollView.addSubview(self.mobile)
            
            self.mobileShaker = AFViewShaker(view: self.mobile)
            
            self.sendVerifyBtn.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
            self.sendVerifyBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
            self.sendVerifyBtn.titleLabel?.font = VCAppLetor.Font.SmallFont
            self.sendVerifyBtn.titleLabel?.textAlignment = .Center
            self.sendVerifyBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.sendVerifyBtn.layer.borderWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.sendVerifyBtn.addTarget(self, action: "checkMobile", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(self.sendVerifyBtn)
            
            self.mobileUnderline.drawType = "GrayLine"
            self.mobileUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.scrollView.addSubview(self.mobileUnderline)
            
            self.verifyCode.placeholder = VCAppLetor.StringLine.InputVerifyCode
            self.verifyCode.clearButtonMode = .WhileEditing
            self.verifyCode.keyboardType = UIKeyboardType.DecimalPad
            self.verifyCode.textAlignment = .Left
            self.verifyCode.font = VCAppLetor.Font.BigFont
            self.verifyCode.delegate = self
            self.scrollView.addSubview(self.verifyCode)
            
            self.verifyCodeUnderline.drawType = "GrayLine"
            self.verifyCodeUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
            self.scrollView.addSubview(self.verifyCodeUnderline)
            
            self.verifyCodeShaker = AFViewShaker(view: self.verifyCode)
            
            self.mobile.becomeFirstResponder()
            
        }
        else if self.editType == VCAppLetor.EditType.Email {
            
            self.title = VCAppLetor.StringLine.EditMemberEmail
            
            self.email.placeholder = self.memberInfo?.email
            self.email.clearButtonMode = .WhileEditing
            self.email.keyboardType = UIKeyboardType.EmailAddress
            self.email.returnKeyType = UIReturnKeyType.Done
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
            
            self.nickname.placeholder = self.memberInfo?.nickname
            self.nickname.clearButtonMode = .WhileEditing
            self.nickname.keyboardType = UIKeyboardType.EmailAddress
            self.nickname.returnKeyType = UIReturnKeyType.Done
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
            self.currentPass.returnKeyType = UIReturnKeyType.Next
            self.currentPass.textAlignment = .Left
            self.currentPass.font = VCAppLetor.Font.BigFont
            self.currentPass.secureTextEntry = true
            self.currentPass.delegate = self
            self.currentPass.tag = 1
            self.scrollView.addSubview(self.currentPass)
            
            self.currentPassShacker = AFViewShaker(view: self.currentPass)
            
            self.currentPassUnderline.drawType = "Line"
            self.currentPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.currentPassUnderline)
            
            self.newPass.placeholder = VCAppLetor.StringLine.NewPass
            self.newPass.keyboardType = UIKeyboardType.EmailAddress
            self.newPass.returnKeyType = UIReturnKeyType.Next
            self.newPass.textAlignment = .Left
            self.newPass.font = VCAppLetor.Font.BigFont
            self.newPass.secureTextEntry = true
            self.newPass.delegate = self
            self.newPass.tag = 2
            self.scrollView.addSubview(self.newPass)
            
            self.newPassUnderline.drawType = "Line"
            self.newPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.newPassUnderline)
            
            self.againPass.placeholder = VCAppLetor.StringLine.AgainPasscode
            self.againPass.keyboardType = UIKeyboardType.EmailAddress
            self.againPass.returnKeyType = UIReturnKeyType.Done
            self.againPass.textAlignment = .Left
            self.againPass.font = VCAppLetor.Font.BigFont
            self.againPass.secureTextEntry = true
            self.againPass.delegate = self
            self.scrollView.addSubview(self.againPass)
            
            self.againPassUnderline.drawType = "Line"
            self.againPassUnderline.lineWidth = 1.0
            self.scrollView.addSubview(self.againPassUnderline)
            
            self.newPassShacker = AFViewShaker(viewsArray: [self.newPass, self.againPass])
            
            self.currentPass.becomeFirstResponder()
        }
    }
    
    func checkMobile() {
        // Check mobile phone number
        let mobile: String = self.mobile.text as String
        self.disableSending()
        
        if (mobile == "") {
            
            self.enableSending()
            self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileCannotEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else if (!self.isMobile(mobile)) {
            self.enableSending()
            self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else {
            
            self.mobile.resignFirstResponder()
            
            self.sendOrderingAuthCode(mobile)
            
        }
        
    }
    
    func isMobile(mobile: String) -> Bool {
        
        let mobileRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
        let mobileTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobileTest.evaluateWithObject(mobile)
    }
    
    func enableSending() {
        
        self.sendVerifyBtn.enabled = true
        self.sendVerifyBtn.backgroundColor = UIColor.whiteColor()
        self.sendVerifyBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
    }
    
    func disableSending() {
        
        // disable sending button while processing
        self.sendVerifyBtn.enabled = false
        self.sendVerifyBtn.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        self.sendVerifyBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func sendOrderingAuthCode(mobile: String) {
        
        let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = VCAppLetor.StringLine.VerifyCodeInProgress
        
        let validateCode: String = (mobile + VCAppLetor.StringLine.SaltKey).md5
        println("code: \(validateCode)")
        
        Alamofire.request(VCheckGo.Router.GetVerifyCode(mobile, validateCode)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string == "1" {
                    
                    self.startCounting()
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: mobile, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.VerifyCode, data: json["data"]["verify_code"].string, namespace: "member")
                    CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.SaltCode, data: json["data"]["code"].string, namespace: "member")
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendDone, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    
                }
                else {
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                hud.hide(true)
            }
            else {
                println("ERROR @ Request for sending varify code : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendFail, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        })
        
    }
    
    func startCounting() {
        self.remainingSecond = VCAppLetor.ConstValue.SMSRemainingSeconds
        self.isCounting = !self.isCounting
    }
    
    func updateTimer(timer: NSTimer) {
        
        self.remainingSecond -= 1
        
        if self.remainingSecond <= 0 {
            self.isCounting = !self.isCounting
            
            self.sendVerifyBtn.enabled = true
            self.sendVerifyBtn.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
            self.sendVerifyBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
            self.sendVerifyBtn.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func editDone() {
        
        if self.editType == VCAppLetor.EditType.Mobile {
            
            if self.mobile.text == "" {
                RKDropdownAlert.title(VCAppLetor.StringLine.MobilePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            else if self.verifyCode.text == "" {
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            else if CTMemCache.sharedInstance.exists(VCAppLetor.UserInfo.VerifyCode, namespace: "member") {
                
                let verifyCodeStr = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.VerifyCode, namespace: "member")?.data as! String
                
                if self.verifyCode.text != verifyCodeStr {
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeWrong, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                else {
                    
                    let mobileStr = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
                    
                    if self.mobile.text != mobileStr {
                        
                        RKDropdownAlert.title(VCAppLetor.StringLine.MobilePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                    else {
                        
                        let mobileStr = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
                        //let verifyCodeStr = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.VerifyCode, namespace: "member")?.data as! String
                        let code = ((CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.SaltCode, namespace: "member")?.data as! String) + VCAppLetor.StringLine.SaltKey).md5
                        
                        let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        hud.mode = MBProgressHUDMode.Indeterminate
                        
                        let wxUserInfo = CTMemCache.sharedInstance.get(VCAppLetor.LoginStatus.WechatLogInfo, namespace: "LoginStatus")?.data as! NSDictionary
                        
                        println("mobile: \(mobileStr)")
                        println("code: \(code)")
                        println("user: \(wxUserInfo)")
                        
                        Alamofire.request(VCheckGo.Router.RegWithWechat(wxUserInfo, mobileStr, code)).validate().responseSwiftyJSON({
                            (_, _, JSON, error) -> Void in
                            
                            if error == nil {
                                
                                let json = JSON
                                
                                if json["status"]["succeed"].string! == "1" {
                                    
                                    let memberId = json["data"]["member_id"].string!
                                    let token = json["data"]["token"].string!
                                    
                                    println("mid:\(memberId)\ntoken:\(token)")
                                    
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatLog, data: true, namespace: "LoginStatus")
                                    
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatAvatar, data: wxUserInfo.valueForKey("headimgurl"), namespace: "LoginStatus")
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatNickname, data: wxUserInfo.valueForKey("nickname"), namespace: "LoginStatus")
                                    
                                    hud.hide(true)
                                    self.mobileDelegate?.didMemberFinishAuthMobile(memberId, token: token)
                                    self.parentNav?.popViewControllerAnimated(true)
                                    
                                }
                                else {
                                    hud.hide(true)
                                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                                }
                                
                            }
                            else {
                                hud.hide(true)
                                println("ERROR @ Reg with wechat : \(error?.localizedDescription)")
                            }
                        })
                    }
                }
            }
            else {
                
                RKDropdownAlert.title(VCAppLetor.StringLine.ResendVerifyCodePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
        }
        else if self.editType == VCAppLetor.EditType.Email {
            
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
            
            self.currentPass.resignFirstResponder()
            self.newPass.resignFirstResponder()
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
        
        if textField.tag == 1 {
            self.newPass.becomeFirstResponder()
        }
        else if textField.tag == 2 {
            self.againPass.becomeFirstResponder()
        }
        else {
            self.editDone()
        }
        return true
    }
    
    func isEmail(email: String) -> Bool {
        
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
    
}



