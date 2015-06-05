//
//  SMSCodeViewController.swift
//
//
//  Created by Gabriel Anthony on 15/5/8.
//
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert
import AFViewShaker
import MBProgressHUD

class SMSCodeViewController: VCBaseViewController, RKDropdownAlertDelegate {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let phoneNumber: UILabel = UILabel.newAutoLayoutView()
    let verifyCode: UITextField = UITextField.newAutoLayoutView()
    let resentButton: UIButton = UIButton.newAutoLayoutView()
    let phoneNumberUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let verifyCodeUnderLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    var codeShaker: AFViewShaker?
    
    var remainingSeconds: Int = VCAppLetor.ConstValue.SMSRemainingSeconds {
        willSet(newSeconds) {
            self.resentButton.titleLabel?.text = "\(newSeconds)"
        }
    }
    
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
    var timer: NSTimer?
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.title = VCAppLetor.StringLine.SMSCode
        self.view.backgroundColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "resetMyPasscode")
        
        self.phoneNumber.font = VCAppLetor.Font.NormalFont
        self.phoneNumber.textAlignment = .Left
        self.scrollView.addSubview(self.phoneNumber)
        
        self.resentButton.setTitle(VCAppLetor.StringLine.Resent, forState: .Disabled)
        self.resentButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
        self.resentButton.titleLabel?.font = VCAppLetor.Font.SmallFont
        self.resentButton.titleLabel?.textAlignment = .Center
        self.resentButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        self.resentButton.layer.borderWidth = VCAppLetor.ConstValue.ButtonBorderWidth
        self.resentButton.layer.borderColor = UIColor.grayColor().CGColor
        self.resentButton.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        self.resentButton.addTarget(self, action: "sentVerifyCode", forControlEvents: .TouchUpInside)
        self.resentButton.enabled = false
        self.scrollView.addSubview(self.resentButton)
        
        self.phoneNumberUnderline.drawType = "Line"
        self.phoneNumberUnderline.lineWidth = 1.0
        self.scrollView.addSubview(phoneNumberUnderline)
        
        self.verifyCode.placeholder = VCAppLetor.StringLine.InputSMSCode
        self.verifyCode.clearsOnBeginEditing = true
        self.verifyCode.keyboardType = UIKeyboardType.NumberPad
        self.scrollView.addSubview(self.verifyCode)
        
        self.verifyCodeUnderLine.drawType = "Line"
        self.verifyCodeUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(self.verifyCodeUnderLine)
        
        self.codeShaker = AFViewShaker(view: self.verifyCode)
        
        self.view.addSubview(self.scrollView)
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sentVerifyCode()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.phoneNumber.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        self.phoneNumber.autoPinEdgeToSuperviewEdge(.Leading, withInset: 30.0)
        self.phoneNumber.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        self.phoneNumber.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.5)
        
        self.resentButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.phoneNumber, withOffset: 20.0)
        self.resentButton.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.ButtonHeight)
        self.resentButton.autoSetDimension(.Width, toSize: 80.0)
        self.resentButton.autoPinEdge(.Top, toEdge: .Top, ofView: self.phoneNumber)
        
        self.phoneNumberUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumber, withOffset: -10.0)
        self.phoneNumberUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.phoneNumber, withOffset: 3.0)
        self.phoneNumberUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.phoneNumber, withOffset: 20.0)
        self.phoneNumberUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.verifyCode.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.phoneNumberUnderline, withOffset: VCAppLetor.ConstValue.LineGap)
        self.verifyCode.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumber)
        self.verifyCode.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.resentButton)
        self.verifyCode.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        
        self.verifyCodeUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.verifyCode, withOffset: 3.0)
        self.verifyCodeUnderLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.phoneNumberUnderline)
        self.verifyCodeUnderLine.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.resentButton)
        self.verifyCodeUnderLine.autoSetDimension(.Height, toSize: 3.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: - Functions
    func resetMyPasscode() {
        
        let verifyCode = self.verifyCode.text
        self.verifyCode.resignFirstResponder()
        
        if verifyCode != "" {
            
            // Matching verify code
            if verifyCode == CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.VerifyCode, namespace: "member")?.data as! String {
                
                // Set member password
                let resetPassViewController: ResetMyPasscodeViewController = ResetMyPasscodeViewController()
                resetPassViewController.parentNav = self.parentNav
                self.parentNav?.showViewController(resetPassViewController, sender: self)
            }
            else {
                self.codeShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeWrong, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
        }
        else {
            self.codeShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodePlease, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        
        
        
    }
    
    func startCounting() {
        self.remainingSeconds = VCAppLetor.ConstValue.SMSRemainingSeconds
        self.isCounting = !self.isCounting
    }
    
    func updateTimer(timer: NSTimer) {
        
        self.remainingSeconds -= 1
        
        if self.remainingSeconds <= 0 {
            self.isCounting = !self.isCounting
            
            self.resentButton.enabled = true
            self.resentButton.setTitle(VCAppLetor.StringLine.Resent, forState: .Normal)
            self.resentButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
            self.resentButton.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func sentVerifyCode() {
        
        self.disableSending()
        if self.verifyCode.isFirstResponder() {
            self.verifyCode.resignFirstResponder()
        }
        
        if self.reachability.isReachable() {
            
            let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.AnnularDeterminate
            hud.labelText = VCAppLetor.StringLine.VerifyCodeInProgress
            
            let validateCode: String = (self.phoneNumber.text! + VCAppLetor.StringLine.SaltKey).md5
            println("code: \(validateCode)")
            
            Alamofire.request(VCheckGo.Router.GetVerifyCode(self.phoneNumber.text!, validateCode)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string == "1" {
                        
                        self.startCounting()
                        
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.Mobile, data: self.phoneNumber.text!, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.VerifyCode, data: json["data"]["verify_code"].string, namespace: "member")
                        CTMemCache.sharedInstance.set(VCAppLetor.UserInfo.SaltCode, data: json["data"]["code"].string, namespace: "member")
                        
                        RKDropdownAlert.title(VCAppLetor.StringLine.VerifyCodeSendDone, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                    }
                }
                else {
                    println("ERROR @ Request for sending varify code : \(error?.localizedDescription)")
                    RKDropdownAlert.title(error?.localizedDescription, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                }
            })
            
            hud.hide(true)
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
        }
    }
    
    func disableSending() {
        
        // disable sending button while processing
        self.resentButton.enabled = false
        self.resentButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        self.resentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func enableSending() {
        self.resentButton.enabled = true
        self.resentButton.setTitle(VCAppLetor.StringLine.Resent, forState: .Normal)
        self.resentButton.backgroundColor = UIColor.whiteColor()
    }
    
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        
        self.enableSending()
        return true
    }
    
    
    
}




