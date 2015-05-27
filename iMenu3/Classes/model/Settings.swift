//
//  Settings.swift
//  
//
//  Created by Gabriel Anthony on 15/5/19.
//
//

import Foundation
import CoreData

@objc(Settings)
class Settings: NSManagedObject {
    
    
    @NSManaged var sid: String
    @NSManaged var name: String
    @NSManaged var value: String
    @NSManaged var type: String
    @NSManaged var data: String

}
