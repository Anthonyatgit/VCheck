//
//  SMSCodeViewController.swift
//  
//
//  Created by Gabriel Anthony on 15/5/8.
//
//

import UIKit

class SMSCodeViewController: UIViewController {
    
    let phoneNumber: UILabel = UILabel()
    let SMSCode: FloatLabelTextField = FloatLabelTextField()
    let secondsLabel: UILabel = UILabel()
    let resentButton: UIButton = UIButton()
    
    var parentNav: UINavigationController?
    
    
    var remainingSeconds: Int = VCAppLetor.ConstValue.SMSRemainingSeconds {
        willSet(newSeconds) {
            self.secondsLabel.text = "\(newSeconds)"
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.SMSCode
        self.view.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "resetMyPasscode")
        
        self.phoneNumber.frame = CGRectMake(60, 82, 160, 30)
        self.phoneNumber.font = VCAppLetor.Font.NormalFont
        self.view.addSubview(self.phoneNumber)
        
        
        self.secondsLabel.frame = CGRectMake(230, 82, 60, 30)
        self.view.addSubview(self.secondsLabel)
        // Fire the seconds counting
        self.isCounting = !self.isCounting
        
        self.resentButton.frame = CGRectMake(230, 82, 60, 30)
        self.resentButton.backgroundColor = UIColor.orangeColor()
        self.resentButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.resentButton.setTitle(VCAppLetor.StringLine.Resent, forState: .Normal)
        
        self.resentButton.addTarget(self, action: "resentSMSCode", forControlEvents: .TouchUpInside)
        self.resentButton.hidden = true
        self.view.addSubview(self.resentButton)
        
        let phoneNumberUnderline: UIView = UIView(frame: CGRectMake(40, 114, 200, 1))
        phoneNumberUnderline.backgroundColor = UIColor.blackColor()
        self.view.addSubview(phoneNumberUnderline)
        
        self.SMSCode.frame = CGRectMake(60, 134, 160, 30)
        self.SMSCode.placeholder = VCAppLetor.StringLine.InputSMSCode
        self.SMSCode.clearButtonMode = .WhileEditing
        self.SMSCode.keyboardType = UIKeyboardType.EmailAddress
        self.view.addSubview(self.SMSCode)
        
        let SMSCodeUnderline: UIView = UIView(frame: CGRectMake(40, 166, 250, 1))
        SMSCodeUnderline.backgroundColor = UIColor.blackColor()
        self.view.addSubview(SMSCodeUnderline)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: Functions
    func resetMyPasscode() {

        let code = arc4random_uniform(9)
        println("\(code)")
        
        let resetPassViewController: ResetMyPasscodeViewController = ResetMyPasscodeViewController()
        resetPassViewController.view.bounds = self.view.bounds
        resetPassViewController.phoneNumber = self.phoneNumber.text
        resetPassViewController.parentNav = self.parentNav
        self.parentNav?.showViewController(resetPassViewController, sender: self)
        
    }
    
    
    func updateTimer(timer: NSTimer) {
        self.remainingSeconds -= 1
        
        if self.remainingSeconds <= 0 {
            self.isCounting = !self.isCounting
            
            self.secondsLabel.hidden = true
            self.resentButton.hidden = false
        }
    }
    
    func resentSMSCode() {
        
        // Call function to resent SMS Code
        
        // Reset Seconds counting
        self.remainingSeconds = VCAppLetor.ConstValue.SMSRemainingSeconds
        self.isCounting = !self.isCounting
        self.resentButton.hidden = true
        self.secondsLabel.hidden = false
    }
    
    
    
    
}




