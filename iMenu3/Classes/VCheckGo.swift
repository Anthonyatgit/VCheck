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
        
        // API Base URL
        #if DEBUG
            static let baseAPIURLString = "http://218.244.158.175/imenu_test/app_interface_vcheck/index.php"
        #else
            static let baseAPIURLString = "http://www.imenu.so/imenu_test/app_interface_vcheck/index.php"
        #endif
        
        // Security Key
        static let consumerKey = "yEUwUg5gPOtlymh2vFW1chwoTYJomgjWikzNva16"
        
        // Route Method Defination
        case AppSettings(String, DeviceType)                                        // 01.基本-获取配置信息
        case MemberLogin(String, String, LoginType, String)                         // 02.会员-登录
        case MemberRegister(String, String, String)                                 // 03.会员-注册
        case ResetPassword(String, String, LoginType, String)                       // 04.会员-密码重置
        case LoginWithToken(String, String)                                         // 05.会员-记录登陆状态
        case MemberLogout(String, String)                                           // 06.会员-登出
        case ValidateMemberInfo(ValidateType, String)                               // 07.会员-校验会员信息
        case QuickLogin(String, String)                                             // 08.快速登陆
        case GetVerifyCode(String, String)                                          // 09.基本-获取验证码
        case EditMemberEmail(String, String, String)                                // 10.会员-编辑个人信息-Email
        case EditMemberNickname(String, String, String)                             // 10.会员-编辑个人信息-Nickname
        case EditMemberPassword(String, String, String, String)                     // 10.会员-编辑个人信息-Password
        case GetMemberInfo(String, String)                                          // 12.会员-获取个人详情
        case GetMyCollections(String, Int, Int, String)                             // 13.会员-获取我的收藏列表
        case EditMyCollection(String, CollectionEditType, String, String)           // 14.会员-编辑我的收藏列表
        case FeedBack(String, String, String)                                       // 16.基本-提交反馈信息
        case GetCityList()                                                          // 17.基本-获取地区列表
        case GetProductList(Int, Int)                                               // 18.产品-获取产品列表
        case GetProductDetail(Int)                                                  // 19.产品-获取产品详细
        case GetProductDetailWithMember(Int, String)                                // 19.产品-获取产品详情[用户模式]
        case GetOrderList(String, Int, Int, String)                                 // 26.会员-获取订单列表
        
        case EditCart(String, EditCartType, String, String, String, String)         // 38.订单-编辑购物车信息
        case ClearCart(String, String)                                              // 38.订单-清空购物车信息
        case AddOrder(String, String)                                               // 39.订单-提交订单
        case UpdatePay(String, VCAppLetor.PaymentCode, String, String)              // 40.订单-编辑结算信息
        case GetPayData(String, String, String)                                     // 41.订单-获取支付数据
        case AsyncPayment(String, String, String, String)                           // 42.订单-提交支付订单
        
        var URLRequest: NSURLRequest {
            
            let (path: String, parameters: [String: String]) = {
                
                
                switch self {
                //=========AppSettings================
                case .AppSettings(let version_ios, let deviceType):
                    let params = ["route":"\(RoutePath.GetClientConfig.rawValue)","token":"","jsonText": "{\"version_ios\":\"\(version_ios)\", \"device_type\":\"\(deviceType.rawValue)\"}"]
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
                case .GetCityList():
                    let params = ["route":"\(RoutePath.GetCityList.rawValue)","token":"","jsonText":""]
                    return ("/\(RoutePath.GetCityList.rawValue)", params)
                //=========GetProductList============
                case .GetProductList(let regionId, let pageNum):
                    let params = ["route":"\(RoutePath.GetProductList.rawValue)","token":"","jsonText":"{\"filter_info\":{\"region_id\":\"\(regionId)\"},\"pagination\":{\"page\":\"\(pageNum)\",\"count\":\"\(VCAppLetor.ConstValue.DefaultItemCountPerPage)\"}}"]
                    return ("/\(RoutePath.GetProductList.rawValue)", params)
                //=========GetProductDetail==========
                case .GetProductDetail(let productId):
                    let params = ["route":"\(RoutePath.GetProductDetail.rawValue)","token":"","jsonText":"{\"article_id\":\"\(productId)\"}"]
                    return ("/\(RoutePath.GetProductDetail.rawValue)", params)
                //=========GetProductDetailWithMember==========
                case .GetProductDetailWithMember(let productId, let memberId):
                    let params = ["route":"\(RoutePath.GetProductDetail.rawValue)","token":"","jsonText":"{\"article_id\":\"\(productId)\",\"member_id\":\"\(memberId)\"}"]
                    return ("/\(RoutePath.GetProductDetail.rawValue)", params)
                //=========GetOrderList==============
                case .GetOrderList(let memberId, let page, let count, let token):
                    let params = ["route":"\(RoutePath.GetOrderList.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"pagination\":{\"page\":\"\(page)\",\"count\":\"\(count)\"}}"]
                    return ("/\(RoutePath.GetOrderList.rawValue)", params)
                //=========GetMyCollections==========
                case .GetMyCollections(let memberId, let page, let count, let token):
                    let params = ["route":"\(RoutePath.GetMyCollection.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"pagination\":{\"page\":\"\(page)\",\"count\":\"\(count)\"}}"]
                    return ("/\(RoutePath.GetMyCollection.rawValue)", params)
                //=========EditMyCollecton===========
                case .EditMyCollection(let memberId, let collectionEditType, let articleId, let token):
                    let params = ["route":"\(RoutePath.EditMyCollection.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"operator_type\":\"\(collectionEditType.rawValue)\",\"article_list\":{\"article_id\":\"\(articleId)\"}}"]
                    return ("/\(RoutePath.EditMyCollection.rawValue)", params)
                //=========EditCart==================
                case .EditCart(let memberId, let editCartType, let menuId, let count, let articleId, let token):
                    let params = ["route":"\(RoutePath.EditCart.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"operator_type\":\"\(editCartType.rawValue)\",\"cart_info\":{\"menu_info\":{\"menu_id\":\"\(menuId)\",\"count\":\"\(count)\"},\"article_info\":{\"article_id\":\"\(articleId)\"}}}"]
                    return ("/\(RoutePath.EditCart.rawValue)", params)
                    //=========ClearCart==================
                case .ClearCart(let memberId, let token):
                    let params = ["route":"\(RoutePath.EditCart.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"operator_type\":\"\(EditCartType.clear.rawValue)\"}"]
                    return ("/\(RoutePath.EditCart.rawValue)", params)
                //=========AddOrder==================
                case .AddOrder(let memberId, let token):
                    let params = ["route":"\(RoutePath.AddOrder.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\"}"]
                    return ("/\(RoutePath.AddOrder.rawValue)", params)
                //=========UpdatePay=================
                case .UpdatePay(let memberId, let paymentCode, let orderId, let token):
                    let params = ["route":"\(RoutePath.UpdatePay.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"checkout_info\":{\"payment_code\":\"\(paymentCode.rawValue)\"},\"order_id\":\"\(orderId)\"}"]
                    return ("/\(RoutePath.UpdatePay.rawValue)", params)
                //=========GetPayData================
                case .GetPayData(let memberId, let orderId, let token):
                    let params = ["route":"\(RoutePath.GetPayData.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"order_id\":\"\(orderId)\"}"]
                    return ("/\(RoutePath.GetPayData.rawValue)", params)
                case .AsyncPayment(let memberId, let orderId, let paymentResult, let token):
                    let params = ["route":"\(RoutePath.AsyncPayment.rawValue)","token":"\(token)","jsonText":"{\"member_id\":\"\(memberId)\",\"order_id\":\"\(orderId)\",\"payment_result\":\"\(paymentResult)\"}"]
                    return ("/\(RoutePath.AsyncPayment.rawValue)", params)
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
    
    enum CollectionEditType: Int {
        case add = 1
        case remove = 2
        case clean = 3
    }
    
    enum EditCartType: Int {
        case edit = 1
        case clear = 2
    }
    
    enum PaymentCode: String {
        case Ali = "alipay"
        case Wechat = "weixin_pay"
    }
    
    // MARK: - InterfacePath 
    enum RoutePath: String {
        
        case GetClientConfig = "base/client_config/getClientConfig"
        case GetVerifyCode = "base/tools/getVerifyCode"
        case FeedBack = "base/feedback/submitFeedbackInfo"
        case GetCityList = "base/region/getRegionList"
        
        case LoginWithToken = "member/member/loginWithToken"
        case ValidateMemberInfo = "member/member/validateMemberInfo"
        case MemberRegister = "member/member/register"
        case MemberLogin = "member/member/login"
        case GetMemberInfo = "member/member/getMemberDetail"
        case MemberLogout = "member/member/logout"
        case ResetPassword = "member/member/resetPassword"
        case EditMemberInfo = "member/member/editMemberInfo"
        case QuickLogin = "member/member/quickLogin"
        case EditMyCollection = "member/collection/editCollectionProduct"
        case GetMyCollection = "member/collection/getCollectionProductList"
        
        case GetProductList = "product/product/getProductList"
        case GetProductDetail = "product/product/getProductDetail"
        
        case EditCart = "sale/order/editCart"
        case AddOrder = "sale/order/addOrder"
        case UpdatePay = "sale/order/checkout"
        case GetPayData = "sale/order/generatePayData"
        case AsyncPayment = "sale/order/submitPayOrder"
        
        case GetOrderList = "sale/order/getOrderList"
        
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


class CityInfo: NSObject {
    
    let city_id: String
    var parent_id: String?
    let city_name: String
    var sort_order: Int?
    var allias_name: String?
    var level: String?
    var open_status: String?
    
    init(cid: String, name: String) {
        
        self.city_id = cid
        self.city_name = name
    }
    
}

class OrderInfo: NSObject {
    
    let id: String
    let no: String
    
    // Base
    var title: String?
    var pricePU: String?
    var priceUnit: String?
    var totalPrice: String?
    var originalTotalPrice: String?
    var createDate: NSDate?
    var orderType: String?
    var menuId: String?
    var menuTitle: String?
    var menuUnit: String?
    var itemCount: String?
    var couponInfo: NSMutableArray?
    
    // Extent
    var status: VCAppLetor.OrderType?
    var typeDescription: String?
    var orderImageURL: String?
    
    init(id: String, no: String) {
        
        self.id = id
        self.no = no
    }
    
}



class FoodInfo: NSObject {
    
    let id: Int
    
    var title: String?
    var addDate: NSDate?
    
    // FOOD
    var desc: String?
    var subTitle: String?
    var foodImage: String?
    var status: String?
    var originalPrice: String?
    var price: String?
    var priceUnit: String?
    var unit: String?
    var remainingCount: String?
    var remainingCountUnit: String?
    var outOfStock: String?
    var endDate: String?
    var remainder: String?
    var returnable: String?
    var favoriteCount: String?
    var isCollected: String?
    
    // VM
    var memberIcon: String?
    
    // STORE
    var storeId: String?
    var storeName: String?
    var address: String?
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var tel1: String?
    var tel2: String?
    var acp: String?
    var icon_thumb: String?
    var icon_source: String?
    
    // MENU
    var menuId: String?
    var menuName: String?
    
    // CONTENT
    var contentImages: NSMutableArray?
    var contentTitles: NSMutableArray?
    var contentDesc: NSMutableArray?
    var menuTitles: NSMutableArray?
    var menuContents: NSMutableArray?
    var tips: NSMutableArray?
    var slideImages: NSMutableArray?
    
    
    init(id: Int) {
    
        self.id = id
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! FoodInfo).id == self.id
    }
    
    override var hash: Int {
        return (self as FoodInfo).id
    }
    
}

class FavInfo: NSObject {
    
    let id: Int
    
    var title: String?
    var addDate: NSDate?
    
    // FOOD
    var desc: String?
    var subTitle: String?
    var foodImage: String?
    var status: String?
    var originalPrice: String?
    var price: String?
    var priceUnit: String?
    var unit: String?
    var remainingCount: String?
    var remainingCountUnit: String?
    var outOfStock: String?
    var endDate: String?
    var remainder: String?
    var returnable: String?
    var favoriteCount: String?
    var isCollected: String?
    
    // VM
    var memberIcon: String?
    
    // STORE
    var storeId: String?
    var storeName: String?
    var address: String?
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var tel1: String?
    var tel2: String?
    var acp: String?
    var icon_thumb: String?
    var icon_source: String?
    
    // MENU
    var menuId: String?
    var menuName: String?
    
    // CONTENT
    var contentImages: NSMutableArray?
    var contentTitles: NSMutableArray?
    var contentDesc: NSMutableArray?
    var menuTitles: NSMutableArray?
    var menuContents: NSMutableArray?
    var tips: NSMutableArray?
    var slideImages: NSMutableArray?
    
    
    init(id: Int) {
        
        self.id = id
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! FoodInfo).id == self.id
    }
    
    override var hash: Int {
        return (self as FavInfo).id
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






















