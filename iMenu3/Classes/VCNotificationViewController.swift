//
//  UserPanelViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/4.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PureLayout
import RKDropdownAlert

class VCNotificationViewController: VCBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Make Values
    let kCellIdentifier = "NotificationOptionCell"
    
    var tableView: UITableView!
    
    var memberInfo: MemberInfo?
    
    // Interface datasource
    let Settings: [String: [String]] = VCAppLetor.UserPanel.NotificationOptions
    
    let allowSwitch: UISwitch = UISwitch.newAutoLayoutView()
    
    var parentNav: UINavigationController?
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.NotificationOptionsTitle
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        
        // Config tableView Style
        self.tableView = UITableView(frame: CGRectMake(0, 64, self.view.width, self.view.height), style: UITableViewStyle.Grouped)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.tableView.registerClass(VCNotificationViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        self.setupOptionHeader()
        
        let userpanelFooterView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 120))
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 30, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        userpanelFooterView.addSubview(noMoreView)
        
        self.tableView.tableFooterView = userpanelFooterView
        
        // For header view
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.view.setNeedsUpdateConstraints()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let pushSwitch = self.allowSwitch.on ? "1" : "0"
        
        let cellOrder = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! VCNotificationViewCell
        let order = cellOrder.checkBox.selected ? "1" : "0"
        
        let cellRefund = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! VCNotificationViewCell
        let refund = cellRefund.checkBox.selected ? "1" : "0"
        
        let cellVoucher = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! VCNotificationViewCell
        let voucher = cellVoucher.checkBox.selected ? "1" : "0"
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        println("status: \(pushSwitch)|\(order)|\(refund)|\(voucher)")
        
        Alamofire.request(VCheckGo.Router.EditMemberNotification(memberId, pushSwitch, order, refund, voucher, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    // DO NOTHING if succeed
                    println("succeed")
                    
                    let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                    
                    memberInfo.pushSwitch = pushSwitch
                    memberInfo.pushOrder = order
                    memberInfo.pushRefund = refund
                    memberInfo.pushVoucher = voucher
                    
                    CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                    
                    if pushSwitch == "0" {
                        
                        XGPush.setTag(VCAppLetor.XGPush.pushClose, successCallback: { () -> Void in
                            
                            //XGPush.unRegisterDevice()
                        }, errorCallback: { () -> Void in
                            
                        })
                    }
                    
                }
                else {
                    
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            }
            else {
                
                println("ERROR @ Request edit push notification options : \(error?.localizedDescription)")
            }
            
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.Settings.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Settings.values.array[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: VCNotificationViewCell = tableView.dequeueReusableCellWithIdentifier("NotificationOptionCell", forIndexPath: indexPath) as! VCNotificationViewCell
        
        let current = self.Settings.values.array[indexPath.section][indexPath.row]
        cell.panelTitle.text = current
        cell.checkBox.addTarget(self, action: "checkOption:", forControlEvents: .TouchUpInside)
        
        if indexPath.row == 0 {
            if self.memberInfo?.pushOrder! == "0" {
                cell.checkBox.setSelected(false, animated: false)
            }
        }
        if indexPath.row == 1 {
            if self.memberInfo?.pushRefund! == "0" {
                cell.checkBox.setSelected(false, animated: false)
            }
        }
        if indexPath.row == 2 {
            if self.memberInfo?.pushVoucher! == "0" {
                cell.checkBox.setSelected(false, animated: false)
            }
        }
        
        cell.setNeedsUpdateConstraints()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return VCAppLetor.ConstValue.UserPanelCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected = self.Settings.values.array[indexPath.section][indexPath.row]
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! VCNotificationViewCell
        
        if cell.checkBox.selected {
            cell.checkBox.setSelected(false, animated: true)
        }
        else {
            cell.checkBox.setSelected(true, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    
    // MARK: - Functions
    
    
    func isAllowedLocationService() -> Bool {
        
        
        if !CLLocationManager.locationServicesEnabled() {
            
            return false
        }
        else {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                
                return false
            }
        }
        
        return true
    }
    
    func checkOption(checkBox: ZFCheckbox) {
        
        if !checkBox.selected {
            
            checkBox.setSelected(true, animated: true)
            
            if !self.allowSwitch.on {
                self.allowSwitch.setOn(true, animated: true)
            }
        }
        else {
            checkBox.setSelected(false, animated: true)
        }
        
    }
    
    func setupOptionHeader() {
        
        
        let headerView: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 60))
        
        let allowNotificationTitle: UILabel = UILabel.newAutoLayoutView()
        allowNotificationTitle.text = VCAppLetor.StringLine.AllowNotificationTitle
        allowNotificationTitle.textAlignment = .Left
        allowNotificationTitle.textColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        allowNotificationTitle.font = VCAppLetor.Font.BigFont
        headerView.addSubview(allowNotificationTitle)
        
        self.allowSwitch.tintColor = UIColor.lightGrayColor()
        self.allowSwitch.onTintColor = UIColor.nephritisColor(alpha: 1.0)
        self.allowSwitch.thumbTintColor = UIColor.whiteColor()
        self.allowSwitch.addTarget(self, action: "onSwitch:", forControlEvents: UIControlEvents.ValueChanged)
        headerView.addSubview(self.allowSwitch)
        
        if self.memberInfo?.pushSwitch == "1" {
            
            self.allowSwitch.setOn(true, animated: false)
        }
        else {
            self.allowSwitch.setOn(false, animated: false)
        }
        
        let headerUnderLine: CustomDrawView = CustomDrawView.newAutoLayoutView()
        headerUnderLine.drawType = "DoubleLine"
        headerView.addSubview(headerUnderLine)
        
        allowNotificationTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 30.0)
        allowNotificationTitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
        allowNotificationTitle.autoSetDimensionsToSize(CGSizeMake(90.0, 18.0))
        
        self.allowSwitch.autoPinEdgeToSuperviewEdge(.Top, withInset: 22.0)
        self.allowSwitch.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
        self.allowSwitch.autoSetDimensionsToSize(CGSizeMake(60.0, 20.0))
        
        headerUnderLine.autoPinEdge(.Top, toEdge: .Bottom, ofView: allowNotificationTitle, withOffset: 12.0)
        headerUnderLine.autoPinEdge(.Leading, toEdge: .Leading, ofView: allowNotificationTitle)
        headerUnderLine.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: allowSwitch, withOffset: 4.0)
        headerUnderLine.autoSetDimension(.Height, toSize: 5.0)
        
        self.tableView.tableHeaderView = headerView
        
    }
    
    func onSwitch(allowSwitch: UISwitch) {
        
        
        if allowSwitch.on {
            
            allowSwitch.setOn(true, animated: true)
            allowSwitch.thumbTintColor = UIColor.whiteColor()
        }
        else {
            allowSwitch.setOn(false, animated: true)
            allowSwitch.thumbTintColor = UIColor.cloudsColor(alpha: 1.0)
        }
        
        for var i=0; i < self.Settings.values.array[0].count; i++ {
            
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! VCNotificationViewCell
            
            if allowSwitch.on {
                
                cell.checkBox.setSelected(true, animated: true)
                cell.checkBox.lineColor = UIColor.nephritisColor().colorWithAlphaComponent(0.8)
                cell.checkBox.lineBackgroundColor = UIColor.nephritisColor().colorWithAlphaComponent(0.8)
                cell.checkBox.backgroundColor = UIColor.whiteColor()
            }
            else {
                
                cell.checkBox.setSelected(false, animated: true)
                cell.checkBox.lineColor = UIColor.clearColor()
                cell.checkBox.lineBackgroundColor = UIColor.clearColor()
                
            }
        }
    }
    
    
    // IF the current user is Login to the app
    func isLogined() -> Bool {
        
        return CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token")
    }
    
    
    
    
}