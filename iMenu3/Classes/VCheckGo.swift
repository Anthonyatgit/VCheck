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
        
        #if DEBUG
            static let baseAPIURLString = "http://218.244.158.175/imenu_test/app_interface_vcheck/index.php"
        #else
            static let baseAPIURLString = "http://www.imenu.so/imenu_test/app_interface_vcheck/index.php"
        #endif
        
        static let consumerKey = "yEUwUg5gPOtlymh2vFW1chwoTYJomgjWikzNva16"
        
        case AppSettings(String, DeviceType)                                // 01.基本-获取配置信息
        case MemberLogin(String, String, LoginType, String)                 // 02.会员-登录
        case MemberRegister(String, String, String)                         // 03.会员-注册
        case ResetPassword(String, String, LoginType, String)               // 04.会员-密码重置
        case LoginWithToken(String, String)                                 // 05.会员-记录登陆状态
        case MemberLogout(String, String)                                   // 06.会员-登出
        case ValidateMemberInfo(ValidateType, String)                       // 07.会员-校验会员信息
        case QuickLogin(String, String)                                     // 08.快速登陆
        case GetVerifyCode(String, String)                                  // 09.基本-获取验证码
        case EditMemberEmail(String, String, String)                        // 10.会员-编辑个人信息-Email
        case EditMemberNickname(String, String, String)                     // 10.会员-编辑个人信息-Nickname
        case EditMemberPassword(String, String, String, String)             // 10.会员-编辑个人信息-Password
        case GetMemberInfo(String, String)                                  // 12.会员-获取个人详情
        case FeedBack(String, String, String)                                       // 16.基本-提交反馈信息
        
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
                //=========QuickLogin================
                case .QuickLogin(let mobile, let code):
                    let params = ["route":"\(RoutePath.QuickLogin.rawValue)","token":"","jsonText":"{\"mobile\":\"\(mobile)\",\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.QuickLogin.rawValue)", params)
                //=========MemberRegister============
                case .MemberRegister(let mobile, let password, let code):
                    let params = ["route":"\(RoutePath.MemberRegister.rawValue)","token":"","jsonText":"{\"mobile\":\(mobile),\"password\":\"\(password)\",\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.MemberRegister.rawValue)", params)
                //=========ResetPassword=============
                case .ResetPassword(let mobile, let newPassword, let loginType, let code):
                    let params = ["route":"\(RoutePath.ResetPassword.rawValue)","token":"","jsonText":"{\"login_name\":\(mobile),\"new_password\":\"\(newPassword)\",\"login_type\":\"\(loginType.rawValue)\",\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.ResetPassword.rawValue)", params)
                //=========MemberLogin===============
                case .MemberLogin(let name, let password, let loginType, let code):
                    let params = ["route":"\(RoutePath.MemberLogin.rawValue)","token":"","jsonText":"{\"login_name\":\(name),\"password\":\"\(password)\",\"login_type\":\"\(loginType.rawValue)\",\"code\":\"\(code)\"}"]
                    return ("/\(RoutePath.MemberLogin.rawValue)", params)
                //=========GetMemberInfo=============
                case .GetMemberInfo(let token, let memberId):
                    let params = ["route":"\(RoutePath.GetMemberInfo.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\"}"]
                    return ("/\(RoutePath.GetMemberInfo.rawValue)", params)
                //=========EditMemberEmail===========
                case .EditMemberEmail(let memberId, let email, let token):
                    let params = ["route":"\(RoutePath.EditMemberInfo.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"email\":\"\(email)\"}"]
                    return ("/\(RoutePath.EditMemberInfo.rawValue)", params)
                    //=========EditMemberNickname===========
                case .EditMemberNickname(let memberId, let nickname, let token):
                    let params = ["route":"\(RoutePath.EditMemberInfo.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"member_name\":\"\(nickname)\"}"]
                    return ("/\(RoutePath.EditMemberInfo.rawValue)", params)
                    //=========EditMemberPassword===========
                case .EditMemberPassword(let memberId, let currentPass, let newPass, let token):
                    let params = ["route":"\(RoutePath.EditMemberInfo.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"old_password\":\"\(currentPass)\",\"password\":\"\(newPass)\"}"]
                    return ("/\(RoutePath.EditMemberInfo.rawValue)", params)
                //=========MemberLogout==============
                case .MemberLogout(let token, let memberId):
                    let params = ["route":"\(RoutePath.MemberLogout.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\"}"]
                    return ("/\(RoutePath.MemberLogout.rawValue)", params)
                //=========FeedBack==================
                case .FeedBack(let memberId, let token, let feedbackInfo):
                    let params = ["route":"\(RoutePath.FeedBack.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"feedback_content\":\"\(feedbackInfo)\"}"]
                    return ("/\(RoutePath.FeedBack.rawValue)", params)
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
    
    enum LoginType: Int {
        case Mobile = 1
        case Email = 2
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
        case MemberLogin = "member/member/login"
        case GetMemberInfo = "member/member/getMemberDetail"
        case MemberLogout = "member/member/logout"
        case ResetPassword = "member/member/resetPassword"
        case EditMemberInfo = "member/member/editMemberInfo"
        case QuickLogin = "member/member/quickLogin"
        case FeedBack = "base/feedback/submitFeedbackInfo"
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

class OrderInfo: NSObject {
    
    let order_id: String
    var order_title: String?
    var order_price: String?
    var order_amount: String?
    let order_total: String
    
    init(id: String, price: String) {
        
        self.order_id = id
        self.order_total = price
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






















