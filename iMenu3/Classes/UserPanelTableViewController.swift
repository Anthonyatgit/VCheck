//
//  UserPanelTableViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/4.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit

class UserPanelTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var userPanelDataSource: [String: [String]] = [
        
        "User"      : ["用户登录"],
        "Order"     : ["我的订单", "我喜欢的礼遇", "我的礼券", "分享赢取礼券"],
        "Settings"  : ["反馈", "关于"]
    ]
    
    var userPanelIcon: [String: [String]] = [
        "user"      : ["user"],
        "order"     : ["ticket", "gift", "cards", "like"],
        "settings"  : ["coffee", "image"]
    ]
    
    
    // MARK:  Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPanelTableView: UITableView = UITableView(frame: tableView.frame, style: UITableViewStyle.Grouped)
        tableView = userPanelTableView
        
        tableView.registerClass(UserPanelTableViewCell.classForCoder(), forCellReuseIdentifier: "UserPanelCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return userPanelDataSource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPanelDataSource.values.array[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserPanelTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserPanelCell", forIndexPath: indexPath) as! UserPanelTableViewCell
        
        let current = userPanelDataSource.values.array[indexPath.section][indexPath.row]
        cell.panelTitle.text = current
        let icon = userPanelIcon.values.array[indexPath.section][indexPath.row]
        cell.panelIcon.image = UIImage(named: icon)
        
        if (indexPath.section == 0) {
            cell.panelIcon.frame = CGRectMake(18.0, 20.0, 24.0, 24.0)
            cell.panelTitle.frame = CGRectMake(56.0, 20.0, 100.0, 20.0)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 70.0
        }
        else {
            return 50.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selected = userPanelDataSource.values.array[indexPath.section][indexPath.row]
        println("\(selected) selected")
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 20
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        if (section == 0) {
            view.frame = CGRectMake(0, 0, 320, 20)
        }
        else {
            view.frame = CGRectMake(0, 0, 320, 1)
        }
        
        return view
    }
    
}









