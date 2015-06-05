//
//  FindMyPasscodeViewController.swift
//  
//
//  Created by Gabriel Anthony on 15/5/8.
//
//

import UIKit
import PureLayout
import Alamofire
import AFViewShaker
import RKDropdownAlert
import MBProgressHUD

class FindMyPasscodeViewController: VCBaseViewController, RKDropdownAlertDelegate {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let phoneNumber: UITextField = UITextField.newAutoLayoutView()
    let phoneUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var mobileShaker: AFViewShaker?
    
    var parentNav: UINavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.FindBackMyPassTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "getAuthCode")
        
        self.phoneNumber.placeholder = VCAppLetor.StringLine.PhoneNumber
        self.phoneNumber.clearButtonMode = .WhileEditing
        self.phoneNumber.keyboardType = UIKeyboardType.NumberPad
        self.scrollView.addSubview(phoneNumber)
        
        self.mobileShaker = AFViewShaker(view: self.phoneNumber)
        
        self.phoneUnderline.drawType = "Line"
        self.phoneUnderline.lineWidth = 1.0
        self.scrollView.addSubview(phoneUnderline)
        
        self.view.addSubview(self.scrollView)
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.phoneNumber.becomeFirstResponder()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.phoneNumber.autoSetDimensionsToSize(CGSizeMake(200.0, 30.0))
        self.phoneNumber.autoAlignAxisToSuperviewAxis(.Vertical)
        self.phoneNumber.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        
        self.phoneUnderline.autoAlignAxisToSuperviewAxis(.Vertical)
        self.phoneUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.phoneNumber, withOffset: 3.0)
        self.phoneUnderline.autoMatchDimension(.Width, toDimension: .Width, ofView: self.phoneNumber, withOffset: 20.0)
        self.phoneUnderline.autoSetDimension(.Height, toSize: 3.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Functions
    
    func getAuthCode() {
        
        let mobile = self.phoneNumber.text
        self.phoneNumber.resignFirstResponder()
        
        if mobile == "" || !self.isMobile(mobile) {
            self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                RKDropdownAlert.title(VCAppLetor.StringLine.MobileIllegal, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
            })
        }
        else {
            self.isValidMobile(mobile)
        }
    }
    
    func isValidMobile(mobile: String) {
        
        var valid = false
        let hud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.AnnularDeterminate
        
        // Sending verufy code to member's mobile via sms
        Alamofire.request(VCheckGo.Router.ValidateMemberInfo(VCheckGo.ValidateType.Mobile, mobile)).validate().responseSwiftyJSON({
            (_, _, JSON, error) -> Void in
            
            let json = JSON
            
            if (error == nil) {
                
                if json["status"]["succeed"].string == "0" && json["status"]["error_code"].string == VCAppLetor.ErrorCode.MobileAlreadyExist {
                    
                    let smsCodeViewController: SMSCodeViewController = SMSCodeViewController()
                    smsCodeViewController.parentNav = self.parentNav
                    smsCodeViewController.phoneNumber.text = self.phoneNumber.text
                    self.parentNav?.showViewController(smsCodeViewController, sender: self)
                }
                else {
                    self.mobileShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                        RKDropdownAlert.title(VCAppLetor.StringLine.MobileNotExist, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime, delegate: self)
                    })
                }
            }
            else {
                println("ERROR @ Validate member info request : \(error?.localizedDescription)")
            }
            hud.hide(true)
        })
    }
    
    func isMobile(mobile: String) -> Bool {
        
        let mobileRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
        let mobileTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        return mobileTest.evaluateWithObject(mobile)
    }
    
    func isEmail(email: String) -> Bool {
        
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
    // MARK: - RKDropdownAlert Delegate
    
    func dropdownAlertWasDismissed() -> Bool {
        self.phoneNumber.becomeFirstResponder()
        return true
    }
    
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        self.phoneNumber.becomeFirstResponder()
        return true
    }
    
    
    
}



