//
//  StringExt.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/25.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation

extension String {
    
    // MD5
    var md5 : String{
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen);
        
        CC_MD5(str!, strLen, result);
        
        var hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        result.destroy();
        
        return String(format: hash as String)
    }
    
    // Replace string in range of string 
    mutating func replaceRange(subRange: Range<Int>, with newValues: String) {
        let start = advance(self.startIndex, subRange.startIndex)
        let end = advance(self.startIndex, subRange.endIndex)
        replaceRange(start..<end, with: newValues)
    }
    
}