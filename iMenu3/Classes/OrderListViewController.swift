//
//  OrderListViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD

class OrderListViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate {
    
    var parentNav: UINavigationController?
    
    var orderList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    var hud: MBProgressHUD!
    
    // MARK - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.OrderTitle
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        // Setup tableView
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        
        // Register Cell View
        self.tableView.registerClass(FavoritesViewCell.self, forCellReuseIdentifier: "orderItemCell")
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120.0
        
        self.getOrderList()
        
        self.view.setNeedsUpdateConstraints()
        
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
        return self.orderList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:OrderListViewCell = self.tableView.dequeueReusableCellWithIdentifier("orderItemCell", forIndexPath: indexPath) as! OrderListViewCell
        
        cell.orderInfo = self.orderList[indexPath.row] as! OrderInfo
        cell.parentNav = self.parentNav
        cell.setupViews()
        
        cell.setNeedsUpdateConstraints()
        
        return cell
        
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var orderInfoVC: OrderInfoViewController = OrderInfoViewController()
        orderInfoVC.orderInfo = self.orderList[indexPath.row] as? OrderInfo
//        orderInfoVC.foodItem = self.foodItems[indexPath.row] as FoodItem
        orderInfoVC.parentNav = self.navigationController
        
        self.navigationController!.showViewController(orderInfoVC, sender: self)
        
    }
    
    // Override to support editing the table view
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        if editingStyle == .Delete {
//            
//            if(self.orderList.count > 0) {
//                
//                
//                let orderInfo: OrderInfo = self.orderList[indexPath.row] as OrderInfo
//                
//                if let orderToDelete = OrderItem.findFirst(attribute: "identifier", value: foodItem.identifier, contextType: BreezeContextType.Main) as? FoodItem {
//                    foodToDelete.deleteInContextOfType(BreezeContextType.Background)
//                }
//                
//                BreezeStore.saveInBackground({ contextType -> Void in
//                    
//                    },
//                    completion: { (error) -> Void in
//                        self.loadOrderList(indexPath: indexPath)
//                })
//                
//            }
//            
//        }
//        else if editingStyle == .Insert {
//            
//        }
//    }
    
    // MARK: - Functions
    
    func getOrderList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            self.loadOrderList()
            //            self.setupRefresh()
        }
        else {
            self.showInternetUnreachable()
        }
        
        self.hud.hide(true)
        
    }
    
    func setupRefresh() {
        
        self.tableView.addPullToRefreshActionHandler { () -> Void in
            
        }
        
        self.tableView.pullToRefreshView.borderColor = UIColor.nephritisColor()
        self.tableView.pullToRefreshView.imageIcon = UIImage(named: VCAppLetor.IconName.LoadingBlack)
    }
    
    
    func loadOrderList(indexPath:NSIndexPath? = nil) {
        
        
        self.orderList.removeAllObjects()
        
        // Load order list, if empty ..
        
        
        let bgView: UIView = UIView()
        bgView.frame = self.view.bounds
        
        let orderIcon: UIImageView = UIImageView.newAutoLayoutView()
        orderIcon.alpha = 0.1
        orderIcon.image = UIImage(named: VCAppLetor.IconName.OrderBlack)
        bgView.addSubview(orderIcon)
        
        let orderEmptyLabel: UILabel = UILabel.newAutoLayoutView()
        orderEmptyLabel.text = VCAppLetor.StringLine.OrderEmpty
        orderEmptyLabel.font = VCAppLetor.Font.NormalFont
        orderEmptyLabel.textColor = UIColor.lightGrayColor()
        orderEmptyLabel.textAlignment = .Center
        bgView.addSubview(orderEmptyLabel)
        
        self.tableView.backgroundView = bgView
        //        self.tableView.scrollEnabled = false
        
        orderIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        orderIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
        orderIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
        
        orderEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
        orderEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: orderIcon, withOffset: 20.0)
        orderEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        
        self.tableView.reloadData()
    }
    
    func showInternetUnreachable() {
        
        self.orderList.removeAllObjects()
        
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
        
        
        self.tableView.reloadData()
    }
    
    
}
