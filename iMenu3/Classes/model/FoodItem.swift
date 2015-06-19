//
//  FoodItem.swift
//  
//
//  Created by Gabriel Anthony on 15/6/19.
//
//

import Foundation
import CoreData

@objc(FoodItem)
class FoodItem: NSManagedObject {
    
    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var addDate: NSDate
    @NSManaged var desc: String
    @NSManaged var foodImage: String
    @NSManaged var status: String
    @NSManaged var originalPrice: String
    @NSManaged var price: String
    @NSManaged var unit: String
    @NSManaged var remainingCount: String
    @NSManaged var endDate: String
    @NSManaged var returnable: String
    @NSManaged var favoriteCount: String

}
