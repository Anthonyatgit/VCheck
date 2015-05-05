//
//  FoodItem.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/27.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreData

@objc(FoodItem)
class FoodItem: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var foodImage: String
    @NSManaged var desc: String
    @NSManaged var addDate: NSDate

}
