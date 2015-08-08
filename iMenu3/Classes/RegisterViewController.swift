//
//  RegisterViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/12.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD
import AFViewShaker
import IHKeyboardAvoiding

class RegisterViewController: VCBaseViewController, UIScrollViewDelegate, UITextFieldDelegate, RKDropdownAlertDelegate {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let phoneNumber: UITextField = UITextField.newAutoLayoutView()
    let authCode: UITextField = UITextField.newAutoLayoutView()
    let inventCode: UITextField = UITextField.newAutoLayoutView()
    
    let senDAuthCodeButton: UIButton = UIButton.newAutoLayoutView()
    
    var phoneNumberShaker: AFViewShaker?
    var authCodeShaker: AFViewShaker?
    
    let regStepView: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let phoneUnderLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let codeUnderLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let invUnderLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let noInventYet: UILabel = UILabel.newAutoLayoutView()
    let terms: UILabel = UILabel.newAutoLayoutView()
    let termsUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let termsButton: UIButton = UIButton.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    var parentController: VCMemberLoginViewController?
    
    var tapGesture: UITapGestureRecognizer!
    
    var remainingSecond: Int = VCAppLetor.ConstValue.SMSRemainingSeconds {
        willSet(newSecond) {
            self.senDAuthCodeButton.titleLabel?.text = "\(newSecond)"
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
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "phoneRegAction")
        
        self.title = VCAppLetor.StringLine.RegPageTitle
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.height = self.view.height - 62.0
        self.scrollView.originY = 62.0
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap:")
        self.tapGesture.numberOfTouchesRequired = 1
        self.tapGesture.numberOfTapsRequired = 1
        
        // Register step icon
        regStepView.drawType = "RegStep1"
        self.scrollView.addSubview(regStepView)
        
        // input your phone number
        self.phoneNumber.placeholder = VCAppLetor.StringLine.PhoneNumber
        self.phoneNumber.clearButtonMode = .WhileEditing
        self.phoneNumber.keyboardType = UIKeyboardType.NumbersAndPunctuation
        self.phoneNumber.returnKeyType = UIReturnKeyType.Done
        self.phoneNumber.textAlignment = .Left
        self.phoneNumber.font = VCAppLetor.Font.BigFont
        self.phoneNumber.tag = 1
        self.phoneNumber.delegate = self
        self.scrollView.addSubview(self.phoneNumber)
        
        // Input your authcode which send to your smartphone by SMS
        self.authCode.placeholder = VCAppLetor.StringLine.SMSCode
        self.authCode.clearButtonMode = .WhileEditing
        self.authCode.keyboardType = UIKeyboardType.NumbersAndPunctuation
        self.authCode.returnKeyType = UIReturnKeyType.Done
        self.authCode.textAlignment = .Left
        self.authCode.font = VCAppLetor.Font.BigFont
        self.authCode.tag = 2
        self.authCode.delegate = self
        self.scrollView.addSubview(self.authCode)
        
        self.phoneNumberShaker = AFViewShaker(view: self.phoneNumber)
        self.authCodeShaker = AFViewShaker(view: self.authCode)
        
        // Send auth code button
        self.senDAuthCodeButton.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
        self.senDAuthCodeButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
        self.senDAuthCodeButton.titleLabel?.font = VCAppLetor.Font.SmallFont
        self.senDAuthCodeButton.titleLabel?.textAlignment = .Center
        self.senDAuthCodeButton.backgroundColor = UIColor.whiteColor()
        self.senDAuthCodeButton.layer.borderWidth = VCAppLetor.ConstValue.ButtonBorderWidth
        self.senDAuthCodeButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        self.senDAuthCodeButton.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        self.senDAuthCodeButton.addTarget(self, action: "checkMobile", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.senDAuthCodeButton)
        
        phoneUnderLine.drawType = "Line"
        phoneUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(phoneUnderLine)
        
        codeUnderLine.drawType = "Line"
        codeUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(codeUnderLine)
        
        // Input your invent code to get a coupon code for you and your friend who send this code to you
        self.inventCode.placeholder = VCAppLetor.StringLine.InventCodeOption
        self.inventCode.clearButtonMode = .WhileEditing
        self.inventCode.textAlignment = .Left
        self.inventCode.font = VCAppLetor.Font.BigFont
        self.inventCode.delegate = self
        self.scrollView.addSubview(self.inventCode)
        
        invUnderLine.drawType = "Line"
        invUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(invUnderLine)
        
        // No invent code yet, no problem, you can set later
        self.noInventYet.text = VCAppLetor.StringLine.NoInventCodeYet
        self.noInventYet.textAlignment = .Left
        self.noInventYet.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.noInventYet.font = VCAppLetor.Font.SmallFont
        self.scrollView.addSubview(noInventYet)
        
        // End user Terms and conditions
        self.terms.text = VCAppLetor.StringLine.AgreeTermsString
        self.terms.textAlignment = .Center
        self.terms.font = VCAppLetor.Font.SmallFont
        self.terms.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.terms.backgroundColor = UIColor.cloudsColor(alpha: 0.2)
        self.scrollView.addSubview(terms)
        
        self.termsUnderline.drawType = "Line"
        self.termsUnderline.lineWidth = 1.0
        self.scrollView.addSubview(termsUnderline)
        
        self.termsButton.setTitle(" ", forState: .Normal)
        self.termsButton.addTarget(self, action: "showTerms", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(termsButton)
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        IHKeyboardAvoiding.setAvoidingView(self.view, withTriggerView: self.inventCode)
        IHKeyboardAvoiding.setPaddingForCurrentAvoidingView(60)
        IHKeyboardAvoiding.setBuffer(60)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func updateViewConstraints() {
        
        self.regStepView.autoSetDimensionsToSize(CGSizeMake(220.0, 44.0))
        self.regStepView.autoAlignAxisToSuperviewAxis(.Vertical)
        self.regStepView.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        
        self.phoneNumber.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.regStepView, withOffset: VCAppLetor.ConstValue.LineGap*2.0)
        self.phoneNumber.autoPinEdgeToSuperviewEdge(.Leading, withInset: 40.0)
        self.phoneNumber.autoSetDimension(.Width, toSize: self.view.width - 180.0)
        self.phoneNumber.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        
        self.phoneUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.phoneNumber, withOffset: 3.0)
        self.phoneUnderLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumber, withOffset: -10.0)
        self.phoneUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.phoneNumber, withOffset: 10.0)
        self.phoneUnderLine.autoSetDimension(.Height, toSize: 3.0)
        
        self.senDAuthCodeButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.phoneNumber, withOffset: 20.0)
        self.senDAuthCodeButton.autoSetDimensionsToSize(CGSizeMake(90.0, VCAppLetor.ConstValue.ButtonHeight))
        self.senDAuthCodeButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: regStepView, withOffset: VCAppLetor.ConstValue.LineGap*2.0)
        
        self.authCode.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumber)
        self.authCode.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.senDAuthCodeButton)
        self.authCode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.phoneUnderLine, withOffset: VCAppLetor.ConstValue.LineGap)
        self.authCode.autoMatchDimension(.Height, toDimension: .Height, ofView: self.phoneNumber)
        
        self.codeUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.authCode, withOffset: 3.0)
        self.codeUnderLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.authCode, withOffset: -10.0)
        self.codeUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.authCode, withOffset: 10.0)
        self.codeUnderLine.autoSetDimension(.Height, toSize: 3.0)
        
        self.inventCode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.codeUnderLine, withOffset: VCAppLetor.ConstValue.LineGap)
        self.inventCode.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.authCode)
        self.inventCode.autoMatchDimension(.Width, toDimension: .Width, ofView: self.authCode)
        self.inventCode.autoMatchDimension(.Height, toDimension: .Height, ofView: self.authCode)
        
        self.invUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.inventCode, withOffset: 3.0)
        self.invUnderLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.inventCode, withOffset: -10.0)
        self.invUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.inventCode, withOffset: 10.0)
        self.invUnderLine.autoSetDimension(.Height, toSize: 3.0)
        
        self.noInventYet.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.invUnderLine, withOffset: 10.0)
        self.noInventYet.autoSetDimension(.Height, toSize: 20.0)
        self.noInventYet.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumber)
        
        self.terms.autoPinEdgeToSuperviewEdge(.Top, withInset: self.scrollView.height - 40.0)
        self.terms.autoSetDimensionsToSize(CGSizeMake(300.0, 30.0))
        self.terms.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.termsUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.terms, withOffset: -9.0)
        self.termsUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: terms, withOffset: -18.0)
        self.termsUnderline.autoSetDimensionsToSize(CGSizeMake(48.0, 3.0))
        
        self.termsButton.autoSetDimensionsToSize(CGSizeMake(48.0, VCAppLetor.ConstValue.ButtonHeight))
        self.termsButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: terms)
        self.termsButton.autoAlignAxis(.Horizontal, toSameAxisOfView: terms)
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: - Functions
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func checkMobile() {
        // Check mobile phone number
        let mobile: String = self.phoneNumber.text as String
        self.disableSending()
        
        if (mobile == "") {
            
            self.phoneNumberShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileCannotEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            })
        }
        else if (!self.isMobile(mobile)) {
            self.phoneNumberShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            })
        }
        else {
            
            self.phoneNumber.resignFirstResponder()
            
            let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.AnnularDeterminate
            hud.labelText = VCAppLetor.StringLine.VerifyCodeInProgress
            
            Alamofire.request(VCheckGo.Router.ValidateMemberInfo(VCheckGo.ValidateType.Mobile, mobile)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                let json = JSON
                
                if (error == nil) {
                    
                    if json["status"]["succeed"].string == "0" {
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                    }
                    else {
                        self.sendRegAuthCode(mobile)
                    }
                }
                else {
                    println("ERROR @ Validate member info request : \(error?.localizedDescription)")
                }
                
                self.phoneNumber.resignFirstResponder()
                hud.hide(true)
                
            })
        }
        
    }
    
    func disableSending() {
        
        // disable sending button while processing
        self.senDAuthCodeButton.enabled = false
        self.senDAuthCodeButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        self.senDAuthCodeButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func enableSending() {
        self.senDAuthCodeButton.enabled = true
        self.senDAuthCodeButton.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
        self.senDAuthCodeButton.backgroundColor = UIColor.whiteColor()
    }
    
    func startCounting() {
        self.remainingSecond = VCAppLetor.ConstValue.SMSRemainingSeconds
        self.isCounting = !self.isCounting
    }
    
    func sendRegAuthCode(mobile: String) {
        
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
                    RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                }
                
                hud.hide(true)
            }
            else {
                println("ERROR @ Request for sending varify code : \(error?.localizedDescription)")
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendFail, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            }
        })
        
    }
    
    func updateTimer(timer: NSTimer) {
        
        self.remainingSecond -= 1
        
        if self.remainingSecond <= 0 {
            self.isCounting = !self.isCounting
            
            self.senDAuthCodeButton.enabled = true
            self.senDAuthCodeButton.setTitle(VCAppLetor.StringLine.SendAutoCode, forState: .Normal)
            self.senDAuthCodeButton.backgroundColor = UIColor.whiteColor()
        }
    }
    
    
    func phoneRegAction() {
        
        let verifyCode = self.authCode.text
        let sendingCode = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.VerifyCode, namespace: "member")?.data as? String ?? ""
        
        if verifyCode != "" {
            
            // Matching verify code
            if verifyCode == sendingCode {
                
                // Set member password
                let setPassForRegViewController: RegSetPassViewController = RegSetPassViewController()
                setPassForRegViewController.delegate = parentController?.userPanelController
                setPassForRegViewController.parentNav = self.parentNav
                self.parentNav?.showViewController(setPassForRegViewController, sender: self)
            }
            else {
                self.authCodeShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeWrong, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
            
        }
        else {
            self.authCodeShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
    }
    
    func isMobile(mobile: String) -> Bool {
        
        let mobileRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
        let mobileTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobileTest.evaluateWithObject(mobile)
    }
    
    func showTerms() {
        
        let userTermsViewController: VCTermsViewController = VCTermsViewController()
        userTermsViewController.parentNav = self.parentNav
        self.parentNav?.showViewController(userTermsViewController, sender: self)
    }
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        
        self.enableSending()
        return true
    }
    
    // MARK: - Keyboard Notifications
    func keyboardWillShowNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.view.addGestureRecognizer(self.tapGesture)
        
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        
        
        self.view.removeGestureRecognizer(self.tapGesture)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField.tag == 1 {
            self.checkMobile()
        }
        else if textField.tag == 2 {
            self.phoneRegAction()
        }
        
        return true
    }
    
    // MARK: - UIGesture
    
    func viewDidTap(gesture: UITapGestureRecognizer) {
        self.phoneNumber.resignFirstResponder()
        self.authCode.resignFirstResponder()
        self.inventCode.resignFirstResponder()
    }
    
    
}






