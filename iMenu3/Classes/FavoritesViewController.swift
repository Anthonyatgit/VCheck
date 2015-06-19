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

class FavoritesViewController: VCBaseViewController, UITableViewDataSource, UITableViewDelegate, RKDropdownAlertDelegate {
    
    var parentNav: UINavigationController?
    
    var favoritesList: NSMutableArray = NSMutableArray()
    
    var tableView: UITableView!
    
    var hud: MBProgressHUD!
    
    
    // MARK - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare for interface
        self.title = VCAppLetor.StringLine.FavoritesTitle
        
        let closeView: UIView = UIView(frame: CGRectMake(6.0, 0.0, 32.0, 32.0))
        closeView.backgroundColor = UIColor.clearColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeView)
        
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
        self.tableView.registerClass(FavoritesViewCell.self, forCellReuseIdentifier: "favoritesItemCell")
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120.0
        
        self.getFavoritesList()
        
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
        return self.favoritesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FavoritesViewCell = self.tableView.dequeueReusableCellWithIdentifier("favoritesItemCell", forIndexPath: indexPath) as! FavoritesViewCell
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
        
    }
    
    // Override to control push with item selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //        var foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        //        foodViewerViewController.foodIdentifier = foodListItems[indexPath.row].identifier
        //        foodViewerViewController.foodItem = self.foodListItems[indexPath.row] as? FoodItem
        //        foodViewerViewController.parentNav = self.navigationController
        //
        //        self.navigationController!.showViewController(foodViewerViewController, sender: self)
        
    }
    
    // Override to support editing the table view
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if(self.favoritesList.count > 0) {
                
                
                let foodItem:FoodItem = self.favoritesList.objectAtIndex(indexPath.row) as! FoodItem
                
                if let foodToDelete = FoodItem.findFirst(attribute: "identifier", value: foodItem.identifier, contextType: BreezeContextType.Main) as? FoodItem {
                    foodToDelete.deleteInContextOfType(BreezeContextType.Background)
                }
                
                BreezeStore.saveInBackground({ contextType -> Void in
                    
                    },
                    completion: { (error) -> Void in
                        self.loadFavoritesList(indexPath: indexPath)
                })
                
            }
            
        }
        else if editingStyle == .Insert {
            
        }
    }
    
    // MARK: - Functions
    
    func getFavoritesList() {
        
        // Show hud
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Determinate
        self.hud.labelText = VCAppLetor.StringLine.isLoading
        
        if reachability.isReachable() {
            
            
            self.loadFavoritesList()
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
    
    
    func loadFavoritesList(indexPath:NSIndexPath? = nil) {
        
        let bgView: UIView = UIView()
        bgView.frame = self.view.bounds
        
        let favoriteIcon: UIImageView = UIImageView.newAutoLayoutView()
        favoriteIcon.alpha = 0.1
        favoriteIcon.image = UIImage(named: VCAppLetor.IconName.MailBlack)
        bgView.addSubview(favoriteIcon)
        
        let favoriteEmptyLabel: UILabel = UILabel.newAutoLayoutView()
        favoriteEmptyLabel.text = VCAppLetor.StringLine.FavoritesEmpty
        favoriteEmptyLabel.font = VCAppLetor.Font.NormalFont
        favoriteEmptyLabel.textColor = UIColor.lightGrayColor()
        favoriteEmptyLabel.textAlignment = .Center
        bgView.addSubview(favoriteEmptyLabel)
        
        self.tableView.backgroundView = bgView
//        self.tableView.scrollEnabled = false
        
        favoriteIcon.autoAlignAxisToSuperviewAxis(.Vertical)
        favoriteIcon.autoPinEdgeToSuperviewEdge(.Top, withInset: 160.0)
        favoriteIcon.autoSetDimensionsToSize(CGSizeMake(48.0, 48.0))
        
        favoriteEmptyLabel.autoSetDimensionsToSize(CGSizeMake(200.0, 20.0))
        favoriteEmptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: favoriteIcon, withOffset: 20.0)
        favoriteEmptyLabel.autoAlignAxisToSuperviewAxis(.Vertical)
    }
    
    func showInternetUnreachable() {
        
        self.favoritesList.removeAllObjects()
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
