//
//  VCAppViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/29.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PageMenu

class VCAppViewController: UIViewController, CAPSPageMenuDelegate {
    
    var pageMenu: CAPSPageMenu?
    
    var foodsController: FoodListController?
    
    // MARK - Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment to display an Edit butotn in the navigation bar for this view controller
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFood")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "userPanel")
        
        self.title = "VCheck"
        //self.navigationController?.hidesBarsOnSwipe = true
        
        //MARK: - Scroll Menu Setup
        var controllerArray: [UIViewController] = []
        
        var foodListController: FoodListController = FoodListController()
        foodListController.parentNavigationController = self.navigationController
        foodListController.title = VCheckGo.Category.Lunch.description
        self.foodsController = foodListController
        controllerArray.append(foodListController)
        
        
        // Using a standard UICollectionViewFlowLayout to dislay 2 cells in each cell
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 1) / 2
        layout.itemSize = CGSizeMake(itemWidth, itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        //        layout.footerReferenceSize = CGSizeMake(collectionView?.bounds.width, 50.0)
        
        var foodCollectionController: FoodCollectionsViewController = FoodCollectionsViewController(collectionViewLayout: layout)
        foodCollectionController.parentNavigationController = self.navigationController
        foodCollectionController.title = VCheckGo.Category.Dinner.description
        controllerArray.append(foodCollectionController)
        
        // Customize menu (Optional)
        var parameters: [String: AnyObject] = [
            "scrollMenuBackgroundColor": UIColor.whiteColor(),
            "selectedMenuItemLabelColor": UIColor.orangeColor(),
            "viewBackgroundColor": UIColor.whiteColor(),
            "selectionIndicatorColor": UIColor.orangeColor(),
            "bottomMenuHairlineColor": UIColor.grayColor(),
            "menuItemFont": UIFont(name: "HelveticaNeue", size: 14.0)!,
            "menuHeight": 40.0,
            "menuItemWidth": 90.0,
            "centerMenuItems": true
        ]
        
        let viewFrame: CGRect = CGRectMake(0.0, 64.0, self.view.frame.width, self.view.frame.height - 64.0)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: viewFrame, options: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func addFood() {
        
        let foodIdentifier = "\(NSDate())"
        
        BreezeStore.saveInBackground({ contextType -> Void in
            
            let foodItem = FoodItem.createInContextOfType(contextType) as! FoodItem
            foodItem.identifier = foodIdentifier
            foodItem.title = "Food-\(foodIdentifier)"
            foodItem.desc = "Food Description Block with text and html content\nThis is the second line with link <a href='#'>website</a>"
            foodItem.addDate = NSDate()
            
            let serNumber = arc4random_uniform(7)
            
            let foodImageURL: String = "http://www.siyo.cc/t/mood\(serNumber + 1).jpg"
            foodItem.foodImage = foodImageURL
            
            }, completion: { error -> Void in
                
                if (error != nil) {
                    println("\(error?.localizedDescription)")
                }
                else {
                    self.insertRowAtTop(foodIdentifier)
                }
        })
        
    }
    
    func userPanel() {
        
        let memberPanel: UserPanelViewController = UserPanelViewController()
        memberPanel.parentNav = self.navigationController
        self.navigationController?.showViewController(memberPanel, sender: self)
    }
    
    // Add new FoodItem
    func insertRowAtTop(identifier: String) {
        
        let foodItem: FoodItem = FoodItem.findFirst(attribute: "identifier", value: identifier, contextType: BreezeContextType.Background) as! FoodItem
        
        self.foodsController?.tableView.beginUpdates()
        
//        let dict:NSDictionary = ["identifier":foodItem.identifier, "title":foodItem.title, "desc":foodItem.desc, "addDate":foodItem.addDate, "foodImage":foodItem.foodImage]
        
        self.foodsController?.foodListItems.insertObject(foodItem, atIndex: 0)
        self.foodsController?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
        self.foodsController?.tableView.endUpdates()
        
    }
    
    
    
}










