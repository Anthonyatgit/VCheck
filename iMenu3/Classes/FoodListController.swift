//
//  FoodListController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FoodListController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var foodListItems: NSMutableArray = NSMutableArray()
    
    var parentNavigationController : UINavigationController?
    
    let imageCache = NSCache()
    
    // MARK - Controller Life-time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(FoodListTableViewCell.classForCoder(), forCellReuseIdentifier: "foodItemCell")
        
        
        // Assign refresh control
        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor.grayColor()
        self.refreshControl = refresh
        self.refreshControl?.addTarget(self, action: "refreshFoodList", forControlEvents: .ValueChanged)
        
        loadFoodList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispoe of any resources that can be recreated
    }
    
    // MARK - Tableview data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        return foodListItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FoodListTableViewCell = tableView.dequeueReusableCellWithIdentifier("foodItemCell", forIndexPath: indexPath) as! FoodListTableViewCell
        
        //let foodDict:NSDictionary = foodListItems.objectAtIndex(indexPath.row) as! NSDictionary
        let foodItem: FoodItem = foodListItems.objectAtIndex(indexPath.row) as! FoodItem
        
        cell.identifier = foodItem.identifier
        cell.foodTitle.text = foodItem.title
        cell.foodDesc.text = foodItem.desc
        
        let imageURL = foodItem.foodImage
        let foodImageView = cell.foodImageView
        
        if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
            foodImageView.image = image
        }
        else {
            
            foodImageView.image = nil
            
            cell.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                
                (request, _, image, error) in
                
                if error == nil && image != nil {
                    let foodImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: self.view.bounds.width, height: 100.0), fitMode: Toucan.Resize.FitMode.Crop)
                    
                    self.imageCache.setObject(foodImage, forKey: request.URLString)
                    
                    if request.URLString == cell.request?.request.URLString {
                        foodImageView.image = foodImage
                    }
                    else {
                        // Resolve when the foodList has changed
                    }
                }
            }
        }
        
        return cell
        
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        println("Food: \(indexPath.row)")
//    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    // Override to control push with item selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodIdentifier = foodListItems[indexPath.row].identifier
        foodViewerViewController.title = "Food Detail"
        foodViewerViewController.view.backgroundColor = UIColor.whiteColor()
        
        parentNavigationController!.pushViewController(foodViewerViewController, animated: true)
        
    }
    
    // Override to support editing the table view
    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            if(self.foodListItems.count > 0) {
                
                let foodDict:NSDictionary = self.foodListItems.objectAtIndex(indexPath.row) as! NSDictionary
                let identifier:String = foodDict.objectForKey("identifier") as! String
                let predicate:NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")
                let foodToDelete:FoodItem = FoodItem.findFirst(predicate: predicate, sortedBy: nil, ascending: false, contextType: BreezeContextType.Background) as! FoodItem
                
                foodToDelete.deleteInContextOfType(BreezeContextType.Background)
                
                BreezeStore.saveInBackground({contextType -> Void in
                    
                    }, completion: {error -> Void in
                        self.loadFoodList(indexPath: indexPath)
                })
                
            }
            
        }
        else if editingStyle == .Insert {
            
        }
    }
    */
    
    // MARK - Functional blocks
    
    func refreshFoodList() {
        
        refreshControl?.beginRefreshing()
        
        loadFoodList()
        
        refreshControl?.endRefreshing()
    }
    
    func loadFoodList(indexPath:NSIndexPath? = nil) {
        
        foodListItems.removeAllObjects()
        
        let foodItems:NSArray = FoodItem.findAll(predicate: nil, sortedBy: "addDate", ascending: false, contextType: BreezeContextType.Background)
        
        if(foodItems.count > 0) {
            
            self.refreshControl?.beginRefreshing()
            
            for food in foodItems {
                
                let foodItem:FoodItem = food as! FoodItem
                
                
                //let dict:NSDictionary = ["identifier":foodItem.identifier, "title":foodItem.title, "desc":foodItem.desc, "addDate":foodItem.addDate, "foodImage":foodItem.foodImage]
                
                
                self.foodListItems.addObject(foodItem)
            }
        }
        
        if(self.refreshControl?.refreshing == true) {
            self.refreshControl?.endRefreshing()
        }
        
        if(indexPath != nil) {
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        self.tableView.reloadData()
        
        
    }
    
    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        println("segue call")
        
        println("\(sender)")
        
        if(segue.identifier == "viewFoodDetail") {
            (segue.destinationViewController as! FoodViewerViewController).foodIdentifier = sender?.identifier
        }
        
    }
    
    
}



