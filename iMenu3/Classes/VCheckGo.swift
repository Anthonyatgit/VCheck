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

struct VCheckGo {
    
    enum Router: URLRequestConvertible {
        
        static let baseAPIURLString = "https://api.500px.com/v1"
        static let consumerKey = "yEUwUg5gPOtlymh2vFW1chwoTYJomgjWikzNva16"
        
        case PopularFoods(Int)
        case FoodInfo(Int, ImageSize)
        
        var URLRequest: NSURLRequest {
            
            let (path: String, parameters: [String: AnyObject]) = {
                
                switch self {
                case .PopularFoods(let page):
                    let params = ["consumer_key": Router.consumerKey, "page": "\(page)", "feature": "popular", "rpp":  "10", "include_store": "store_download", "include_states": "votes"]
                    return ("/photos", params)
                case .FoodInfo(let id, let ImageSize):
                    let params = ["consumer_key": Router.consumerKey, "image_size": "\(ImageSize.rawValue)"]
                    return ("/photos/\(id)", params)
                default: return ("/",["consumer_key": Router.consumerKey])
                }
            }()
            
            let URL = NSURL(string: Router.baseAPIURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            
            let encoding = Alamofire.ParameterEncoding.URL
            
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
        
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






















