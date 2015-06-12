//
//  FeedbackViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/10.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//


import UIKit
import PureLayout
import Alamofire
import AFViewShaker
import RKDropdownAlert
import MBProgressHUD

class FeedbackViewController: VCBaseViewController, UITextViewDelegate {
    
    var parentNav: UINavigationController?
    
    let scrollView: UIScrollView = UIScrollView()
    
    let feedbackInfo: UITextView = UITextView.newAutoLayoutView()
    let feedbackBG: UITextView = UITextView.newAutoLayoutView()
    let feedbackInfoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var feedbackInfoShaker: AFViewShaker?
    
    let contactInfoName: UILabel = UILabel.newAutoLayoutView()
    let contactInfoText: UITextField = UITextField.newAutoLayoutView()
    let contactInfoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var hud: MBProgressHUD!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.FeedBackTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: VCAppLetor.StringLine.Send, style: .Done, target: self, action: "sendFeedbackAction")
        
        self.feedbackBG.text = VCAppLetor.StringLine.FeedBackPlaceholder
        self.feedbackBG.font = VCAppLetor.Font.NormalFont
        self.feedbackBG.textAlignment = .Left
        self.feedbackBG.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
//        self.feedbackBG.delegate = self
//        self.feedbackBG.editable = false
//        self.feedbackBG.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.scrollView.addSubview(self.feedbackBG)
        
        self.feedbackInfo.text = ""
        self.feedbackInfo.font = VCAppLetor.Font.NormalFont
        self.feedbackInfo.textAlignment = .Left
        self.feedbackInfo.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.feedbackInfo.keyboardType = UIKeyboardType.EmailAddress
        self.feedbackInfo.backgroundColor = UIColor.clearColor()
        self.feedbackInfo.delegate = self
        self.scrollView.addSubview(self.feedbackInfo)
        
        self.feedbackInfoShaker = AFViewShaker(view: self.feedbackBG)
        
        self.feedbackInfoUnderline.drawType = "GrayLine"
        self.feedbackInfoUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.feedbackInfoUnderline)
        
        self.contactInfoName.text = VCAppLetor.StringLine.ContactInfo
        self.contactInfoName.textAlignment = .Left
        self.contactInfoName.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contactInfoName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.contactInfoName)
        
        self.contactInfoText.placeholder = VCAppLetor.StringLine.ContactPlaceHolder
        self.contactInfoText.font = VCAppLetor.Font.NormalFont
        self.contactInfoText.textAlignment = .Left
        self.contactInfoText.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.contactInfoText.keyboardType = UIKeyboardType.EmailAddress
        self.scrollView.addSubview(self.contactInfoText)
        
        self.contactInfoUnderline.drawType = "GrayLine"
        self.contactInfoUnderline.lineWidth = 1.0
        self.scrollView.addSubview(self.contactInfoUnderline)
        
        
        self.view.addSubview(self.scrollView)
        
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.feedbackInfo.becomeFirstResponder()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.feedbackBG.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
        self.feedbackBG.autoSetDimension(.Width, toSize: self.scrollView.width - 40.0)
        self.feedbackBG.autoSetDimension(.Height, toSize: 150.0)
        self.feedbackBG.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.feedbackInfo.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
        self.feedbackInfo.autoSetDimension(.Width, toSize: self.scrollView.width - 40.0)
        self.feedbackInfo.autoSetDimension(.Height, toSize: 150.0)
        self.feedbackInfo.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.feedbackInfoUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.feedbackInfo)
        self.feedbackInfoUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.feedbackInfo)
        self.feedbackInfoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.feedbackInfo, withOffset: 10.0)
        self.feedbackInfoUnderline.autoSetDimension(.Height, toSize: 3.0)
        
        self.contactInfoName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.feedbackInfo, withOffset: 20.0)
        self.contactInfoName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.feedbackInfoUnderline, withOffset: 20.0)
        self.contactInfoName.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
        
        self.contactInfoText.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.contactInfoName, withOffset: 20.0)
        self.contactInfoText.autoAlignAxis(.Horizontal, toSameAxisOfView: self.contactInfoName)
        self.contactInfoText.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.feedbackInfo, withOffset: 20.0)
        self.contactInfoText.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.TextFieldHeight)
        
        self.contactInfoUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.feedbackInfo)
        self.contactInfoUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.feedbackInfo)
        self.contactInfoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.contactInfoName, withOffset: 20.0)
        self.contactInfoUnderline.autoSetDimension(.Height, toSize: 3.0)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITextField Delegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text != "" {
            self.feedbackBG.hidden = true
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            self.feedbackBG.hidden = false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text != "" {
            self.feedbackBG.hidden = true
        }
        else {
            self.feedbackBG.hidden = false
        }
    }
    
    
    // MARK: - Functions
    
    func sendFeedbackAction() {
        
        let feedbackText = self.feedbackInfo.text
        
        if self.reachability.isReachable() {
            
            if feedbackText != "" {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.hud.mode = MBProgressHUDMode.Indeterminate
                
                let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
                let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
                
                Alamofire.request(VCheckGo.Router.FeedBack(memberId, token, feedbackText)).validate().responseSwiftyJSON({
                    (_, _, JSON, error) -> Void in
                    
                    if error == nil {
                        
                        let json = JSON
                        self.hud.hide(true)
                        
                        println("\(json)")
                        
                        if json["status"]["succeed"].string == "1" {
                            
                            RKDropdownAlert.title(VCAppLetor.StringLine.FeedbackSucceed, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                            
                            self.parentNav?.popViewControllerAnimated(true)
                        }
                        else {
                            RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        }
                    }
                    else {
                        self.hud.hide(true)
                        println("ERROR @ Feedback request : \(error?.localizedDescription)")
                    }
                })
                
            }
            else {
                self.feedbackInfoShaker?.shakeWithDuration(VCAppLetor.ConstValue.TextFieldShakeTime, completion: { () -> Void in
                    RKDropdownAlert.title(VCAppLetor.StringLine.FeedbackTextEmpty, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                })
            }
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
        
        
    }
    
    
    
    
    
    

}




