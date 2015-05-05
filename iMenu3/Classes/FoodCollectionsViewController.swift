//
//  FoodCollectionsViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/29.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData

class FoodCollectionsViewController: UICollectionViewController {
    
    var parentNavigationController : UINavigationController?
    
    var foods: NSMutableArray = NSMutableArray()
    
    let reuseIdentifier = "itemCollectionViewCell"
    
    var titleArray : [String] = ["Relaxed", "Playful", "Happy", "Adventurous", "Wealthy", "Hungry", "Loved", "Active"]
    var foodImageArray : [String] = ["mood1.jpg", "mood2.jpg", "mood3.jpg", "mood4.jpg", "mood5.jpg", "mood6.jpg", "mood7.jpg", "mood8.jpg"]
    var iconArray : [String] = ["relax.png", "playful.png", "happy.png", "adventurous.png", "wealthy.png", "hungry.png", "loved.png", "active.png"]
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Life-cycle
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // Register collectionView cell
        collectionView?.registerClass(FoodCollectionsViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        // Setup refresh control
        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: "foodCollectionRefresh", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: FoodCollectionsViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FoodCollectionsViewCell
        
        cell.foodTitle.text = titleArray[indexPath.row]
        cell.foodImageView.image = UIImage(named: foodImageArray[indexPath.row])
        cell.iconImageView.image = UIImage(named: iconArray[indexPath.row])
        
        return cell
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    
    
}











