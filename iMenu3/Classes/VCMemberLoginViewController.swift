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
}

class VCMemberLoginViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, RKDropdownAlertDelegate {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let loginTitle: UILabel = UILabel.newAutoLayoutView()
    let loginName: UITextField = UITextField.newAutoLayoutView()
    let loginPass: UITextField = UITextField.newAutoLayoutView()
    
    var loginNameShaker: AFViewShaker?
    var loginPassShaker: AFViewShaker?
    
    let weiboSignInButton: UIButton = UIButton.newAutoLayoutView()
    let wechatSignInButton: UIButton = UIButton.newAutoLayoutView()
    let logoutButton: UIButton = UIButton.newAutoLayoutView()
    
    let forgetPassButton = UIButton.newAutoLayoutView()
    let nameUnderLine = CustomDrawView.newAutoLayoutView()
    let passUnderLine = CustomDrawView.newAutoLayoutView()
    let signUpText: UILabel = UILabel.newAutoLayoutView()
    let signUpButton: UIButton = UIButton.newAutoLayoutView()
    
    var delegate: MemberSigninDelegate? = nil
    var userPanelController: UserPanelViewController?
    
    
    let socialLine1 = CustomDrawView.newAutoLayoutView()
    let socialLine2 = CustomDrawView.newAutoLayoutView()
    let socialSignInTitle: UILabel = UILabel.newAutoLayoutView()
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.title = VCAppLetor.StringLine.LoginPageTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Done, style: .Done, target: self, action: "letMeLogin")
        navigationItem.leftBarButtonItem = barButtonItemWithImageNamed(VCAppLetor.IconName.ClearIconBlack, title: nil, action: "dismiss")
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap:")
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.numberOfTouchesRequired = 1
        
        // Top Description Text
        self.loginTitle.text = VCAppLetor.StringLine.LoginTitle
        self.loginTitle.font = VCAppLetor.Font.NormalFont
        self.loginTitle.textColor = UIColor.blackColor()
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
        forgetPassButton.setImage(UIImage(named: VCAppLetor.IconName.HelpIconBlack), forState: .Normal)
        forgetPassButton.alpha = 0.1
        forgetPassButton.addTarget(self, action: "forgotMyPasscode", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(forgetPassButton)
        
        // Login Passcode Underline
        passUnderLine.drawType = "Line"
        passUnderLine.lineWidth = 1.0
        self.scrollView.addSubview(passUnderLine)
        
        // SignUp Description Text
        signUpText.text = VCAppLetor.StringLine.SignUpText
        signUpText.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(signUpText)
        
        // SignUp Button
        signUpButton.setTitle(VCAppLetor.StringLine.SignUpButtonText, forState: .Normal)
        signUpButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        signUpButton.titleLabel?.font = VCAppLetor.Font.NormalFont
        signUpButton.addTarget(self, action: "letMeRegister", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(signUpButton)
        
        
        self.weiboSignInButton.setImage(UIImage(named: "weibo.png"), forState: .Normal)
        self.weiboSignInButton.addTarget(self, action: "signinWithWeibo", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.weiboSignInButton)
        
        self.wechatSignInButton.setImage(UIImage(named: "wechat.png"), forState: .Normal)
        self.wechatSignInButton.addTarget(self, action: "signinWithWechat", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.wechatSignInButton)
        
        
        socialLine1.drawType = "Line"
        socialLine1.lineWidth = 2.0
        self.scrollView.addSubview(socialLine1)
        
        socialLine2.drawType = "Line"
        socialLine2.lineWidth = 1.0
        self.scrollView.addSubview(socialLine2)
        
        socialSignInTitle.text = VCAppLetor.StringLine.SocialSignUpTitle
        socialSignInTitle.textAlignment = .Center
        socialSignInTitle.backgroundColor = UIColor.whiteColor()
        socialSignInTitle.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(socialSignInTitle)
        
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
        
        self.loginTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        self.loginTitle.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.loginTitle.autoSetDimension(.Height, toSize: 20.0)
        self.loginTitle.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.loginName.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        self.loginName.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        self.loginName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginTitle, withOffset: VCAppLetor.ConstValue.LineGap)
        self.loginName.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.loginPass.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.loginName)
        self.loginPass.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginName, withOffset: VCAppLetor.ConstValue.LineGap)
        self.loginPass.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: -24.0)
        self.loginPass.autoMatchDimension(.Height, toDimension: .Height, ofView: self.loginName)
        
        nameUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginName, withOffset: 1.0)
        nameUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: 20.0)
        nameUnderLine.autoSetDimension(.Height, toSize: 3.0)
        nameUnderLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        forgetPassButton.autoSetDimensionsToSize(CGSizeMake(24.0, 24.0))
        forgetPassButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.loginName)
        forgetPassButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.loginPass)
        
        passUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginPass, withOffset: 1.0)
        passUnderLine.autoMatchDimension(.Width, toDimension: .Width, ofView: self.loginName, withOffset: 20.0)
        passUnderLine.autoSetDimension(.Height, toSize: 3.0)
        passUnderLine.autoAlignAxisToSuperviewAxis(.Vertical)
        
        signUpText.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.loginName, withOffset: 20.0)
        signUpText.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        signUpText.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.loginPass, withOffset: VCAppLetor.ConstValue.LineGap)
        
        signUpButton.autoSetDimensionsToSize(CGSizeMake(75.0, 20.0))
        signUpButton.autoPinEdge(.Leading, toEdge: .Trailing, ofView: signUpText, withOffset: 0.0)
        signUpButton.autoAlignAxis(.Horizontal, toSameAxisOfView: signUpText)
        
        self.weiboSignInButton.autoSetDimensionsToSize(CGSizeMake(52.0, 52.0))
        self.weiboSignInButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.signUpText, withOffset: 120.0)
        self.weiboSignInButton.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.signUpText)
        
        self.wechatSignInButton.autoSetDimensionsToSize(CGSizeMake(52.0, 52.0))
        self.wechatSignInButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.weiboSignInButton)
        self.wechatSignInButton.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.signUpButton)
        
        socialLine1.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.weiboSignInButton, withOffset: -45.0)
        socialLine1.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        socialLine1.autoSetDimension(.Height, toSize: 3.0)
        socialLine1.autoAlignAxisToSuperviewAxis(.Vertical)
        
        socialLine2.autoPinEdge(.Top, toEdge: .Bottom, ofView: socialLine1, withOffset: 1.0)
        socialLine2.autoAlignAxisToSuperviewAxis(.Vertical)
        socialLine2.autoMatchDimension(.Width, toDimension: .Width, ofView: self.scrollView, withMultiplier: 0.8)
        socialLine2.autoSetDimension(.Height, toSize: 2.0)
        
        socialSignInTitle.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        socialSignInTitle.autoAlignAxisToSuperviewAxis(.Vertical)
        socialSignInTitle.autoPinEdge(.Top, toEdge: .Top, ofView: socialLine1, withOffset: -7.0)
        
        
        
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
    
    // MARK: Functions
    
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        
        let button: UIButton = UIButton.newAutoLayoutView()
        
        if imageName != nil {
            button.setImage(UIImage(named: imageName!)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        if title != nil {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSizeMake(90.0, 24.0))
        button.frame = CGRectMake(0.0, 0.0, 42.0, 42.0)
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        
        if action != nil {
            button.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }
    
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
            
            hud.hide(true)
        }
        
        
    }
    
    
    func letMeRegister() {
        
        // Present member register page
        
        if CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String == "0" {
            
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
        
        ShareSDK.getUserInfoWithType(ShareTypeSinaWeibo, authOptions: nil) { (result, userInfo, error) -> Void in
            
            if result {
                
                // Fitch member info from server when login return success, cache member info in the local and refresh userinterface
                //============================================================
                
                var mid: String = userInfo.uid()
                
                println("Userinfo: \(userInfo)")
                
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
                            self.logoutButton.hidden = false
                            self.dismiss()
                        }
                })
            }
        }
        
    }
    
    
    func signinWithWechat() {
        
        ShareSDK.getUserInfoWithType(ShareTypeWeixiTimeline, authOptions: nil) { (result, userInfo, error) -> Void in
            
            if result {
                
                
                println("Userinfo: \(userInfo)")
                
                // Fitch member info from server when login return success, cache member info in the local and refresh userinterface
                //============================================================
                var mid: String = userInfo.uid()
                
                BreezeStore.saveInBackground({ (contextType) -> Void in
                    
                    let member = Member.createInContextOfType(contextType) as! Member
                    member.mid = userInfo.uid()
                    member.nickname = userInfo.nickname()
                    member.iconURL = userInfo.profileImage()
                    
                    }, completion: { error -> Void in
                        
                        if (error != nil) {
                            println("\(error?.localizedDescription)")
                        }
                        else {
                            
                            CTMemCache.sharedInstance.set("isLogin", data: true, namespace: "member")
                            CTMemCache.sharedInstance.set("loginType", data: VCAppLetor.LoginType.WeChat, namespace: "member")
                            CTMemCache.sharedInstance.set("currentMid", data: mid, namespace: "member")
                            // Prepare for member login refresh
                            self.delegate?.memberDidSigninSuccess(mid, token: "0")
                            self.logoutButton.hidden = false
                            self.dismiss()
                        }
                })
            }
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showShareAction() {
        
        var shareContent: ISSContent = ShareSDK.content("分享文字", defaultContent: "默认分享内容，没内容时显示", image: nil, title: "提示", url: "返回链接", description: "这是一条测试内容", mediaType: SSPublishContentMediaTypeNews)
        
        var shareList: NSArray = ShareSDKContentController.getCustomShareList()
        
        println("\(shareList)")
        
        let container: ISSContainer = ShareSDK.container()
        container.setIPhoneContainerWithViewController(self)
        
        ShareSDK.showShareActionSheet(nil,
            shareList: nil,
            content: shareContent,
            statusBarTips: true,
            authOptions: nil,
            shareOptions: nil,
            result: { (type: ShareType, state:SSResponseState, statusInfo: ISSPlatformShareInfo!, error: ICMErrorInfo!, end: Bool) in
                
                println(state.value)
                
                if (state.value == SSResponseStateSuccess.value) {
                    println("分享成功")
                    var alert = UIAlertView(title: "提示", message: "分享成功", delegate: self, cancelButtonTitle: "确定")
                    alert.show()
                }
                else {
                    if (state.value == 2) {
                        var alert = UIAlertView(title: "提示", message: "您没有安装客户端", delegate: self, cancelButtonTitle: "确定")
                        alert.show()
                        println(error.errorCode())
                        println(error.errorDescription())
                    }
                }
                
        })
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








