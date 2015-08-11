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

class VCSettingsViewController: VCBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIAlertViewDelegate {
    
    // MARK: - Make Values
    let kCellIdentifier = "SettingsCell"
    
    var tableView: UITableView!
    
    // Interface datasource
    let Settings: [String: [String]] = VCAppLetor.UserPanel.Settings
    
    var cacheSize: UInt64 = 0
    
    var parentNav: UINavigationController?
    var userPanelVC: UserPanelViewController?
    
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.SettingsTitle
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
        
        self.tableView.registerClass(VCSettingsViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        
        
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
        
        let cell: VCSettingsViewCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! VCSettingsViewCell
        
        let current = self.Settings.values.array[indexPath.section][indexPath.row]
        cell.panelTitle.text = current
        
        
        if indexPath.row == 0  && indexPath.section == 0 {
            cell.descLabel.text = ""
        }
        else if indexPath.row == 1  && indexPath.section == 0 {
            
            if self.isAllowedLocationService() {
                cell.descLabel.text = VCAppLetor.StringLine.LSIsEnabled
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            else {
                cell.descLabel.text = VCAppLetor.StringLine.LSIsDisabled
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        else if indexPath.row == 2  && indexPath.section == 0 {
            var cacheDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
            cacheDirectoryURL = cacheDirectoryURL.URLByAppendingPathComponent("product")
            
            let cacheSizeStr = ("\(self.getCacheFileSize(cacheDirectoryURL.path!))" as NSString).floatValue / 1024.0
            
            
            cell.descLabel.text = "\(cacheSizeStr) Mb"
            
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else if indexPath.row == 3  && indexPath.section == 0 {
            
            
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
        
        if (indexPath.section == 0 && indexPath.row == 0) { // Push Notification
            
            if (isLogined()) {
                
                let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                
                let notificationOptionsVC: VCNotificationViewController = VCNotificationViewController()
                notificationOptionsVC.parentNav = self.parentNav
                notificationOptionsVC.memberInfo = memberInfo
                self.parentNav?.showViewController(notificationOptionsVC, sender: self)
                
            }
            else {
                self.presentLoginPanel() // Present user login interface
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1) { // Location Service
            
            //UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=LOCATION_SERVICES")!)
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            }
            
        }
        else if (indexPath.section == 0 && indexPath.row == 2) { // Cache
            
            if self.cacheSize != 0 {
                
                let clearAlert: UIAlertView = UIAlertView(title: VCAppLetor.StringLine.ClearImageCache, message: "", delegate: self, cancelButtonTitle: "否", otherButtonTitles: "是")
                clearAlert.show()
            }
            
            
        }
        else if (indexPath.section == 0 && indexPath.row == 3) { // Rate Us
            
            let url = NSURL(string: VCAppLetor.ConstValue.AppStoreRateURL)
            
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            }
            else {
                RKDropdownAlert.title(VCAppLetor.StringLine.AppStoreUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
            }
        }
        else {
            return
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    // MARK: - UIAlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            
        }
        else if buttonIndex == 1 {
            self.clearImageCache()
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! VCSettingsViewCell
            cell.descLabel.text = "0 Mb"
        }
    }
    
    
    // MARK: - Functions
    
    func clearImageCache() {
        
        var directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
        directoryURL = directoryURL!.URLByAppendingPathComponent("product")
        
        if NSFileManager.defaultManager().fileExistsAtPath(directoryURL!.path!) {
            
            var err: NSError?
            
            NSFileManager.defaultManager().removeItemAtPath(directoryURL!.path!, error: &err)
            println("remove path: \(directoryURL!.path!)")
            
            NSFileManager.defaultManager().createDirectoryAtPath(directoryURL!.path!, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
    }
    
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
    
    func getCacheFileSize(folderPath: String) -> UInt64 {
        
        let manager: NSFileManager = NSFileManager.defaultManager()
        
        if !manager.fileExistsAtPath(folderPath) {
            return 0
        }
        
        let childFilesEnumerator: NSEnumerator = (manager.subpathsAtPath(folderPath) as! AnyObject).objectEnumerator()
        
        
        var folderSize: UInt64 = 0
        
        while let fileName = childFilesEnumerator.nextObject() as? String {
            
            
            if !fileName.isEmpty {
                
                let fileAbsolutePath: String = folderPath.stringByAppendingPathComponent(fileName)
                
                println("file: \(fileAbsolutePath) | size: \(folderSize)")
                
                folderSize += self.fileSizeAtPath(fileAbsolutePath)
            }
            
        }
        
        self.cacheSize = folderSize/(1024*1024)
        
        return folderSize/1024
        
    }
    
    func fileSizeAtPath(filePath: String) -> UInt64 {
        
        let manager: NSFileManager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(filePath) {
            return (manager.attributesOfItemAtPath(filePath, error: nil) as! AnyObject).fileSize()
        }
        
        return 0
    }
    
    func presentLoginPanel() {
        
        self.parentNav?.popViewControllerAnimated(true)
        self.userPanelVC?.presentLoginPanel()
    }
    
    func getMemberInfo() {
        
    }
    
    
    // IF the current user is Login to the app
    func isLogined() -> Bool {
        
        return CTMemCache.sharedInstance.exists(VCAppLetor.SettingName.optToken, namespace: "token")
    }
    
    func freeServiceCall() {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://4008369917")!)
    }
    
    
    
}