//
//  VCheckGo.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/4/30.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

struct VCheckGo {
    
    enum Router: URLRequestConvertible {
        
        static let baseAPIURLString = "http://218.244.158.175/imenu_test/app_interface_vcheck/index.php"
        static let consumerKey = "yEUwUg5gPOtlymh2vFW1chwoTYJomgjWikzNva16"
        
        case AppSettings(String, DeviceType)            // Get App Settings
        case LoginWithToken(String, String)             // Login With Token
        case GetVerifyCode(String, String)              // Get Verify Code
        case ValidateMemberInfo(ValidateType, String)   // Verify Member Info
        case MemberRegister(String, String, String)     // Member Register
        case GetMemberInfo(String, String)              // Get Member Info
        
        var URLRequest: NSURLRequest {
            
            let (path: String, parameters: [String: String]) = {
                
                
                switch self {
                //=========AppSettings================
                case .AppSettings(let version_ios, let deviceType):
                    let params = ["route":"\(RoutePath.GetClientConfig.rawValue)","token":"","jsonText": "{\"version_ios\":\(version_ios), \"device_type\":\"\(deviceType.rawValue)\"}"]
                    return ("/\(RoutePath.GetClientConfig.rawValue)", params)
                //=========LoginWithToken============
                case .LoginWithToken(let token, let mid):
                    let params = ["route":"\(RoutePath.LoginWithToken.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\(mid)}"]
                    return ("/\(RoutePath.LoginWithToken.rawValue)", params)
                //=========GetVerifyCode=============
                case .GetVerifyCode(let mobile, let code):
                    let params = ["route":"\(RoutePath.GetVerifyCode.rawValue)","token":"","jsonText":"{\"mobile\":\(mobile),\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.GetVerifyCode.rawValue)", params)
                //=========ValidateMemberInfo========
                case .ValidateMemberInfo(let validateType, let value):
                    let params = ["route":"\(RoutePath.ValidateMemberInfo.rawValue)","token":"","jsonText":"{\"validate_type\":\"\(validateType.rawValue)\",\"validate_value\":\(value)}"]
                    return ("/\(RoutePath.ValidateMemberInfo.rawValue)", params)
                //=========MemberRegister============
                case .MemberRegister(let mobile, let password, let code):
                    let params = ["route":"\(RoutePath.MemberRegister.rawValue)","token":"","jsonText":"{\"mobile\":\(mobile),\"password\":\"\(password)\",\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.MemberRegister.rawValue)", params)
                //=========GetMemberInfo=============
                case .GetMemberInfo(let token, let memberId):
                    let params = ["route":"\(RoutePath.GetMemberInfo.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\"}"]
                    return ("/\(RoutePath.GetMemberInfo.rawValue)", params)
                //=========DEFAULT===================
                default: return ("/",["consumer_key": Router.consumerKey])
                }
            }()
            
            
            let URL = NSURL(string: Router.baseAPIURLString)
            let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            URLRequest.HTTPMethod = "POST"
            
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
        
    }
    
    enum DeviceType: Int {
        case iPhone = 10
        case iPad = 11
        case Android = 20
    }
    
    enum ValidateType: Int {
        case Mobile = 1
        case Email = 2
        case Nickname = 3
    }
    
    // MARK: - InterfacePath 
    enum RoutePath: String {
        case GetClientConfig = "base/client_config/getClientConfig"
        case LoginWithToken = "member/member/loginWithToken"
        case GetVerifyCode = "base/tools/getVerifyCode"
        case ValidateMemberInfo = "member/member/validateMemberInfo"
        case MemberRegister = "member/member/register"
        case GetMemberInfo = "member/member/getMemberDetail"
    }
    
    enum ImageSize: Int {
        case Tiny = 1
        case Small = 2
        case Medium = 3
        case Large = 4
        case XLarge = 5
    }
    
    enum Category: Int, Printable {
        
        case Uncategoried = 0, Lunch, Dinner
        
        var description: String {
            get {
                switch self {
                case .Uncategoried: return "Uncategoried"
                case .Lunch: return "Lunch"
                case .Dinner: return "Dinner"
                default: return "Uncategoried"
                }
            }
        }
    }
    
}



class FoodInfo: NSObject {
    
    let id: Int
    let url: String
    
    var name: String?
    
    var favoritesCount: Int?
    var votesCount: Int?
    var commentsCount: Int?
    
    var category: VCheckGo.Category?
    var desc: String?
    
    init(id: Int, url: String) {
        self.id = id
        self.url = url
    }
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        
        self.id = representation.valueForKeyPath("photo.id") as! Int
        self.url = representation.valueForKeyPath("photo.image_url") as! String
        
        self.favoritesCount = representation.valueForKeyPath("photo.favorities_count") as? Int
        self.votesCount = representation.valueForKeyPath("photo.votes_count") as? Int
        self.commentsCount = representation.valueForKeyPath("photo.comments_count") as? Int
        self.name = representation.valueForKeyPath("photo.name") as? String
        self.desc = representation.valueForKeyPath("photo.description") as? String
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! FoodInfo).id == self.id
    }
    
    override var hash: Int {
        return (self as FoodInfo).id
    }
    

}

final class Comment {
    
    let userName: String
    let userAvatarURL: String
    let commentBody: String
    
    init(JSON: AnyObject) {
        
        userName = JSON.valueForKeyPath("user.fullname") as! String
        userAvatarURL = JSON.valueForKeyPath("user.userpic_url") as! String
        commentBody = JSON.valueForKeyPath("body") as! String
    }
    
    
    
    
    
}

extension Alamofire.Request {
    
    class func imageResponseSerializer() -> Serializer {
        
        return { request, response, data in
            
            if data == nil {
                return (nil, nil)
            }
            
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        
        return response(serializer: Request.imageResponseSerializer(), completionHandler: {
            (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
    
}

@objc public protocol ResponseObjectSerializable {
    init(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Alamofire.Request {
    
    public func responseObject<T: ResponseObjectSerializable>(completionHandler:(NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        
        let serializer: Serializer = { (request, response, data) in
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if response != nil && JSON != nil {
                return (T(response: response!, representation: JSON!), nil)
            }
            else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: {
            
            (request, response, object, error) in
            
            completionHandler(request, response, object as? T, error)
        })
    }
}

@objc public protocol ResponseCollectionSerializable {
    static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request {
    
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        
        let serializer: Serializer = { (request, response, data) in
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if response != nil && JSON != nil {
                return (T.collection(response: response!, representation: JSON!), nil)
            }
            else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: {
            
            (request, response, object, error) in
            
            completionHandler(request, response, object as? [T], error)
        })
    }
}

// MARK: - Request for Swift JSON

extension Alamofire.Request {
    
    public func responseSwiftyJSON(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void) -> Self {
        return responseSwiftyJSON(queue: nil, options: NSJSONReadingOptions.AllowFragments, completionHandler: completionHandler)
    }
    
    public func responseSwiftyJSON(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, JSON, NSError?) -> Void) -> Self {
        return response(queue: queue, serializer: Request.JSONResponseSerializer(options: options), completionHandler: {
            (request, response, object, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                var responseJSON: JSON
                if error != nil || object == nil {
                    responseJSON = JSON.nullJSON
                }
                else {
                    responseJSON = SwiftyJSON.JSON(object!)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(self.request, self.response, responseJSON, error)
                })
            })
        })
    }
}






















