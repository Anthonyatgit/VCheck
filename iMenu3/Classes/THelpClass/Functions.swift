//
//  Functions.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/23.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

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


// Push Device Token
func pushDeviceToken(deviceToken: String, type: VCheckGo.PushDeviceType) {
    
    let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
    let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
    
    Alamofire.request(VCheckGo.Router.PushDeviceToken(memberId, deviceToken, type, token)).validate().responseSwiftyJSON ({
        (_, _, JSON, error) -> Void in
        
        if error == nil {
            
            let json = JSON
            if json["status"]["succeed"].string! == "1" {
                
                // Push Done!
            }
            else {
                println("push device token error: " + json["status"]["error_desc"].string!)
            }
        }
        else {
            println("ERROR @ Request to push device token : \(error?.localizedDescription)")
        }
    })
}




