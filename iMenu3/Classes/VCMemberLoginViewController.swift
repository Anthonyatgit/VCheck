//
//  VCMemberLoginViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/5.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert
import MBProgressHUD
import AFViewShaker

protocol MemberSigninDelegate {
    
    func memberDidSigninSuccess(mid: String, token: String)
    func memberDidSigninWithWechatSuccess(mid: String, token: String)
}

class VCMemberLoginViewController: VCBaseViewController, UIScrollViewDelegate, UITextFieldDelegate, RKDropdownAlertDelegate {
    
    let scrollView: UIScrollView = UIScrollView.newAutoLayoutView()
    
    let loginTitle: UILabel = UILabel.newAutoLayoutView()
    let loginName: UITextField = UITextField.newAutoLayoutView()
    let loginPass: UITextField = UITextField.newAutoLayoutView()
    
    var loginNameShaker: AFViewShaker?
    var loginPassShaker: AFViewShaker?
    
    let weiboSignInButton: UIButton = UIButton.newAutoLayoutView()
    let wechatSignInButton: UIButton = UIButton.newAutoLayoutView()
    
    let forgetPassButton = UIButton.newAutoLayoutView()
    let nameUnderLine = CustomDrawView.newAutoLayoutView()
    let passUnderLine = CustomDrawView.newAutoLayoutView()
    let signUpText: UILabel = UILabel.newAutoLayoutView()
    let signUpButton: UIButton = UIButton.newAutoLayoutView()
    
    var delegate: MemberSigninDelegate? = nil
    var userPanelController: UserPanelViewController?
    
    
    let socialLine = CustomDrawView.newAutoLayoutView()
    let socialSignInTitle: UILabel = UILabel.newAutoLayoutView()
    
    let closeButton: UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
    
    var tapGesture: UITapGestureRecognizer!
    
    var hud: MBProgressHUD?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.scrollView.originX = 0.0
        //        self.scrollView.originY = 62.0
        //        self.scrollView.width = self.view.width
        //        self.scrollView.height = self.view.height-62.0
        
        self.title = VCAppLetor.StringLine.LoginPageTitle
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        let closeView: UIView = UIView(frame: CGRectMake(6.0, 0.0, 32.0, 32.0))
        closeView.backgroundColor = UIColor.clearColor()
        
        self.closeButton.setImage(UIImage(named: VCAppLetor.IconName.ClearIconBlack)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.closeButton.backgroundColor = UIColor.clearColor()
        self.closeButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        closeView.addSubview(self.closeButton)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeView)
        //        self.navigationController?.navigationBar.alpha = 0.2
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Done, style: .Done, target: self, action: "letMeLogin")
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        
        // Top Description Text
        self.loginTitle.text = VCAppLetor.StringLine.LoginTitle
        self.loginTitle.font = VCAppLetor.Font.NormalFont
        self.loginTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.loginTitle.textAlignment = .Center
        self.scrollView.addSubview(self.loginTitle)
        
        // Login Name
        self.loginName.placeholder = VCAppLetor.StringLine.LoginName
        self.loginName.clearButtonMode = .WhileEditing
        self.loginName.keyboardType = UIKeyboardType.EmailAddress
        self.loginName.returnKeyType = UIReturnKeyType.Next
        self.loginName.clearsOnBeginEditing = true
        self.loginName.tag = 1
        self.loginName.delegate = self
        self.scrollView.addSubview(self.loginName)
        
        // Login Name Underline
        nameUnderLine.drawType = "Line"
        nameUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(nameUnderLine)
        
        // Login Pass
        self.loginPass.placeholder = VCAppLetor.StringLine.LoginPass
        self.loginPass.secureTextEntry = true
        self.loginPass.keyboardType = UIKeyboardType.EmailAddress
        self.loginPass.returnKeyType = UIReturnKeyType.Done
        self.loginPass.clearsOnBeginEditing = true
        self.loginPass.delegate = self
        self.scrollView.addSubview(self.loginPass)
        
        // Forget Passcode Button
        self.forgetPassButton.setImage(UIImage(named: VCAppLetor.IconName.HelpIconBlack), forState: .Normal)
        self.forgetPassButton.alpha = 0.1
        self.forgetPassButton.addTarget(self, action: "forgotMyPasscode", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.forgetPassButton)
        
        // Login Passcode Underline
        self.passUnderLine.drawType = "Line"
        self.passUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(passUnderLine)
        
        // SignUp Description Text
        self.signUpText.text = VCAppLetor.StringLine.SignUpText
        self.signUpText.font = VCAppLetor.Font.NormalFont
        self.signUpText.textAlignment = .Left
        self.signUpText.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.scrollView.addSubview(self.signUpText)
        
        // SignUp Button
        signUpButton.setTitle(VCAppLetor.StringLine.SignUpButtonText, forState: .Normal)
        signUpButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        signUpButton.titleLabel?.font = VCAppLetor.Font.NormalFont
        signUpButton.addTarget(self, action: "letMeRegister", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(signUpButton)
        
        self.socialLine.drawType = "DoubleLine"
        self.scrollView.addSubview(self.socialLine)
        
        self.socialSignInTitle.text = VCAppLetor.StringLine.SocialSignUpTitle
        self.socialSignInTitle.textAlignment = .Center
        self.socialSignInTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.socialSignInTitle.backgroundColor = UIColor.whiteColor()
        self.socialSignInTitle.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.socialSignInTitle)
        
        
        self.weiboSignInButton.setImage(UIImage(named: "weibo.png"), forState: .Normal)
        self.weiboSignInButton.backgroundColor = UIColor.whiteColor()
        self.weiboSignInButton.imageEdgeInsets = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
        self.weiboSignInButton.addTarget(self, action: "signinWithWeibo", forControlEvents: .TouchUpInside)
        self.weiboSignInButton.layer.cornerRadius = 26.0
        self.weiboSignInButton.layer.borderWidth = 1.0
        self.weiboSignInButton.layer.borderColor = UIColor.blackColor().CGColor
        self.weiboSignInButton.alpha = 0.4
        self.scrollView.addSubview(self.weiboSignInButton)
        
        self.wechatSignInButton.setImage(UIImage(named: "wechat.png"), forState: .Normal)
        self.wechatSignInButton.backgroundColor = UIColor.whiteColor()
        self.wechatSignInButton.imageEdgeInsets = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
        self.wechatSignInButton.addTarget(self, action: "signinWithWechat", forControlEvents: .TouchUpInside)
        self.wechatSignInButton.layer.cornerRadius = 26.0
        self.wechatSignInButton.layer.borderWidth = 1.0
        self.wechatSignInButton.layer.borderColor = UIColor.blackColor().CGColor
        self.wechatSignInButton.alpha = 0.8
        self.scrollView.addSubview(self.wechatSignInButton)
        
        // Shake Animation
        self.loginNameShaker = AFViewShaker(view: self.loginName)
        self.loginPassShaker = AFViewShaker(view: self.loginPass)
        
        self.view.addSubview(self.scrollView)
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidFinishInput:", name: UITextFieldTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.scrollView.autoSetDimensionsToSize(CGSizeMake(self.view.width, self.view.height - 62.0))
        self.scrollView.autoPinEdgeToSuperviewEdge(.Top, withInset: 62.0)
        self.scrollView.autoPinEdgeToSuperviewEdge(.Leading)
        
        self.loginTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        self.loginTitle.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.loginTitle.autoSetDimension(.Height, toSize: 20.0)
        self.loginTitle.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.loginName.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.loginName.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        self.loginName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginTitle, withOffset: VCAppLetor.ConstValue.LineGap*2.0)
        self.loginName.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.nameUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginName, withOffset: 3.0)
        self.nameUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: 20.0)
        self.nameUnderLine.autoSetDimension(.Height, toSize: 3.0)
        self.nameUnderLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.loginPass.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.loginName)
        self.loginPass.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.nameUnderLine, withOffset: VCAppLetor.ConstValue.LineGap)
        self.loginPass.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: -24.0)
        self.loginPass.autoMatchDimension(.Height, toDimension: .Height, ofView: self.loginName)
        
        self.forgetPassButton.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
        self.forgetPassButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.loginName)
        self.forgetPassButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.loginPass)
        
        self.passUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginPass, withOffset: 3.0)
        self.passUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: 20.0)
        self.passUnderLine.autoSetDimension(.Height, toSize: 3.0)
        self.passUnderLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.signUpText.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.loginName, withOffset: self.view.width/2.0)
        self.signUpText.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        self.signUpText.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginPass, withOffset: VCAppLetor.ConstValue.LineGap)
        
        self.signUpButton.autoSetDimensionsToSize(CGSizeMake(75.0, 20.0))
        self.signUpButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.signUpText, withOffset: 0.0)
        self.signUpButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.signUpText)
        
        self.socialLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.signUpText, withOffset: self.view.height-400.0)
        self.socialLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.socialLine.autoSetDimension(.Height, toSize: 5.0)
        self.socialLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.socialSignInTitle.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        self.socialSignInTitle.autoAlignAxisToSuperviewAxis(.Vertical)
        self.socialSignInTitle.autoAlignAxis(.Horizontal, toSameAxisOfView: self.socialLine)
        
        self.weiboSignInButton.autoSetDimensionsToSize(CGSizeMake(52.0, 52.0))
        self.weiboSignInButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.socialSignInTitle, withOffset: 30.0)
        self.weiboSignInButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.loginName, withOffset: 40.0)
        
        self.wechatSignInButton.autoSetDimensionsToSize(CGSizeMake(52.0, 52.0))
        self.wechatSignInButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.weiboSignInButton)
        self.wechatSignInButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.loginName, withOffset: -40.0)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.scrollView.contentOffset = CGPointMake(0, 0)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Do some cleanup when dealloc
        
    }
    
    // MARK: - RKDropDownAlertDelegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    // MARK: - User Sign-in & Sign-up Logistic
    
    func userDidFinishInput(notification: NSNotification) {
        
        
    }
    
    // MARK: - UITextFiledDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            self.loginPass.becomeFirstResponder()
        }
        else {
            self.letMeLogin()
        }
        return true
    }
    
    // MARK: - Keyboard Notifications
    func keyboardWillShowNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationOptions = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            options: animationOptions,
            animations: {
                
            },
            completion: { complated in
                self.view.addGestureRecognizer(self.tapGesture)
        })
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        
        
        self.view.removeGestureRecognizer(self.tapGesture)
    }
    
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.loginName.resignFirstResponder()
        self.loginPass.resignFirstResponder()
    }
    
    // MARK: - Functions
    
    func letMeLogin() {
        
        self.loginName.resignFirstResponder()
        self.loginPass.resignFirstResponder()
        
        // Clear local cache data with member
        CTMemCache.sharedInstance.cleanNamespace("member")
        
        let loginNameText = self.loginName.text
        let loginPassText = self.loginPass.text
        
        if loginNameText == "" {
            self.loginNameShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.LoginNameEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else if loginPassText == "" {
            self.loginPassShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.LoginPassEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else if !self.isEmail(loginNameText) && !self.isMobile(loginNameText) {
            self.loginNameShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.LoginNameIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            })
        }
        else {
            
            let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Determinate
            
            var loginType: VCheckGo.LoginType = VCheckGo.LoginType.Mobile
            if self.isEmail(loginNameText) {
                loginType = VCheckGo.LoginType.Email
            }
            
            let code: String = (loginNameText + VCAppLetor.StringLine.SaltKey).md5
            
            if self.reachability.isReachable() {
                
                Alamofire.request(VCheckGo.Router.MemberLogin(loginNameText, loginPassText, loginType, code)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        
                        if json["status"]["succeed"].string == "1" {
                            
                            self.delegate?.memberDidSigninSuccess(json["data"]["member_id"].string!, token: json["data"]["token"].string!)
                            self.dismiss()
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        println("ERROR @ Request for member login : \(error?.localizedDescription)")
                    }
                })
            }
            else {
                RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
            
            
            hud.hide(true)
        }
        
        
    }
    
    
    func letMeRegister() {
        
        // Present member register page
        
        if !CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token") {
            
            let regViewController: RegisterViewController = RegisterViewController()
            let parentNav = self.parentViewController as! UINavigationController
            regViewController.parentController = self
            regViewController.parentNav = parentNav
            regViewController.view.bounds = self.view.bounds
            parentNav.showViewController(regViewController, sender: self)
        }
        
    }
    
    func forgotMyPasscode() {
        
        let findMyPassViewController: FindMyPasscodeViewController = FindMyPasscodeViewController()
        let parentNav = self.parentViewController as! UINavigationController
        
        findMyPassViewController.parentNav = parentNav
        //        navParent.pushViewController(findMyPassViewController, animated: true)
        parentNav.showViewController(findMyPassViewController, sender: self)
        
    }
    
    func signinWithWeibo() {
        
        /**
        ShareSDK.getUserInfoWithType(ShareTypeSinaWeibo, authOptions: nil) {
            (result, userInfo, error) -> Void in
            
            if result {
                
                println("result: \(result) | userInfo: \(userInfo.sourceData() as NSDictionary)")
                
                // Fitch member info from server when login return success, cache member info in the local and refresh userinterface
                //============================================================
                
                var mid: String = userInfo.uid()
                
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    member.mid = userInfo.uid()
                    member.nickname = userInfo.nickname()
                    member.iconURL = userInfo.profileImage()
                    
                    //                    let optIsLogin = Settings.createInContextOfType(contextType) as! Settings
                    //                    optIsLogin.sid = "\(NSDate())"
                    //                    optIsLogin.name = VCAppLetor.SettingName.optNameIsLogin
                    //                    optIsLogin.value = "true"
                    //
                    //                    let optLoginType = Settings.createInContextOfType(contextType) as! Settings
                    //                    optLoginType.sid = "\(NSDate())"
                    //                    optLoginType.name = VCAppLetor.SettingName.optNameLoginType
                    //                    optLoginType.value = VCAppLetor.LoginType.SinaWeibo
                    
                    }, completion: { error -> Void in
                        
                        if (error != nil) {
                            println("\(error?.localizedDescription)")
                        }
                        else {
                            // Prepare for member login refresh
                            
                            CTMemCache.sharedInstance.set("isLogin", data: true, namespace: "member")
                            CTMemCache.sharedInstance.set("loginType", data: VCAppLetor.LoginType.SinaWeibo, namespace: "member")
                            CTMemCache.sharedInstance.set("currentMid", data: mid, namespace: "member")
                            
                            self.delegate?.memberDidSigninSuccess(mid, token: "0")
                            self.dismiss()
                        }
                })
            }
        }
        **/
    }
    
    
    func signinWithWechat() {
        
        
        
        CTMemCache.sharedInstance.set(VCAppLetor.LoginType.WeChat, data: true, namespace: "Sign")
        
        ShareSDK.getUserInfoWithType(ShareTypeWeixiSession, authOptions: nil) {
            (result, userInfo, error) -> Void in
            
            if result {
                
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.hud?.mode = MBProgressHUDMode.Indeterminate
                
                println("result: \(result) | userInfo: \(userInfo.sourceData() as NSDictionary)")
                
                // Fitch member info from server when login return success, cache member info in the local and refresh userinterface
                //============================================================
                var mid: String = userInfo.uid()
                
                if (error == nil) {
                    
                    let userInfoDict = userInfo.sourceData() as NSDictionary
                    
                    var wxUserInfo: NSMutableDictionary = NSMutableDictionary()
                    wxUserInfo.setValue(userInfo.uid(), forKeyPath: "uid")
                    wxUserInfo.setValue(userInfoDict.valueForKey("openid"), forKeyPath: "openid")
                    wxUserInfo.setValue(userInfo.nickname(), forKeyPath: "nickname")
                    let sex: AnyObject? = userInfoDict.valueForKey("sex")
                    wxUserInfo.setValue("\(sex!)", forKeyPath: "sex")
                    wxUserInfo.setValue(userInfoDict.valueForKey("province"), forKeyPath: "province")
                    wxUserInfo.setValue(userInfoDict.valueForKey("city"), forKeyPath: "city")
                    wxUserInfo.setValue(userInfoDict.valueForKey("country"), forKeyPath: "country")
                    wxUserInfo.setValue(userInfo.profileImage(), forKeyPath: "headimgurl")
                    wxUserInfo.setValue(userInfoDict.valueForKey("unionid"), forKeyPath: "unionid")
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatLogInfo, data: wxUserInfo, namespace: "LoginStatus")
                    
                    Alamofire.request(VCheckGo.Router.LoginWithWechat(wxUserInfo)).validate().responseSwiftyJSON({
                        (_, _, JSON, error) -> Void in
                        
                        if error == nil {
                            
                            let json = JSON
                            
                            if json["status"]["succeed"].string! == "1" {
                                
                                let memberId = json["data"]["member_id"].string!
                                let token = json["data"]["token"].string!
                                
                                if memberId == "0" && token == "" {
                                    
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatLog, data: true, namespace: "LoginStatus")
                                    
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatAvatar, data: wxUserInfo.valueForKey("headimgurl"), namespace: "LoginStatus")
                                    CTMemCache.sharedInstance.set(VCAppLetor.LoginStatus.WechatNickname, data: wxUserInfo.valueForKey("nickname"), namespace: "LoginStatus")
                                    
                                    self.delegate?.memberDidSigninWithWechatSuccess(memberId, token: token)
                                    
                                }
                                else {
                                    
                                    self.delegate?.memberDidSigninSuccess(memberId, token: token)
                                    
                                }
                                
                                self.dismiss()
                                
                            }
                            else {
                                RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            }
                            
                        }
                        else {
                            println("ERROR @ Login with wechat : \(error?.localizedDescription)")
                        }
                    })
                }
                else {
                    
                    self.hud?.hide(true)
                    println("ERROR @ Auth with WeChat:\(error.errorCode())-\(error.errorDescription())")
                }
                
                
                BreezeStore.saveInMain({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    
                    member.mid = userInfo.uid()
                    member.nickname = userInfo.nickname()
                    member.iconURL = userInfo.profileImage()
                    member.lastLog = NSDate()
                    member.token = "1"
                    
                })
            }
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func isEmail(email: String) -> Bool {
        
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
    func isMobile(mobile: String) -> Bool {
        
        let mobileRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
        let mobileTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobileTest.evaluateWithObject(mobile)
    }
    
    
    // MARK: - UIGesture
    
    func viewDidTap(gesture: UITapGestureRecognizer) {
        self.loginName.resignFirstResponder()
        self.loginPass.resignFirstResponder()
    }
    
    
    
    
    
}








