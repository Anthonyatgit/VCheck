//
//  Functions.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation

// Transform price string to formatted price string
func round_price(price: String) -> String {
    
    return "\(floor((price as NSString).floatValue))"
}

// Escape HTML String
func escape(html: String) -> String{
    var result = html.stringByReplacingOccurrencesOfString("&", withString: "&amp;", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString("\"", withString: "&quot;", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString("'", withString: "&#39;", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString("<", withString: "&lt;", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString(">", withString: "&gt;", options: nil, range: nil)
    return result
}