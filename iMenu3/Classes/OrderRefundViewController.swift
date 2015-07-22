//
//  OrderInfoViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/6/21.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import RKDropdownAlert
import MBProgressHUD
import DKChainableAnimationKit

protocol OrderRefundDelegate {
    func didSubmitRefundSuccess()
}

class OrderRefundViewController: VCBaseViewController, UIScrollViewDelegate {
    
    var foodInfo: FoodInfo!
    var orderInfo: OrderInfo!
    
    var delegate: OrderRefundDelegate?
    
    var parentNav: UINavigationController?
    
    var didSetupConstraints = false
    
    let scrollView: UIScrollView = UIScrollView()
    
    let foodImage: UIImageView = UIImageView.newAutoLayoutView()
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let foodUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let priceValue: UILabel = UILabel.newAutoLayoutView()
    
    
    let orderInfoTitle: UILabel = UILabel.newAutoLayoutView()
    let refundTips: UILabel = UILabel.newAutoLayoutView()
    let orderInfoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let orderNoValue: UILabel = UILabel.newAutoLayoutView()
    let orderDateValue: UILabel = UILabel.newAutoLayoutView()
    let orderAmountValue: UILabel = UILabel.newAutoLayoutView()
    let refundBtn: UIButton = UIButton.newAutoLayoutView()
    
    
    var reasons: NSMutableArray = NSMutableArray()
    var reasonsText: NSMutableArray = NSMutableArray()
    var bTextArr: NSMutableArray = NSMutableArray()
    var checkboxs: NSMutableArray = NSMutableArray()
    
    let reasonsUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    
    let noMoreView: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    var selectedReason: Int = 0
    
    var hud: MBProgressHUD!
    
    
    // MARK: - LifetimeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.OrderRefund
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        
        self.scrollView.frame = self.view.bounds
//        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.height = self.view.height - 62.0
        self.scrollView.originY = 62.0
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.alpha = 0.1
        
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        self.loadRefundList()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.scrollView.frame.size
        
        if self.didSetupConstraints {
            
            let height = self.noMoreView.originY + 60.0
            
            if height < self.scrollView.height {
                
                self.scrollView.contentSize.height += 1
            }
            else {
                self.scrollView.contentSize.height = self.noMoreView.originY + 80.0
            }
            
        }
        
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Functions
    func loadFoodInfo() {
        
        let foodId = (self.orderInfo.foodId! as NSString).integerValue
        
        Alamofire.request(VCheckGo.Router.GetProductDetail(foodId)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        let product: FoodInfo = FoodInfo(id: (json["data"]["article_info"]["article_id"].string! as NSString).integerValue)
                        
                        product.title = json["data"]["article_info"]["title"].string!
                        
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                        product.addDate = dateFormatter.dateFromString(json["data"]["article_info"]["article_date"].string!)!
                        
                        product.desc = json["data"]["article_info"]["summary"].string!
                        product.subTitle = json["data"]["article_info"]["sub_title"].string!
                        product.foodImage = json["data"]["article_info"]["article_image_list"][0]["image"]["source"].string!
                        product.status = json["data"]["article_info"]["menu_info"]["menu_status"]["menu_status_id"].string!
                        product.originalPrice = json["data"]["article_info"]["menu_info"]["price"]["original_price"].string!
                        product.price = json["data"]["article_info"]["menu_info"]["price"]["special_price"].string!
                        product.priceUnit = json["data"]["article_info"]["menu_info"]["price"]["price_unit"].string!
                        product.unit = json["data"]["article_info"]["menu_info"]["menu_unit"]["menu_unit"].string!
                        product.remainingCount = json["data"]["article_info"]["menu_info"]["stock"]["menu_count"].string!
                        product.remainingCountUnit = json["data"]["article_info"]["menu_info"]["stock"]["menu_unit"].string!
                        product.remainder = json["data"]["article_info"]["menu_info"]["remainder_time"].string!
                        product.outOfStock = json["data"]["article_info"]["menu_info"]["stock"]["out_of_stock_info"].string!
                        product.endDate = json["data"]["article_info"]["menu_info"]["end_date"].string!
                        product.returnable = "1"
                        
                        product.memberIcon = json["data"]["article_info"]["member_info"]["icon_image"]["thumb"].string!
                        
                        product.menuId = json["data"]["article_info"]["menu_info"]["menu_id"].string!
                        product.menuName = json["data"]["article_info"]["menu_info"]["menu_name"].string!
                        
                        product.storeId = json["data"]["article_info"]["store_info"]["store_id"].string!
                        product.storeName = json["data"]["article_info"]["store_info"]["store_name"].string!
                        product.address = json["data"]["article_info"]["store_info"]["address"].string!
                        product.longitude = (json["data"]["article_info"]["store_info"]["longitude_num"].string! as NSString).doubleValue
                        product.latitude = (json["data"]["article_info"]["store_info"]["latitude_num"].string! as NSString).doubleValue
                        product.tel1 = json["data"]["article_info"]["store_info"]["tel_1"].string!
                        product.tel2 = json["data"]["article_info"]["store_info"]["tel_2"].string!
                        product.acp = json["data"]["article_info"]["store_info"]["per"].string!
                        product.icon_thumb = json["data"]["article_info"]["store_info"]["icon_image"]["thumb"].string!
                        product.icon_source = json["data"]["article_info"]["store_info"]["icon_image"]["source"].string!
                        
                        // Info Part
                        let foodTips = json["data"]["article_info"]["article_tips_info"]["content"].arrayValue
                        
                        product.tips = NSMutableArray()
                        
                        for tip in foodTips {
                            
                            product.tips?.addObject(tip.string!)
                        }
                        
                        
                        self.foodInfo = product
                        
                        self.setupOrderView()
                        
                        self.hud.hide(true)
                        
                        self.updateOrderViewConstraints()
                        
                        
                        self.scrollView.animation.makeAlpha(1.0).animate(0.2)
                        
                    }
                    else {
                        self.hud.hide(true)
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                    
                }
                else {
                    self.hud.hide(true)
                    RKDropdownAlert.title(VCAppLetor.StringLine.InternetUnreachable, backgroundColor: VCAppLetor.Colors.error, textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    println("ERROR @ Request for foodInfo with order detail page : \(error?.localizedDescription)")
                }
                
            })
        })
        
    }
    
    func loadRefundList() {
        
        Alamofire.request(VCheckGo.Router.GetRefundReasons()).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    
                    let reasonList: Array = json["data"]["return_reason_list"].arrayValue
                    
                    for reason in reasonList {
                        
                        let reasonItem: NSDictionary = ["rid": reason["return_reason_id"].string!, "title": reason["return_reason_name"].string!]
                        self.reasons.addObject(reasonItem)
                        
                        let reasonCheckbox: ZFCheckbox = ZFCheckbox()
                        self.checkboxs.addObject(reasonCheckbox)
                        
                    }
                    
                    
                    self.setupOrderView()
                    
                    self.hud.hide(true)
                    
                    self.updateOrderViewConstraints()
                    
                    self.scrollView.animation.makeAlpha(1.0).animate(0.2)
                    
                }
                else {
                    
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            }
            else {
                
                println("ERROR @ Get refund reasons : \(error?.localizedDescription)")
            }
            
            
            
        })
        
        
        
    }
    
    
    func setupOrderView() {
        
        let imageURL = self.orderInfo.orderImageURL! as String
        
        Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
            
            (_, _, image, error) in
            
            if error == nil && image != nil {
                
                let foodImageResized: UIImage = Toucan.Resize.resizeImage(image!, size: CGSize(width: 120.0, height: 100.0), fitMode: Toucan.Resize.FitMode.Crop)
                
                self.foodImage.image = foodImageResized
            }
        }
        self.scrollView.addSubview(self.foodImage)
        
        
        self.foodTitle.text = self.orderInfo.menuTitle!
        self.foodTitle.textAlignment = .Left
        self.foodTitle.textColor = VCAppLetor.Colors.Title
        self.foodTitle.font = VCAppLetor.Font.NormalFont
        self.foodTitle.numberOfLines = 2
        self.foodTitle.sizeToFit()
        self.scrollView.addSubview(self.foodTitle)
        
        self.priceValue.text = "单价: " + round_price(self.orderInfo.pricePU!) + self.orderInfo.priceUnit!
        self.priceValue.textAlignment = .Left
        self.priceValue.textColor = VCAppLetor.Colors.Light
        self.priceValue.font = VCAppLetor.Font.SmallFont
        self.priceValue.sizeToFit()
        self.scrollView.addSubview(self.priceValue)
        
        
        self.orderAmountValue.text = "×" + self.orderInfo.itemCount!
        self.orderAmountValue.textAlignment = .Left
        self.orderAmountValue.textColor = VCAppLetor.Colors.Content
        self.orderAmountValue.font = VCAppLetor.Font.SmallFont
        self.orderAmountValue.sizeToFit()
        self.scrollView.addSubview(self.orderAmountValue)
        
        
        self.orderNoValue.text = self.orderInfo.no
        self.orderNoValue.textAlignment = .Right
        self.orderNoValue.textColor = VCAppLetor.Colors.Content
        self.orderNoValue.font = VCAppLetor.Font.NormalFont
        self.orderNoValue.sizeToFit()
        self.scrollView.addSubview(self.orderNoValue)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateFormatWithoutSeconds
        
        self.orderDateValue.text = dateFormatter.stringFromDate(self.orderInfo.createDate!)
        self.orderDateValue.textAlignment = .Right
        self.orderDateValue.textColor = VCAppLetor.Colors.Light
        self.orderDateValue.font = VCAppLetor.Font.SmallFont
        self.orderDateValue.sizeToFit()
        self.scrollView.addSubview(self.orderDateValue)
        
        
        self.foodUnderline.drawType = "GrayLine"
        self.foodUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.foodUnderline)
        
        
        self.orderInfoTitle.text = VCAppLetor.StringLine.RefundReason
        self.orderInfoTitle.textAlignment = .Left
        self.orderInfoTitle.textColor = VCAppLetor.Colors.Title
        self.orderInfoTitle.font = VCAppLetor.Font.XLarge
        self.scrollView.addSubview(self.orderInfoTitle)
        
        self.refundTips.text = VCAppLetor.StringLine.RefundTips
        self.refundTips.textAlignment = .Right
        self.refundTips.textColor = UIColor.lightGrayColor()
        self.refundTips.font = VCAppLetor.Font.SmallFont
        self.refundTips.sizeToFit()
        self.scrollView.addSubview(self.refundTips)
        
        
        self.orderInfoUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.orderInfoUnderline)
        
        for var i=0; i<self.reasons.count; i++ {
            
            (self.checkboxs[i] as! ZFCheckbox).animateDuration = 0.5
            (self.checkboxs[i] as! ZFCheckbox).lineWidth = 2
            (self.checkboxs[i] as! ZFCheckbox).selected = false
            (self.checkboxs[i] as! ZFCheckbox).tag = (self.reasons[i]["rid"] as! NSString).integerValue
            (self.checkboxs[i] as! ZFCheckbox).lineColor = UIColor.nephritisColor().colorWithAlphaComponent(0.6)
            (self.checkboxs[i] as! ZFCheckbox).lineBackgroundColor = UIColor.nephritisColor().colorWithAlphaComponent(0.8)
            (self.checkboxs[i] as! ZFCheckbox).backgroundColor = UIColor.whiteColor()
            (self.checkboxs[i] as! ZFCheckbox).addTarget(self, action: "selectControl:", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview((self.checkboxs[i] as! ZFCheckbox))
            
            
            let bText: UILabel = UILabel.newAutoLayoutView()
            bText.text = self.reasons[i]["title"] as? String
            bText.textAlignment = .Left
            bText.textColor = VCAppLetor.Colors.Content
            bText.font = VCAppLetor.Font.NormalFont
            self.scrollView.addSubview(bText)
            
            self.bTextArr.addObject(bText)
            
            let reasonText: UIButton = UIButton.newAutoLayoutView()
            reasonText.setTitle("", forState: .Normal)
            reasonText.layer.borderWidth = 0
            reasonText.backgroundColor = UIColor.clearColor()
            reasonText.tag = (self.reasons[i]["rid"] as! NSString).integerValue + 100
            reasonText.addTarget(self, action: "selectTitle:", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(reasonText)
            
            
            self.reasonsText.addObject(reasonText)
            
        }
        
        self.reasonsUnderline.drawType = "GrayLine"
        self.reasonsUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.reasonsUnderline)
        
        self.refundBtn.setTitle(VCAppLetor.StringLine.SubmitRefund, forState: .Normal)
        self.refundBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.refundBtn.addTarget(self, action: "submitRefundAction:", forControlEvents: .TouchUpInside)
        self.refundBtn.backgroundColor = UIColor.alizarinColor()
        self.refundBtn.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
        self.scrollView.addSubview(self.refundBtn)
        
        self.noMoreView.drawType = "noMore"
        self.noMoreView.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(self.noMoreView)
        
        
        self.view.addSubview(self.scrollView)
        
        
    }
    
    func selectTitle(btn: UIButton) {
        
        for item in self.checkboxs {
            item.setSelected(false, animated: false)
        }
        
        (self.scrollView.viewWithTag(btn.tag-100) as! ZFCheckbox).setSelected(true, animated: true)
        
        self.selectedReason = btn.tag-100
        
        
    }
    
    func selectControl(z: ZFCheckbox) {
        
        for item in self.checkboxs {
            item.setSelected(false, animated: false)
        }
        
        z.setSelected(true, animated: true)
        self.selectedReason = z.tag
        
        
    }
    
    
    func updateOrderViewConstraints() {
        
        if !self.didSetupConstraints {
            
            
            self.foodImage.autoPinEdgeToSuperviewEdge(.Top, withInset: 12.0)
            self.foodImage.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
            self.foodImage.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
            
            self.foodTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodImage, withOffset: 10.0)
            self.foodTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImage, withOffset: 10.0)
            
            self.priceValue.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.priceValue.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 8.0)
            
            self.orderAmountValue.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.priceValue, withOffset: 10.0)
            self.orderAmountValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.priceValue)
            
            self.orderNoValue.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.orderNoValue.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.priceValue, withOffset: 10.0)
            
            self.orderDateValue.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.orderDateValue.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderNoValue, withOffset: 8.0)
            
            
            self.foodUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
            self.foodUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImage, withOffset: 12.0)
            self.foodUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0, 3.0))
            
            
            self.orderInfoTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
            self.orderInfoTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.orderInfoTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodUnderline, withOffset: 30.0)
            self.orderInfoTitle.autoSetDimension(.Height, toSize: 30.0)
            
            self.refundTips.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.refundTips.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.orderInfoTitle)
            
            self.orderInfoUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
            self.orderInfoUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.orderInfoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoTitle, withOffset: 8.0)
            self.orderInfoUnderline.autoSetDimension(.Height, toSize: 5.0)
            
            for var i=0; i<self.reasons.count; i++ {
                
                let check = self.checkboxs[i] as! ZFCheckbox
                
                check.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.orderInfoUnderline)
                let space: CGFloat = 40.0*CGFloat(("\(i)" as NSString).floatValue)+10.0
                check.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoUnderline, withOffset: space)
                check.autoSetDimensionsToSize(CGSizeMake(26.0, 26.0))
                
                let bText = self.bTextArr[i] as! UILabel
                
                bText.autoPinEdge(.Leading, toEdge: .Trailing, ofView: check, withOffset: 20.0)
                bText.autoAlignAxis(.Horizontal, toSameAxisOfView: check)
                bText.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0-30.0, 18.0))
                
                
                let checkText = self.reasonsText[i] as! UIButton
                
                checkText.autoPinEdge(.Leading, toEdge: .Trailing, ofView: check, withOffset: 10.0)
                checkText.autoAlignAxis(.Horizontal, toSameAxisOfView: check)
                checkText.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0-30.0, 18.0))
                
                if i == self.reasons.count-1 {
                    
                    self.reasonsUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
                    self.reasonsUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: check, withOffset: 12.0)
                    self.reasonsUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0, 3.0))
                }
                
            }
            
            
            self.refundBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.reasonsUnderline, withOffset: 20.0)
            self.refundBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodUnderline)
            self.refundBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.refundBtn.autoSetDimension(.Height, toSize: 40.0)
            
            self.noMoreView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.refundBtn, withOffset: 20.0)
            self.noMoreView.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodUnderline)
            self.noMoreView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.noMoreView.autoSetDimension(.Height, toSize: 60.0)
            
            
            self.didSetupConstraints = true
        }
        
    }
    
    func submitRefundAction(btn: UIButton) {
        
        
        if self.selectedReason != 0 {
            
            let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
            let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
            
            Alamofire.request(VCheckGo.Router.SubmitRefund(memberId, self.orderInfo.id, self.selectedReason, token)).validate().responseSwiftyJSON({
                (_, _, JSON, error) -> Void in
                
                if error == nil {
                    
                    let json = JSON
                    
                    if json["status"]["succeed"].string! == "1" {
                        
                        self.delegate?.didSubmitRefundSuccess()
                        self.parentNav?.popViewControllerAnimated(true)
                    }
                    else {
                        
                        RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                    }
                    
                }
                else {
                    
                    println("ERROR @ Submit refund apply : \(error?.localizedDescription)")
                }
                
                
            })
            
        }
        else {
            
            RKDropdownAlert.title(VCAppLetor.StringLine.RefundTips, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        }
        
        
        
    }
    
    
}




