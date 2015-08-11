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

class OrderInfoViewController: VCBaseViewController, UIScrollViewDelegate, OrderRefundDelegate {
    
    var foodInfo: FoodInfo!
    var orderInfo: OrderInfo!
    
    var parentNav: UINavigationController?
    
    var didSetupConstraints = false
    
    let scrollView: UIScrollView = UIScrollView()
    
    let foodImage: UIImageView = UIImageView.newAutoLayoutView()
    let foodTitle: UILabel = UILabel.newAutoLayoutView()
    let foodUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let priceValue: UILabel = UILabel.newAutoLayoutView()
    let foodRightArrow: UIImageView = UIImageView.newAutoLayoutView()
    let foodBtn: UIButton = UIButton.newAutoLayoutView()
    
    let storeName: UILabel = UILabel.newAutoLayoutView()
    let storeNameUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let addressName: UILabel = UILabel.newAutoLayoutView()
    let addressValue: UILabel = UILabel.newAutoLayoutView()
    let addressUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let telName: UILabel = UILabel.newAutoLayoutView()
    let telValue: UILabel = UILabel.newAutoLayoutView()
    let callStoreBtn: UIButton = UIButton.newAutoLayoutView()
    let telUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let tipsTitle: UILabel = UILabel.newAutoLayoutView()
    let tipsUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    let tipsBlockWrap: UIView = UIView.newAutoLayoutView()
    let tipsBlock: TYAttributedLabel = TYAttributedLabel()
    let tipsEndUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    
    let orderInfoTitle: UILabel = UILabel.newAutoLayoutView()
    let orderInfoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let orderFinal: UILabel = UILabel.newAutoLayoutView()
    let orderDiscount: UILabel = UILabel.newAutoLayoutView()
    
    let orderNoName: UILabel = UILabel.newAutoLayoutView()
    let orderNoValue: UILabel = UILabel.newAutoLayoutView()
    let orderNoUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let orderMobileName: UILabel = UILabel.newAutoLayoutView()
    let orderMobileValue: UILabel = UILabel.newAutoLayoutView()
    let orderMobileUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let orderDateName: UILabel = UILabel.newAutoLayoutView()
    let orderDateValue: UILabel = UILabel.newAutoLayoutView()
    let orderDateUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let orderAmountName: UILabel = UILabel.newAutoLayoutView()
    let orderAmountValue: UILabel = UILabel.newAutoLayoutView()
    let orderAmountUnderline: CustomDrawView = CustomDrawView.newAutoLayoutView()
    
    let refundBtn: UIButton = UIButton.newAutoLayoutView()
    
    let payBarView: UIView = UIView.newAutoLayoutView()
    let payBg: UIView = UIView.newAutoLayoutView()
    let payBtn: UIButton = UIButton.newAutoLayoutView()
    let orderPriceName: UILabel = UILabel.newAutoLayoutView()
    let orderPriceValue: UILabel = UILabel.newAutoLayoutView()
    
    let discount: UILabel = UILabel.newAutoLayoutView()
    
    let deleteBtn: UIButton = UIButton.newAutoLayoutView()
    
    var hud: MBProgressHUD!
    
    var orderListVC: OrderListViewController?
    
    // MARK: - LifetimeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.OrderDetail
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Rewrite back bar button
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentMode = UIViewContentMode.Top
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.height = self.view.height - 62.0
        self.scrollView.originY = 62.0
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.alpha = 0.1
        
        if self.orderInfo.orderType == "10" {
            self.scrollView.height -= VCAppLetor.ConstValue.CheckNowBarHeight
        }
        
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        
        self.loadFoodInfo()
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.didSetupConstraints {
            
            if self.orderInfo.orderType == "21" || self.orderInfo.orderType == "52" {
                
                self.scrollView.contentSize.height = self.refundBtn.originY + 70.0
            }
            else {
                self.scrollView.contentSize.height = self.orderAmountUnderline.originY + 40.0
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
        self.scrollView.addSubview(self.priceValue)
        
        self.foodRightArrow.image = UIImage(named: VCAppLetor.IconName.RightDisclosureIcon)
        self.foodRightArrow.alpha = 0.4
        self.scrollView.addSubview(self.foodRightArrow)
        
        self.foodUnderline.drawType = "GrayLine"
        self.foodUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.foodUnderline)
        
        self.foodBtn.setTitle("", forState: .Normal)
        self.foodBtn.setTitleColor(UIColor.clearColor(), forState: .Normal)
        self.foodBtn.addTarget(self, action: "showFoodDetail:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.foodBtn)
        
        self.storeName.text = self.foodInfo.storeName!
        self.storeName.textAlignment = .Left
        self.storeName.textColor = VCAppLetor.Colors.Title
        self.storeName.font = VCAppLetor.Font.XLarge
        self.scrollView.addSubview(self.storeName)
        
        self.storeNameUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.storeNameUnderline)
        
        self.addressName.text = VCAppLetor.StringLine.addressName
        self.addressName.textAlignment = .Left
        self.addressName.textColor = VCAppLetor.Colors.Title
        self.addressName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.addressName)
        
        self.addressValue.text = self.foodInfo.address!
        self.addressValue.textAlignment = .Right
        self.addressValue.textColor = VCAppLetor.Colors.Content
        self.addressValue.font = VCAppLetor.Font.NormalFont
        self.addressValue.numberOfLines = 2
        self.addressValue.sizeToFit()
        self.scrollView.addSubview(self.addressValue)
        
        self.addressUnderline.drawType = "GrayLine"
        self.addressUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.addressUnderline)
        
        self.telName.text = VCAppLetor.StringLine.preorderTel
        self.telName.textAlignment = .Left
        self.telName.textColor = VCAppLetor.Colors.Title
        self.telName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.telName)
        
        self.telValue.text = self.foodInfo.tel1
        self.telValue.textAlignment = .Right
        self.telValue.textColor = VCAppLetor.Colors.Content
        self.telValue.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.telValue)
        
        self.telUnderline.drawType = "GrayLine"
        self.telUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.telUnderline)
        
        self.tipsTitle.text = VCAppLetor.StringLine.tipsRule
        self.tipsTitle.textAlignment = .Left
        self.tipsTitle.textColor = VCAppLetor.Colors.Title
        self.tipsTitle.font = VCAppLetor.Font.XLarge
        self.scrollView.addSubview(self.tipsTitle)
        
        self.tipsUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.tipsUnderline)
        
        self.tipsBlock.linesSpacing = 4
        self.tipsBlock.backgroundColor = UIColor.clearColor()
        self.tipsBlock.font = VCAppLetor.Font.NormalFont
        self.tipsBlock.textColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
        self.tipsBlock.textAlignment = CTTextAlignment.TextAlignmentLeft
        
        var tipString: String = ""
        
        for var i=0; i<self.foodInfo.tips!.count; i++ {
            
            tipString += "• \(self.foodInfo.tips!.objectAtIndex(i) as! String) \n"
        }
        
        self.tipsBlock.text = tipString
        self.tipsBlock.setFrameWithOrign(CGPointMake(0, 0), width: self.view.width-40.0)
        self.tipsBlockWrap.addSubview(self.tipsBlock)
        self.scrollView.addSubview(self.tipsBlockWrap)
        
        self.tipsEndUnderline.drawType = "GrayLine"
        self.tipsEndUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.tipsEndUnderline)
        
        self.orderInfoTitle.text = VCAppLetor.StringLine.OrderInformation
        self.orderInfoTitle.textAlignment = .Left
        self.orderInfoTitle.textColor = VCAppLetor.Colors.Title
        self.orderInfoTitle.font = VCAppLetor.Font.XLarge
        self.orderInfoTitle.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(self.orderInfoTitle)
        
        self.orderFinal.text = "支付: " + round_price(self.orderInfo.totalPrice!) + self.orderInfo.priceUnit!
        self.orderFinal.textAlignment = .Center
        self.orderFinal.textColor = UIColor.alizarinColor()
        self.orderFinal.font = VCAppLetor.Font.LightSmall
        self.orderFinal.sizeToFit()
        self.scrollView.addSubview(self.orderFinal)
        
        self.orderDiscount.text = "-" + round_price(self.orderInfo.voucherPrice!) + self.orderInfo.priceUnit!
        self.orderDiscount.textAlignment = .Center
        self.orderDiscount.textColor = UIColor.whiteColor()
        self.orderDiscount.font = VCAppLetor.Font.LightSmall
        self.orderDiscount.layer.cornerRadius = 2.0
        self.orderDiscount.layer.backgroundColor = UIColor.alizarinColor(alpha: 0.6).CGColor
        self.orderDiscount.sizeToFit()
        self.scrollView.addSubview(self.orderDiscount)
        
        self.orderInfoUnderline.drawType = "DoubleLine"
        self.scrollView.addSubview(self.orderInfoUnderline)
        
        self.orderNoName.text = VCAppLetor.StringLine.OrderNoName
        self.orderNoName.textAlignment = .Left
        self.orderNoName.textColor = VCAppLetor.Colors.Title
        self.orderNoName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.orderNoName)
        
        self.orderNoValue.text = self.orderInfo.no
        self.orderNoValue.textAlignment = .Right
        self.orderNoValue.textColor = VCAppLetor.Colors.Content
        self.orderNoValue.font = VCAppLetor.Font.NormalFont
        self.orderNoValue.sizeToFit()
        self.scrollView.addSubview(self.orderNoValue)
        
        self.orderNoUnderline.drawType = "GrayLine"
        self.orderNoUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderNoUnderline)
        
        self.orderMobileName.text = VCAppLetor.StringLine.OrderMobile
        self.orderMobileName.textAlignment = .Left
        self.orderMobileName.textColor = VCAppLetor.Colors.Title
        self.orderMobileName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.orderMobileName)
        
        self.orderMobileValue.text = self.orderInfo.createByMobile!
        self.orderMobileValue.textAlignment = .Right
        self.orderMobileValue.textColor = VCAppLetor.Colors.Content
        self.orderMobileValue.font = VCAppLetor.Font.NormalFont
        self.orderMobileValue.sizeToFit()
        self.scrollView.addSubview(self.orderMobileValue)
        
        self.orderMobileUnderline.drawType = "GrayLine"
        self.orderMobileUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderMobileUnderline)
        
        self.orderDateName.text = VCAppLetor.StringLine.OrderCreateDate
        self.orderDateName.textAlignment = .Left
        self.orderDateName.textColor = VCAppLetor.Colors.Title
        self.orderDateName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.orderDateName)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = VCAppLetor.ConstValue.DateFormatWithoutSeconds
        
        self.orderDateValue.text = dateFormatter.stringFromDate(self.orderInfo.createDate!)
        self.orderDateValue.textAlignment = .Right
        self.orderDateValue.textColor = VCAppLetor.Colors.Content
        self.orderDateValue.font = VCAppLetor.Font.NormalFont
        self.orderDateValue.sizeToFit()
        self.scrollView.addSubview(self.orderDateValue)
        
        self.orderDateUnderline.drawType = "GrayLine"
        self.orderDateUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderDateUnderline)
        
        self.orderAmountName.text = VCAppLetor.StringLine.OrderItemCount
        self.orderAmountName.textAlignment = .Left
        self.orderAmountName.textColor = VCAppLetor.Colors.Title
        self.orderAmountName.font = VCAppLetor.Font.NormalFont
        self.scrollView.addSubview(self.orderAmountName)
        
        self.orderAmountValue.text = self.orderInfo.itemCount!
        self.orderAmountValue.textAlignment = .Right
        self.orderAmountValue.textColor = VCAppLetor.Colors.Content
        self.orderAmountValue.font = VCAppLetor.Font.NormalFont
        self.orderAmountValue.sizeToFit()
        self.scrollView.addSubview(self.orderAmountValue)
        
        self.orderAmountUnderline.drawType = "GrayLine"
        self.orderAmountUnderline.lineWidth = VCAppLetor.ConstValue.GrayLineWidth
        self.scrollView.addSubview(self.orderAmountUnderline)
        
        if self.orderInfo.orderType == "21" || self.orderInfo.orderType == "52" {
            
            self.refundBtn.setTitle(VCAppLetor.StringLine.OrderRefund, forState: .Normal)
            self.refundBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.refundBtn.layer.cornerRadius = VCAppLetor.ConstValue.ButtonCornerRadius
            self.refundBtn.addTarget(self, action: "refundAction:", forControlEvents: .TouchUpInside)
            self.refundBtn.backgroundColor = UIColor.nephritisColor()
            self.scrollView.addSubview(self.refundBtn)
        }
        
        
        self.view.addSubview(self.scrollView)
        
        if self.orderInfo.orderType == "10" {
            self.setupPayBar()
        }
        
        if self.orderInfo.orderType == "31" || self.orderInfo.orderType == "32" {
            self.setupRefundView()
        }
        
    }
    
    func setupPayBar() {
        
        self.payBg.backgroundColor = UIColor.nephritisColor()
        self.payBarView.addSubview(self.payBg)
        
        self.payBtn.backgroundColor = UIColor.nephritisColor()
        self.payBtn.setTitle(VCAppLetor.StringLine.PayNow, forState: UIControlState.Normal)
        self.payBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.payBtn.layer.borderWidth = 1.0
        self.payBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.payBtn.addTarget(self, action: "payNowAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.payBarView.addSubview(self.payBtn)
        
        self.orderPriceName.text = VCAppLetor.StringLine.FinalOrderTotal
        self.orderPriceName.textAlignment = .Left
        self.orderPriceName.textColor = UIColor.orangeColor()
        self.orderPriceName.font = VCAppLetor.Font.SmallFont
        self.orderPriceName.sizeToFit()
        self.payBarView.addSubview(self.orderPriceName)
        
        self.orderPriceValue.text = round_price(self.orderInfo.totalPrice!) + self.orderInfo.priceUnit!
        self.orderPriceValue.textAlignment = .Center
        self.orderPriceValue.textColor = UIColor.orangeColor()
        self.orderPriceValue.font = VCAppLetor.Font.XLarge
        self.orderPriceValue.sizeToFit()
        self.payBarView.addSubview(self.orderPriceValue)
        
        if self.orderInfo.voucherPrice! != "" {
            
            self.discount.text = "-\(round_price(self.orderInfo.voucherPrice!))\(self.orderInfo.priceUnit!)"
            self.discount.textAlignment = .Left
            self.discount.textColor = UIColor.whiteColor()
            self.discount.font = VCAppLetor.Font.SmallFont
            self.discount.layer.backgroundColor = UIColor.alizarinColor(alpha: 0.6).CGColor
            self.discount.layer.cornerRadius = 2.0
            self.discount.sizeToFit()
            self.payBarView.addSubview(self.discount)
            
        }
        
        
        self.payBarView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
        
        let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
        topBorder.drawType = "GrayLine"
        topBorder.lineWidth = 1.0
        self.payBarView.addSubview(topBorder)
        
        topBorder.autoSetDimension(.Height, toSize: 1.0)
        topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
        
        self.view.addSubview(self.payBarView)
    }
    
    func setupRefundView() {
        
        let memberId = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optNameCurrentMid, namespace: "member")?.data as! String
        let token = CTMemCache.sharedInstance.get(VCAppLetor.SettingName.optToken, namespace: "token")?.data as! String
        
        Alamofire.request(VCheckGo.Router.GetRefundInfo(memberId, self.orderInfo.id, token)).validate().responseSwiftyJSON ({
            (_, _, JSON, error) -> Void in
            
            if error == nil {
                
                let json = JSON
                
                if json["status"]["succeed"].string! == "1" {
                    
                    let refundView: UIView = UIView.newAutoLayoutView()
                    refundView.backgroundColor = UIColor.cloudsColor(alpha: 0.4)
                    self.view.addSubview(refundView)
                    
                    let refundStatus: UILabel = UILabel.newAutoLayoutView()
                    refundStatus.font = VCAppLetor.Font.XLarge
                    refundStatus.textAlignment = .Left
                    refundStatus.sizeToFit()
                    refundView.addSubview(refundStatus)
                    
                    let refundingDate: UILabel = UILabel.newAutoLayoutView()
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = VCAppLetor.ConstValue.DefaultDateFormat
                    
                    let date: NSDate = dateFormatter.dateFromString(json["data"]["return_info"]["date_added"].string!)!
                    
                    var addDateFormatter = NSDateFormatter()
                    addDateFormatter.dateFormat = VCAppLetor.ConstValue.DateFormatWithoutSeconds
                    
                    refundingDate.text = VCAppLetor.StringLine.RefundingDateName + addDateFormatter.stringFromDate(date)
                    refundingDate.textAlignment = .Left
                    refundingDate.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                    refundingDate.font = VCAppLetor.Font.SmallFont
                    refundingDate.sizeToFit()
                    refundView.addSubview(refundingDate)
                    
                    let refundTips: UILabel = UILabel.newAutoLayoutView()
                    refundTips.textAlignment = .Right
                    refundTips.textColor = UIColor.lightGrayColor()
                    refundTips.font = VCAppLetor.Font.SmallFont
                    refundTips.sizeToFit()
                    refundView.addSubview(refundTips)
                    
                    if self.orderInfo.orderType == "31" {
                        
                        refundStatus.text = VCAppLetor.StringLine.RefundInProgress
                        refundStatus.textColor = UIColor.alizarinColor()
                        
                        refundTips.text = VCAppLetor.StringLine.RefundingTip
                    }
                    else if self.orderInfo.orderType == "32" {
                        
                        refundStatus.text = VCAppLetor.StringLine.RefundFinish
                        refundStatus.textColor = UIColor.nephritisColor()
                        
                        refundTips.text = VCAppLetor.StringLine.RefundedTip
                    }
                    
                    let refundActionText: UILabel = UILabel.newAutoLayoutView()
                    refundActionText.text = json["data"]["return_info"]["return_action_description"].string!
                    refundActionText.textAlignment = .Right
                    refundActionText.textColor = VCAppLetor.Colors.Content
                    refundActionText.font = VCAppLetor.Font.SmallFont
                    refundActionText.sizeToFit()
                    refundView.addSubview(refundActionText)
                    
                    refundView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Top)
                    refundView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
                    
                    refundStatus.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
                    refundStatus.autoPinEdgeToSuperviewEdge(.Top, withInset: 12.0)
                    
                    refundingDate.autoPinEdge(.Top, toEdge: .Bottom, ofView: refundStatus, withOffset: 10.0)
                    refundingDate.autoPinEdge(.Leading, toEdge: .Leading, ofView: refundStatus)
                    
                    refundActionText.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
                    refundActionText.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: refundStatus)
                    
                    refundTips.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: refundActionText)
                    refundTips.autoPinEdge(.Top, toEdge: .Bottom, ofView: refundActionText, withOffset: 10.0)
                    
                    
                    
                    let topBorder: CustomDrawView = CustomDrawView.newAutoLayoutView()
                    
                    if self.orderInfo.orderType == "31" {
                        
                        topBorder.drawType = "RedLine"
                    }
                    else if self.orderInfo.orderType == "32" {
                        
                        
                        topBorder.drawType = "GreenLine"
                    }
                    topBorder.lineWidth = 1.0
                    refundView.addSubview(topBorder)
                    
                    topBorder.autoSetDimension(.Height, toSize: 1.0)
                    topBorder.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Bottom)
                    
                    self.view.addSubview(refundView)
                    
                    self.refundBtn.removeFromSuperview()
                    
                    self.scrollView.height -= VCAppLetor.ConstValue.CheckNowBarHeight
                    
                }
                else {
                    
                    RKDropdownAlert.title(json["status"]["error_desc"].string!, backgroundColor: UIColor.alizarinColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
                }
                
            }
            else {
                
                println("ERROR @ Get Refund info : \(error?.localizedDescription)")
            }
            
        })
        
    }
    
    func updateOrderViewConstraints() {
        
        if !self.didSetupConstraints {
            
            
            self.foodImage.autoPinEdgeToSuperviewEdge(.Top, withInset: 12.0)
            self.foodImage.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
            self.foodImage.autoSetDimensionsToSize(CGSizeMake(120.0, 100.0))
            
            self.foodTitle.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.foodImage, withOffset: 10.0)
            self.foodTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImage, withOffset: 30.0)
            
            self.priceValue.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodTitle)
            self.priceValue.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodTitle, withOffset: 8.0)
            self.priceValue.autoSetDimensionsToSize(CGSizeMake(self.view.width-80-120, 16.0))
            
            self.foodUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
            self.foodUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodImage, withOffset: 12.0)
            self.foodUnderline.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0, 3.0))
            
            self.foodRightArrow.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.foodRightArrow.autoAlignAxis(.Horizontal, toSameAxisOfView: self.foodImage)
            self.foodRightArrow.autoSetDimensionsToSize(CGSizeMake(26.0, 26.0))
            
            self.foodBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodImage)
            self.foodBtn.autoPinEdge(.Top, toEdge: .Top, ofView: self.foodImage)
            self.foodBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodRightArrow)
            self.foodBtn.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.foodUnderline)
            
            self.storeName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.foodUnderline)
            self.storeName.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.foodUnderline)
            self.storeName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.foodUnderline, withOffset: 30.0)
            self.storeName.autoSetDimension(.Height, toSize: 30.0)
            
            self.storeNameUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.storeNameUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.storeNameUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storeName, withOffset: 6.0)
            self.storeNameUnderline.autoSetDimension(.Height, toSize: 5.0)
            
            self.addressName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.addressName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storeNameUnderline, withOffset: 10.0)
            self.addressName.autoSetDimensionsToSize(CGSizeMake(70.0, 18.0))
            
            self.addressValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.addressValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.addressName)
            
            self.addressUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.addressValue, withOffset: 10.0)
            self.addressUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.addressUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.addressUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.telName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.telName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.addressUnderline, withOffset: 10.0)
            self.telName.autoSetDimensionsToSize(CGSizeMake(70.0, 18.0))
            
            self.telValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.telValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.telName)
            
            self.telUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.telValue, withOffset: 10.0)
            self.telUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.telUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.telUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.tipsTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.telUnderline, withOffset: 30.0)
            self.tipsTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.tipsTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.tipsTitle.autoSetDimension(.Height, toSize: 30.0)
            
            self.tipsUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.tipsUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.tipsUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.tipsTitle, withOffset: 8.0)
            self.tipsUnderline.autoSetDimension(.Height, toSize: 5.0)
            
            self.tipsBlockWrap.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.tipsBlockWrap.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.tipsUnderline, withOffset: 10.0)
            self.tipsBlockWrap.autoSetDimensionsToSize(CGSizeMake(self.view.width-40.0, self.tipsBlock.height))
            
            self.tipsEndUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.tipsBlockWrap, withOffset: 10.0)
            self.tipsEndUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.tipsEndUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.tipsEndUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.orderInfoTitle.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderInfoTitle.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderInfoTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.tipsEndUnderline, withOffset: 30.0)
            self.orderInfoTitle.autoSetDimension(.Height, toSize: 30.0)
            
            if self.orderInfo.voucherPrice! != "" {
                
                self.orderDiscount.autoAlignAxis(.Horizontal, toSameAxisOfView: self.orderInfoTitle)
                self.orderDiscount.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
                
                self.orderFinal.autoAlignAxis(.Horizontal, toSameAxisOfView: self.orderInfoTitle)
                self.orderFinal.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderDiscount, withOffset: -10.0)
            }
            else {
                
                self.orderFinal.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.orderInfoTitle)
                self.orderFinal.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
                
            }
            
            self.orderInfoUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderInfoUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderInfoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoTitle, withOffset: 8.0)
            self.orderInfoUnderline.autoSetDimension(.Height, toSize: 5.0)
            
            self.orderNoName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderNoName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderInfoUnderline, withOffset: 10.0)
            self.orderNoName.autoSetDimensionsToSize(CGSizeMake(80.0, 18.0))
            
            self.orderNoValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderNoValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderNoName)
            
            self.orderNoUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderNoValue, withOffset: 10.0)
            self.orderNoUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderNoUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderNoUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.orderMobileName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderMobileName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderNoUnderline, withOffset: 10.0)
            self.orderMobileName.autoSetDimensionsToSize(CGSizeMake(80.0, 18.0))
            
            self.orderMobileValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderMobileValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderMobileName)
            
            self.orderMobileUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderMobileValue, withOffset: 10.0)
            self.orderMobileUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderMobileUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderMobileUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.orderDateName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderDateName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderMobileUnderline, withOffset: 10.0)
            self.orderDateName.autoSetDimensionsToSize(CGSizeMake(80.0, 18.0))
            
            self.orderDateValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderDateValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderDateName)
            
            self.orderDateUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderDateValue, withOffset: 10.0)
            self.orderDateUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderDateUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderDateUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            self.orderAmountName.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderAmountName.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderDateUnderline, withOffset: 10.0)
            self.orderAmountName.autoSetDimensionsToSize(CGSizeMake(80.0, 18.0))
            
            self.orderAmountValue.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderAmountValue.autoPinEdge(.Top, toEdge: .Top, ofView: self.orderAmountName)
            
            self.orderAmountUnderline.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderAmountValue, withOffset: 10.0)
            self.orderAmountUnderline.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
            self.orderAmountUnderline.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
            self.orderAmountUnderline.autoSetDimension(.Height, toSize: 3.0)
            
            
            if self.orderInfo.orderType == "21" || self.orderInfo.orderType == "52" {
                
                self.refundBtn.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.orderAmountUnderline, withOffset: 20.0)
                self.refundBtn.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.storeName)
                self.refundBtn.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.storeName)
                self.refundBtn.autoSetDimension(.Height, toSize: 40.0)
            }
            
            if self.orderInfo.orderType == "10" {
                
                self.payBarView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), excludingEdge: .Top)
                self.payBarView.autoSetDimension(.Height, toSize: VCAppLetor.ConstValue.CheckNowBarHeight)
                
                self.payBtn.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(10.0, 0.0, 10.0, 20.0), excludingEdge: .Leading)
                self.payBtn.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payBarView, withMultiplier: 0.4)
                
                self.payBg.autoPinEdge(.Leading, toEdge: .Leading, ofView: self.payBtn, withOffset: -1.0)
                self.payBg.autoPinEdge(.Top, toEdge: .Top, ofView: self.payBtn, withOffset: -1.0)
                self.payBg.autoMatchDimension(.Height, toDimension: .Height, ofView: self.payBtn, withOffset: 2.0)
                self.payBg.autoMatchDimension(.Width, toDimension: .Width, ofView: self.payBtn, withOffset: 2.0)
                
                self.orderPriceValue.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payBtn)
                self.orderPriceValue.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.payBtn, withOffset: -30.0)
                //        self.orderPriceValue.autoSetDimensionsToSize(CGSizeMake(54.0, 22.0))
                
                self.orderPriceName.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.orderPriceValue, withOffset: 0.0)
                self.orderPriceName.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.payBtn)
                self.orderPriceName.autoSetDimensionsToSize(CGSizeMake(62.0, 20.0))
                
                if self.orderInfo.voucherPrice! != "" {
                    
                    self.discount.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.orderPriceValue, withOffset: -8.0)
                    self.discount.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: self.orderPriceValue)
                    
                }
                else {
                    self.discount.hidden = true
                }
            }
            
            self.didSetupConstraints = true
        }
        
    }
    
    func showFoodDetail(btn: UIButton) {
        
        let foodViewerViewController: FoodViewerViewController = FoodViewerViewController()
        foodViewerViewController.foodInfo = self.foodInfo
        foodViewerViewController.parentNav = self.parentNav
        
        self.parentNav!.showViewController(foodViewerViewController, sender: self)
        
        
    }
    
    func payNowAction() {
        
        // Transfer to payment page
        let paymentVC: VCPayNowViewController = VCPayNowViewController()
        paymentVC.parentNav = self.parentNav
        paymentVC.foodDetailVC = self
        paymentVC.orderInfo = self.orderInfo
        self.parentNav?.showViewController(paymentVC, sender: self)
        
    }
    
    func refundAction(btn: UIButton) {
        
        let refundVC: OrderRefundViewController = OrderRefundViewController()
        refundVC.orderInfo = self.orderInfo
        refundVC.parentNav = self.parentNav
        refundVC.delegate = self
        self.parentNav?.showViewController(refundVC, sender: self)
        
        
    }
    
    // MARK: - OrderRefundDelegate
    func didSubmitRefundSuccess() {
        
        RKDropdownAlert.title(VCAppLetor.StringLine.RefundSucceed, backgroundColor: UIColor.nephritisColor(), textColor: UIColor.whiteColor(), time: VCAppLetor.ConstValue.TopAlertStayTime)
        
        self.orderInfo.orderType = "31"
        self.orderListVC?.shouldReload = true
        
        self.setupRefundView()
    }
    
    
}
