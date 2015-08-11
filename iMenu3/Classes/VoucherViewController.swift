//
//  FavoritesViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/19.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD

@objc protocol VoucherDelegate {
    optional func didUseVoucher(voucherId: String, price: String)
    optional func didCancleVoucher()
    optional func didFinishExchangeVoucher()
}

class VoucherViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate, UIScrollViewDelegate {
    
    var parentNav: UINavigationController?
    
    var voucherList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    let headerView: CustomDrawView = CustomDrawView()
    
    let codeBar: UIView = UIView.newAutoLayoutView()
    let code: UITextField = UITextField.newAutoLayoutView()
    let codeBtn: UIButton = UIButton.newAutoLayoutView()
    let maskView: UIView = UIView.newAutoLayoutView()
    
    var currentPage: Int = 1
    var haveMore: Bool = false
    var isLoading: Bool = false
    
    var delegate: VoucherDelegate?
    
    var validCount: Int = 0
    
    var active: Bool = false
    var orderId: String = ""
    
    var hud: MBProgressHUD!
    
    // MARK: - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.VoucherTitle
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Rewrite back bar button
        if self.active {
            
            let cancleVoucher: UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 60.0, 24.0))
            cancleVoucher.setTitle(VCAppLetor.StringLine.CancleVoucher, forState: .Normal)
            cancleVoucher.titleLabel?.font = VCAppLetor.Font.BigFont
            cancleVoucher.titleLabel?.textAlignment = .Left
            cancleVoucher.titleLabel?.textColor = UIColor.whiteColor()
            cancleVoucher.backgroundColor = UIColor.clearColor()
            cancleVoucher.addTarget(self, action: "cancleVoucher", forControlEvents: .TouchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancleVoucher)
            
        }
        
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alpha = 0
        
        self.view.addSubview(self.tableView)
        
        
        // Register Cell View
        self.tableView.registerClass(VoucherViewCell.self, forCellReuseIdentifier: "voucherItemCell")
        
        
        let noMoreView: CustomDrawView = CustomDrawView(frame: CGRectMake(0, 0, self.view.width, 60.0))
        noMoreView.drawType = "noMore"
        noMoreView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = noMoreView
        
        self.getVoucherList()
        
        self.view.setNeedsUpdateConstraints()
        
        self.setupExchangeBar()
        
        self.setupExchangeView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispoe of any resources that can be recreated
    }
    
    
    // MARK: - RKDropdownAlert Delegate
    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        return true
    }
    
    func dropdownAlertWasDismissed() -> Bool {
        return true
    }
    
    // MARK: - Tableview data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        return self.voucherList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:VoucherViewCell = self.tableView.dequeueReusableCellWithIdentifier("voucherItemCell", forIndexPath: indexPath) as! VoucherViewCell
        
        cell.voucher = self.voucherList[indexPath.row] as! Voucher
        cell.parentNav = self.parentNav
        cell.setupViews()
        
        cell.setNeedsUpdateConstraints()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VCAppLetor.ConstValue.VoucherItemCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.active {
            
            let voucher = self.voucherList.objectAtIndex(indexPath.row) as! Voucher
            
            self.delegate?.didUseVoucher!(voucher.voucherId, price: voucher.price!)
            self.parentNav?.popViewControllerAnimated(true)
        }
        
    }
    
    // MARK: - Functions
    
    func cancleVoucher() {
        
        self.delegate?.didCancleVoucher!()
        self.parentNav?.popViewControllerAnimated(true)
        
    }
    
    func getVoucherList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        if reachability.isReachable() {
            
            self.loadVouchers()
        }
        else {
            self.showInternetUnreachable()
        }
        
        self.hud.hide(true)
        
    }
    
    
    
    func loadVouchers(indexPath:NSIndexPath? = nil) {
        
        // Copy to ensure the foodlist will never lost
        let voucherListCopy: NSMutableArray = NSMutableArray(array: self.voucherList)
        
        // Request for favorite list
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        if self.orderId == "" {
            
            Alamofire.request(VCheckGo.Router.GetMyVouchers(memberId, self.currentPage, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON ({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // Available City?
                            if json["paginated"]["total"].string! == "0" {
                                
                                // Load favorites list, if empty ..
                                let bgView: UIView = UIView()
                                bgView.frame = self.view.bounds
                                
                                let favoriteIcon: UIImageView = UIImageView.newAutoLayoutView()
                                favoriteIcon.alpha = 0.1
                                favoriteIcon.image = UIImage(named: VCAppLetor.IconName.GiftBlack)
                                bgView.addSubview(favoriteIcon)
                                
                                let favoriteEmptyLabel: UILabel = UILabel.newAutoLayoutView()
                                favoriteEmptyLabel.text = VCAppLetor.StringLine.FavoritesEmpty
                                favoriteEmptyLabel.font = VCAppLetor.Font.NormalFont
                                favoriteEmptyLabel.textColor = UIColor.lightGrayColor()
                                favoriteEmptyLabel.textAlignment = .Center
                                bgView.addSubview(favoriteEmptyLabel)
                                
                                self.tableView.backgroundView = bgView
                                
                                favoriteIcon.autoAlignAxisToSuperviewAxis(.Vertical)
                                favoriteIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
                                favoriteIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
                                
                                favoriteEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
                                favoriteEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: favoriteIcon, withOffset: 20.0)
                                favoriteEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
                                
                                self.tableView.stopRefreshAnimation()
                                
                                self.tableView.animation.makeAlpha(1.0).animate(0.4)
                                
                                return
                            }
                            
                            // Deal with paging
                            if json["paginated"]["more"].string! == "1" {
                                self.haveMore = true
                            }
                            else {
                                self.haveMore = false
                            }
                            
                            // Deal with the current page listing
                            
                            self.voucherList.removeAllObjects()
                            
                            let voucherList: Array = json["data"]["voucher_list"].arrayValue
                            
                            for item in voucherList {
                                
                                
                                let voucher: Voucher = Voucher(vid: item["voucher_member_id"].string!)
                                
                                voucher.title = item["voucher_name"].string!
                                voucher.desc = item["description"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                
                                voucher.startDate = dateFormatter.dateFromString(item["begin_date"].string!)!
                                voucher.endDate = dateFormatter.dateFromString(item["end_date"].string!)!
                                
                                voucher.status = item["voucher_status"].string!
                                voucher.price = item["discount"].string!
                                
                                voucher.limit = item["total"].string!
                                voucher.limitDesc = item["limit_description"].string!
                                
                                if !self.active {
                                    
                                    self.voucherList.addObject(voucher)
                                }
                                else {
                                    
                                    if voucher.status == "1" {
                                        self.voucherList.addObject(voucher)
                                    }
                                }
                                
                                
                                if voucher.status == "1" {
                                    self.validCount++
                                }
                                
                            }
                            
                            self.isLoading = false
                            
                            let validCountNumber = json["data"]["voucher_info"]["voucher_use_count"].string!
                            
                            self.headerView.frame = CGRectMake(0, 0, self.view.width, 50)
                            self.headerView.drawType = "voucherHeader"
                            self.headerView.withTitle = "\(validCountNumber)"
                            self.tableView.tableHeaderView = self.headerView
                            
                            self.hud.hide(true)
                            self.tableView.stopRefreshAnimation()
                            self.tableView.reloadData()
                            self.tableView.animation.makeAlpha(1.0).animate(0.4)
                        })
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                        self.hud.hide(true)
                        self.tableView.stopRefreshAnimation()
                        
                        // Restore FoodList
                        self.voucherList = voucherListCopy
                    }
                }
                else {
                    println("ERROR @ Get Favorites List Request: \(error?.localizedDescription)")
                    
                    // Restore FoodList
                    self.voucherList = voucherListCopy
                    
                    // Restore interface
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            })
            
        }
        else {
            
            Alamofire.request(VCheckGo.Router.GetMyVouchersWithOrderId(memberId, self.orderId, self.currentPage, VCAppLetor.ConstValue.DefaultListItemCountPerPage, token)).validate().responseSwiftyJSON ({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // Available City?
                            if json["paginated"]["total"].string! == "0" {
                                
                                // Load favorites list, if empty ..
                                let bgView: UIView = UIView()
                                bgView.frame = self.view.bounds
                                
                                let favoriteIcon: UIImageView = UIImageView.newAutoLayoutView()
                                favoriteIcon.alpha = 0.1
                                favoriteIcon.image = UIImage(named: VCAppLetor.IconName.GiftBlack)
                                bgView.addSubview(favoriteIcon)
                                
                                let favoriteEmptyLabel: UILabel = UILabel.newAutoLayoutView()
                                favoriteEmptyLabel.text = VCAppLetor.StringLine.FavoritesEmpty
                                favoriteEmptyLabel.font = VCAppLetor.Font.NormalFont
                                favoriteEmptyLabel.textColor = UIColor.lightGrayColor()
                                favoriteEmptyLabel.textAlignment = .Center
                                bgView.addSubview(favoriteEmptyLabel)
                                
                                self.tableView.backgroundView = bgView
                                
                                favoriteIcon.autoAlignAxisToSuperviewAxis(.Vertical)
                                favoriteIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
                                favoriteIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
                                
                                favoriteEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
                                favoriteEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: favoriteIcon, withOffset: 20.0)
                                favoriteEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
                                
                                self.tableView.stopRefreshAnimation()
                                
                                self.tableView.animation.makeAlpha(1.0).animate(0.4)
                                
                                return
                            }
                            
                            // Deal with paging
                            if json["paginated"]["more"].string! == "1" {
                                self.haveMore = true
                            }
                            else {
                                self.haveMore = false
                            }
                            
                            // Deal with the current page listing
                            
                            self.voucherList.removeAllObjects()
                            
                            let voucherList: Array = json["data"]["voucher_list"].arrayValue
                            
                            for item in voucherList {
                                
                                
                                let voucher: Voucher = Voucher(vid: item["voucher_member_id"].string!)
                                
                                voucher.title = item["voucher_name"].string!
                                voucher.desc = item["description"].string!
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                                
                                voucher.startDate = dateFormatter.dateFromString(item["begin_date"].string!)!
                                voucher.endDate = dateFormatter.dateFromString(item["end_date"].string!)!
                                
                                voucher.status = item["voucher_status"].string!
                                voucher.price = item["discount"].string!
                                
                                voucher.limit = item["total"].string!
                                voucher.limitDesc = item["limit_description"].string!
                                
                                if !self.active {
                                    
                                    self.voucherList.addObject(voucher)
                                }
                                else {
                                    
                                    if voucher.status == "1" {
                                        self.voucherList.addObject(voucher)
                                    }
                                }
                                
                                
                                if voucher.status == "1" {
                                    self.validCount++
                                }
                                
                            }
                            
                            self.isLoading = false
                            
                            let validCountNumber = json["data"]["voucher_info"]["voucher_use_count"].string!
                            
                            self.headerView.frame = CGRectMake(0, 0, self.view.width, 50)
                            self.headerView.drawType = "voucherHeader"
                            self.headerView.withTitle = "\(validCountNumber)"
                            self.tableView.tableHeaderView = self.headerView
                            
                            self.hud.hide(true)
                            self.tableView.stopRefreshAnimation()
                            self.tableView.reloadData()
                            self.tableView.animation.makeAlpha(1.0).animate(0.4)
                        })
                        
                    }
                    else {
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                        
                        self.hud.hide(true)
                        self.tableView.stopRefreshAnimation()
                        
                        // Restore FoodList
                        self.voucherList = voucherListCopy
                    }
                }
                else {
                    println("ERROR @ Get Favorites List Request: \(error?.localizedDescription)")
                    
                    // Restore FoodList
                    self.voucherList = voucherListCopy
                    
                    // Restore interface
                    self.hud.hide(true)
                    self.tableView.stopRefreshAnimation()
                    
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            })
            
        }
        
    }
    
    func insertRowsAtTop(newRows: NSMutableArray) {
        
        
        self.tableView.beginUpdates()
        
        for vou in newRows {
            
            let currentVouCount: Int = self.voucherList.count
            self.voucherList.addObject(vou)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        self.tableView.endUpdates()
    }
    
    func setupExchangeView() {
        
        self.maskView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.maskView.hidden = true
        self.view.addSubview(self.maskView)
        
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.addTarget(self, action: "dismiss")
        self.maskView.addGestureRecognizer(gesture)
        
        self.maskView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(62, 0, 0, 0))
        
        self.codeBar.backgroundColor = UIColor.whiteColor()
        self.maskView.addSubview(self.codeBar)
        
        self.codeBar.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0, 0, 0, 0), excludingEdge: .Bottom)
        self.codeBar.autoSetDimension(.Height, toSize: 70)
        
        self.code.font = VCAppLetor.Font.LightNormal
        self.code.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.code.placeholder = VCAppLetor.StringLine.ExchangeCode
        self.codeBar.addSubview(self.code)
        
        self.code.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10, 10, 10, 100))
        
        self.codeBtn.setTitle(VCAppLetor.StringLine.ExchangeTitle, forState: .Normal)
        self.codeBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.codeBtn.titleLabel?.font = VCAppLetor.Font.BigFont
        self.codeBtn.backgroundColor = UIColor.alizarinColor()
        self.codeBtn.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        self.codeBtn.addTarget(self, action: "exchange", forControlEvents: .TouchUpInside)
        self.codeBar.addSubview(self.codeBtn)
        
        self.codeBtn.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(15, self.view.width - 80, 15, 20))
        
    }
    
    func dismiss() {
        
        self.maskView.hidden = true
        self.code.resignFirstResponder()
    }
    
    func exchange() {
        
        let codeStr: String = self.code.text
        
        if codeStr != "" {
            
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            self.hud = MBProgressHUD.showHUDAddedTo(self.maskView, animated: true)
            self.hud.mode = MBProgressHUDMode.Indeterminate
            
            Alamofire.request(VCheckGo.Router.VoucherExchange(memberId, codeStr, token)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        
                        self.hud.hide(true)
                        self.code.resignFirstResponder()
                        
                        self.maskView.hidden = true
                        self.getVoucherList()
                        
                        let memberInfo = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optMemberInfo, namespace: "member")?.data as! MemberInfo
                        let deCount: Int = ("\(memberInfo.voucherValid!)" as NSString).integerValue + 1
                        memberInfo.voucherValid = "\(deCount)"
                        
                        CTMemCache.sharedInstance.set(VCAppLetor.SettingName.optMemberInfo, data: memberInfo, namespace: "member")
                        
                        self.delegate?.didFinishExchangeVoucher!()
                    }
                    else {
                        self.hud.hide(true)
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                }
                else {
                    self.hud.hide(true)
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
                
            })
            
            
            
        }
        else {
            RKDropdownAlert.title(VCAppLetor.StringLine.ExchangeCodeNeeded, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
        
        
    }
    
    func exchangeAction() {
        
        self.maskView.hidden = false
        self.code.becomeFirstResponder()
        
    }
    
    
    func setupExchangeBar() {
        
        let exchangeBar: UIView = UIView.newAutoLayoutView()
        exchangeBar.backgroundColor = UIColor.whiteColor()
        exchangeBar.layer.borderWidth = 1.0
        exchangeBar.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.6).CGColor
        self.view.addSubview(exchangeBar)
        
        exchangeBar.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0, -1, -1, -1), excludingEdge: .Top)
        exchangeBar.autoSetDimension(.Height, toSize: 50)
        
        let addIcon: UIImageView = UIImageView.newAutoLayoutView()
        addIcon.image = UIImage(named: VCAppLetor.IconName.AddBlack)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addIcon.tintColor = UIColor.goldColor()
        exchangeBar.addSubview(addIcon)
        
        addIcon.autoPinEdgeToSuperviewEdge(.Leading, withInset: self.view.width / 2 - 20)
        addIcon.autoAlignAxisToSuperviewAxis(.Horizontal)
        addIcon.autoSetDimensionsToSize(CGSizeMake(16, 16))
        
        let exchangeBtn: UIButton = UIButton.newAutoLayoutView()
        exchangeBtn.setTitle(VCAppLetor.StringLine.ExchangeTitle, forState: .Normal)
        exchangeBtn.setTitleColor(UIColor.goldColor(), forState: .Normal)
        exchangeBtn.backgroundColor = UIColor.clearColor()
        exchangeBtn.addTarget(self, action: "exchangeAction", forControlEvents: .TouchUpInside)
        exchangeBar.addSubview(exchangeBtn)
        
        exchangeBtn.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0, 20, 0, 0))
        
        
    }
    
    func showInternetUnreachable() {
        
        self.voucherList.removeAllObjects()
        self.tableView.reloadData()
        
        let bgView: UIView = UIView()
        bgView.frame = self.view.bounds
        
        let internetIcon: UIImageView = UIImageView.newAutoLayoutView()
        internetIcon.alpha = 0.1
        internetIcon.image = UIImage(named: VCAppLetor.IconName.InternetBlack)
        bgView.addSubview(internetIcon)
        
        let internetUnreachLabel: UILabel = UILabel.newAutoLayoutView()
        internetUnreachLabel.text = VCAppLetor.StringLine.InternetUnreachable
        internetUnreachLabel.font = VCAppLetor.Font.NormalFont
        internetUnreachLabel.textColor = UIColor.lightGrayColor()
        internetUnreachLabel.textAlignment = .Center
        bgView.addSubview(internetUnreachLabel)
        
        self.tableView.backgroundView = bgView
        //        self.tableView.scrollEnabled = false
        
        internetIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        internetIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
        internetIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
        
        internetUnreachLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
        internetUnreachLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: internetIcon, withOffset: 20.0)
        internetUnreachLabel.autoAlignAxisToSuperviewAxis(.Vertical)
    }
    
    
}
