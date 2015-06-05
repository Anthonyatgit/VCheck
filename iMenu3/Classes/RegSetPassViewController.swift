//
//  RegSetPassViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/15.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD

protocol MemberRegisterDelegate {
    func memberDidFinishRegister(mid: String, token: String)
}

class RegSetPassViewController: VCBaseViewController {
    
    let scrollView: UIScrollView = UIScrollView()
    
    let newPasscode: UITextField = UITextField.newAutoLayoutView()
    let newPassUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    var delegate: MemberRegisterDelegate?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.LoginPass
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Next, style: .Done, target: self, action: "regSetpassDone")
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        
        self.newPasscode.placeholder = VCAppLetor.StringLine.InitPasscode
        self.newPasscode.clearButtonMode = .WhileEditing
        self.newPasscode.font = VCAppLetor.Font.BigFont
        self.newPasscode.textAlignment = .Center
        self.newPasscode.secureTextEntry = true
        self.scrollView.addSubview(self.newPasscode)
        
        newPassUnderline.drawType = "Line"
        newPassUnderline.lineWidth = 1.0
        self.scrollView.addSubview(newPassUnderline)
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        
        self.newPasscode.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 30.0)
        self.newPasscode.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        self.newPasscode.autoMatchDimension(ALDimension.Width, toDimension: ALDimension.Width, ofView: self.view, withMultiplier: 0.6, relation: NSLayoutRelation.GreaterThanOrEqual)
        self.newPasscode.autoSetDimension(ALDimension.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        
        newPassUnderline.autoMatchDimension(ALDimension.Width, toDimension: ALDimension.Width, ofView: self.newPasscode, withOffset: 20.0)
        newPassUnderline.autoSetDimension(ALDimension.Height, toSize: VCAppLetor.ConstValue.UnderlineHeight)
        newPassUnderline.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.newPasscode)
        newPassUnderline.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Functions
    
    func regSetpassDone() {
        
        // Register logistic with server side
        let passcodeToBeSet = self.newPasscode.text
        
        if count(passcodeToBeSet) >= VCAppLetor.ConstValue.MinLengthOfPasscode {
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Determinate
            hud.labelText = VCAppLetor.StringLine.RegisterInProgress
            
            let mobile = CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.Mobile, namespace: "member")?.data as! String
            let code = ((CTMemCache.sharedInstance.get(VCAppLetor.UserInfo.SaltCode, namespace: "member")?.data as! String) + VCAppLetor.StringLine.SaltKey).md5
            // Submit member register request
            Alamofire.request(VCheckGo.Router.MemberRegister(mobile, passcodeToBeSet, code)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string == "1" {
                        
                        self.newPasscode.resignFirstResponder()
                        self.delegate?.memberDidFinishRegister(json["data"]["member_id"].string!, token: json["data"]["token"].string!)
                        self.dismiss()
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                }
                else {
                    println("ERROR @ Send request for member register : \(error?.localizedDescription)")
                }
                
                hud.hide(true)
            })
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.PasscodeTooShort, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
    
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}


