//
//  Member.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/11.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreData

@objc(Member)
class Member: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var mid: String
    @NSManaged var phone: String
    @NSManaged var token: String
    @NSManaged var nickname: String
    @NSManaged var iconURL: String
    @NSManaged var lastLog: NSDate

}
