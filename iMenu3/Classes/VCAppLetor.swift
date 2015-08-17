//
//  VCAppLetor.swift
//  iMenu3
//  
//  Global const value difination
//
//  Created by Gabriel Anthony on 15/4/29.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

struct VCAppLetor {
    
    // MARK: - SettingType
    enum SettingType {
        static let AppConfig: String = "appConfig"
        static let MemberInfo: String = "memberInfo"
    }
    
    // MARK: - Font
    enum Font {
        
        // FONT
        static let XSmall: UIFont = UIFont(name: "HelveticaNeue", size: 10.0)!
        static let SmallFont: UIFont = UIFont(name: "HelveticaNeue", size: 12.0)!
        static let NormalFont: UIFont = UIFont(name: "HelveticaNeue", size: 14.0)!
        static let BigFont: UIFont = UIFont(name: "HelveticaNeue", size: 16.0)!
        static let XLarge: UIFont = UIFont(name: "HelveticaNeue", size: 18.0)!
        static let XXLarge: UIFont = UIFont(name: "HelveticaNeue", size: 22.0)!
//        static let XXXLarge: UIFont = UIFont(name: "HelveticaNeue", size: 28.0)!
        static let XXXLarge: UIFont = UIFont.boldSystemFontOfSize(28.0)
        static let boldLarge: UIFont = UIFont.boldSystemFontOfSize(18.0)
        
        
        static let LightNormal: UIFont = UIFont(name: "HelveticaNeue-Light", size: 18.0)!
        static let XXLight: UIFont = UIFont(name: "HelveticaNeue-Light", size: 22.0)!
        static let UltraLight: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 18.0)!
        static let UltraLightSmall: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 12.0)!
        static let Light: UIFont = UIFont(name: "HelveticaNeue-Light", size: 18.0)!
        static let LightSmall: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        static let LightXSmall: UIFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        static let LightXXSmall: UIFont = UIFont(name: "HelveticaNeue-Light", size: 10.0)!
        static let XXXXUltraLight: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 48.0)!
        static let XXXUltraLight: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 42.0)!
    }
    
    // MARK: - StringLing
    // Const String Defination
    enum StringLine {
        
        // MEMBER LOGIN
        static let AppName: String = "TASTE"
        static let AppNameZh: String = "知味"
        static let AppScheme: String = "vcheck"
        static let SaltKey: String = "siyo_vcheck"
        static let isLoading: String = "努力加载中.."
        static let InternetUnreachable: String = "网络好像不给力啊"
        static let UpdateNowButtonTitle: String = "立即更新"
        static let UpdateNoticeTitle: String = "更新提示"
        static let UpdateDescription: String = "有最新的可用版本，建议升级应用保持内容为最新"
        static let UserPanelTitle: String = "我的账户"
        static let SettingsTitle: String = "偏好设置"
        static let LoginPageTitle: String = "登陆"
        static let RegPageTitle: String = "注册"
        static let UserInfoWithoutSignin: String = "登陆/注册享丰富礼券"
        static let LoginTitle: String = "使用VCheck账号登陆，赢取丰富礼券"
        static let LoginName: String = "手机号/邮箱"
        static let LoginPass: String = "密码"
        static let LoginNameEmpty: String = "手机号/邮箱忘记填写了？"
        static let LoginNameIllegal: String = "手机号/邮箱填写格式不对，检查一下"
        static let MobileIllegal: String = "手机号码填写格式不对，检查一下"
        static let MobileNotExist: String = "手机号码不存在，检查一下"
        static let LoginPassEmpty: String = "密码忘记填写了？"
        static let LoginInfoError: String = "手机号/邮箱或者密码是不是写错了？"
        static let SignUpText: String = "新用户也有专享福利，"
        static let SignUpButtonText: String = "点击注册"
        static let SocialSignUpTitle: String = "使用社交账号登陆"
        static let MobileCannotEmpty: String = "请填写您的手机号码来接收验证码"
        static let VerifyCodeSendDone: String = "验证码发送成功"
        static let VerifyCodeSendFail: String = "验证码发送失败，请稍后重试"
        static let VerifyCodePlease: String = "请填写您手机收到的6位验证码进行注册"
        static let VerifyCodeWrong: String = "您填写的验证码不正确，请检查输入或重新获取验证码"
        static let LoginFail: String = "邮箱/手机号码或密码错误，请再试一次"
        static let VerifyCodeInProgress: String = "正在发送..."
        static let RegisterInProgress: String = "正在注册..."
        static let Done: String = "确定"
        static let Send: String = "发送"
        static let Gotit: String = "我知道了"
        static let FindBackMyPassTitle: String = "找回密码"
        static let SMSCode: String = "验证码"
        static let InputSMSCode: String = "请输入验证码"
        static let ResetYourPasscode: String = "重置密码"
        static let Next: String = "下一步"
        static let Preview: String = "上一步"
        static let Resent: String = "重新发送"
        static let NewPasscode: String = "新密码"
        static let AgainPasscode: String = "再输一次"
        static let PassNotMatch: String = "密码输入不匹配，应当为6-20位数字或字母"
        static let PasscodeTooShort: String = "密码应当为6-20位数字或字母"
        static let ResetPassDone: String = "密码设置成功，现在可以登录了"
        static let PhoneNumber: String = "手机号码"
        static let SendAutoCode: String = "发送验证码"
        static let InventCodeOption: String = "邀请码(选填)"
        static let NoInventCodeYet: String = "还没有邀请码？没关系，以后还可以补填"
        static let AgreeTermsString: String = "点击下一步，代表理解并同意 VCheck 的用户协议"
        static let UserTerms: String = "用户协议"
        static let TermsURL: String = "http://218.244.158.175/static/vcheck/userterms.html"
        static let InitPasscode: String = "请设置您的登陆密码"
        static let BlackUserIconURL: String = "http://218.244.158.175/siyocc/t/account_circle_black.png"
        static let NotSetYet: String = "未设置"
        static let PassCodeString = "••••••"
        static let NotAuthYet: String = "未绑定"
        static let DoAuthed: String = "已绑定"
        static let RequireMobileString: String = "通过你的手机号获取验证码"
        static let ResendVerifyCodePlease: String = "请重新获取验证码"
        static let UserInfoSettings: String = "账户设置"
        static let BindMobile: String = "用户验证"
        static let EditMemberEmail: String = "修改邮箱"
        static let EmailIllegal: String = "邮箱地址格式不正确"
        static let EditEmailSuccess: String = "邮箱修改成功"
        static let EditMemberNickname: String = "修改昵称"
        static let NicknameTooShort: String = "昵称应当为2-20位字符"
        static let EditNicknameSuccess: String = "昵称修改成功"
        static let EditMemberPassowrd: String = "修改密码"
        static let CurrentPass: String = "当前密码"
        static let NewPass: String = "新密码"
        static let NewPassAgain: String = "再输一遍新密码"
        static let newpassNotMatch: String = "密码输入不匹配，应当为6-20位数字或字母"
        static let PasswordTooShort: String = "密码应当为6-20位数字或字母"
        static let EditPasswordSuccess: String = "密码修改成功"
        static let MobileCannotChange: String = "手机号码绑定后不能修改[联系客服]"
        static let Logout: String = "退出登录"
        static let ServiceTel: String = "联系客户服务"
        static let FreeServiceCall: String = "4008 369 917"
        static let FeedBackTitle: String = "反馈意见"
        static let FeedBackPlaceholder: String = "请在这里写下对知味App的感受，我们将不断努力为你做的更好~"
        static let ContactInfo: String = "联系方式"
        static let ContactPlaceHolder: String = "邮箱，微信，QQ，手机皆可"
        static let FeedbackTextEmpty: String = "给我们写点什么吧"
        static let FeedbackSucceed: String = "我们已经收悉你的反馈信息，我们会努力为你做的更好~"
        static let NoMore: String = "・知味・"
        static let LSIsEnabled: String = "已开启"
        static let LSIsDisabled: String = "未开启"
        static let LocationServiceDisabled: String = "定位服务未开启"
        static let EnableLS: String = "请在 系统设置>隐私>定位服务中 开启定位服务让知味为你提供美食地图"
        static let LocationServiceNotAuth: String = "定位服务未授权"
        static let EnableLSForApp: String = "请在 系统设置>隐私>定位服务中 设置，允许知味访问你的地理位置"
        static let ServiceCityTitle: String = "选择服务的城市"
        static let ServiceCityNote: String = "我们正在努力为更多城市提供服务"
        static let CityName: String = "城市"
        static let Locating: String = "定位"
        static let Cancle: String = "取消"
        static let StoreLocation: String = "商家位置"
        static let OpenSoon: String = "[即将开通]"
        
        static let Weibo: String = "新浪微博"
        static let Wechat: String = "微信好友"
        static let Friends: String = "朋友圈"
        
        static let DefaultShareContent: String = "知味Taste最精致的餐品和就餐体验，即刻获取30元礼券!邀请码"
        static let ShareSucceed: String = "分享成功"
        static let ShareFailed: String = "分享失败"
        static let ShareCancledByUser: String = "用户取消了分享"
        static let ShareTips: String = "邀请越多好友，获得越多金券奖励!"
        static let Rewards1: String = "当好友使用你的邀请码注册，可获得50元礼券"
        static let Rewards2: String = "当好友完成首单消费，你还可以获得50元礼券"
        
        
        static let MailboxTitle: String = "信息中心"
        static let MailboxEmpty: String = "暂无消息"
        static let MyMail: String  = "我的消息"
        static let InviteFriend: String = "邀请好友"
        
        static let OrderTitle: String = "我的订单"
        static let OrderEmpty: String = "你还没有任何订单"
        static let OrderDetail: String = "订单详情"
        static let OrderInformation: String = "订单信息"
        static let OrderExCodeTitle: String = "消费码"
        static let OrderNoName: String = "订单编号"
        static let OrderMobile: String = "下单手机号"
        static let OrderCreateDate: String = "下单时间"
        static let OrderItemCount: String = "购买数量"
        static let OrderRefund: String = "申请退款"
        static let RefundReason: String = "退款原因"
        static let RefundTips: String = "选一项帮助我们快速为您退款"
        static let SubmitRefund: String = "提交申请"
        static let RefundSucceed: String = "申请退款成功,您的款项将在3-10个工作日内退回"
        static let RefundInProgress: String = "退款处理中"
        static let RefundFinish: String = "退款成功"
        static let RefundingTip: String = "预计3个工作日内完成"
        static let RefundingDateName: String = "申请: "
        static let RefundedDateName: String = "退款时间: "
        static let RefundedTip: String = "您的款项已经退回"
        
        static let FavoritesTitle: String = "我喜欢的礼遇"
        static let FavoritesEmpty: String = "你还没有喜欢的礼遇"
        static let FavOnSale: String = "售卖中"
        static let FavOffSale: String = "已结束"
        
        static let VoucherTitle: String = "我的礼券"
        static let VoucherAvailable: String = "张可用礼券"
        static let ExchangeTitle: String = "兑换"
        static let ExchangeCode: String = "兑换码或邀请码"
        static let ExchangeCodeNeeded: String = "请输入兑换码或邀请码"
        static let CancleVoucher: String = "不使用"
        
        static let FoodViewerTitle: String = "礼遇详情"
        static let ShareToGetCoupon: String = "分享获取礼券"
        static let CheckNow: String = "立即购买"
        static let SegmentTitles: [AnyObject] = ["亮点","菜单","须知"]
        static let HaveOrderWaitForPay: String = "你已经预定了此商品，可以立即支付"
        static let BackToPay: String = "此商品已经存在订单，请返回商品页面直接支付"
        static let isClose: String = "已结束"
        
        static let CheckNowTitle: String = "填写订单"
        static let CheckNowTip: String = "请注意，该礼遇需要到店享用"
        static let PayNowTip: String = "该礼遇支持随时申请退款"
        static let PayDoneTip: String = "向服务商家出示你的订单号码享受您的礼遇"
        static let PriceName: String = "价格"
        static let PricePU: String = "单价: "
        static let AmountName: String = "数量"
        static let TotalPriceName: String = "合计"
        static let MobilePlease: String = "请正确输入手机号"
        static let InputVerifyCode: String = "请输入验证码"
        static let MobileName: String = "手机号码"
        static let LoginWithCoupon: String = "填写你收到的验证码即刻开始知味之旅"
        static let LoginNow: String = "立即登录"
        static let OrderPriceName: String = "合计: "
        static let SubmitBtnTitle: String = "提交订单"
        static let SubmitOrderInProgress: String = "正在提交您的订单"
        static let AsyncPaymentInProgress: String = "正在同步交易信息"
        static let PaymentSucceed: String = "支付已经完成"
        static let UserCanclePayment: String = "你取消了支付，如你的支付遇到问题请联系客服 [4008 369 917]"
        static let UserAuthFail: String = "你的身份认证失败，支付已取消，请重试"
        static let PaymentNetworkError: String = "支付已取消，你的网络好像不给力，请重新支付"
        static let PaymentFailed: String = "支付失败，请重新支付你的订单"
        
        static let PayOrderTitle: String = "确认订单"
        static let UseCouponName: String = "使用礼券"
        static let CouponNone: String = "未使用"
        static let FinalOrderTotal: String = "还需支付"
        static let ChoosePayType: String = "选择支付方式"
        static let QuestionWithPay: String = "支付遇到问题?"
        static let AlipayType: String = "支付宝"
        static let AlipaySubtitle: String = "推荐支付宝用户使用"
        static let WechatType: String = "微信支付"
        static let WechatSubtitle: String = "推荐微信5.0以上用户使用"
        static let PayNow: String = "立即支付"
        
        static let PaymentDoneTitle: String = "购买成功"
        static let PaymentSuccessString: String = "购买成功，感谢您的惠顾"
        static let OrderProductName: String = "礼遇名称:"
        static let OrderNumber: String = "订单号码:"
        static let CheckOrderTitle: String = "查看我的订单"
        static let BackToGo: String = "继续浏览"
        static let UnFinishOrder: String = "你有未完成的订单，可以在我的订单中查看"
        
        static let AboutTitle: String = "关于我们"
        static let AppSubtitle: String = "• 精 选 限 量 美 食 •"
        static let AppWebsiteURL: String = "http://taste.imenu.so"
        static let AppCopyRight: String = "Copyright © 2015 Siyo Tech All Rights Reserved"
        
        static let SkipLaunchImage: String = "SKIP >"
        
        static let FoodTitle: String = "[title]"
        static let FoodDesc: String = "[desc]"
        
        static let rateName: String = "好评率:"
        static let addressName: String = "地址:"
        static let contectTelName: String = "联系餐厅:"
        static let preorderTel: String = "预约电话:"
        static let tipsName: String = "温馨提示"
        static let tipsRule: String = "使用规则"
        static let wechatServiceName: String = "• 点击这里联系"
        static let wechatServiceTitle: String = "微信客服 •"
        
        static let LocationUserFail: String = "获取位置信息失败"
        static let YourCityNotInService: String = "您的城市目前还未开通服务"
        
        static let OneImageOnly: String = "你只能选择一张图片作为头像"
        static let AvatarUploadError: String = "头像上传失败"
        
        static let ClearImageCache: String = "确定清除图片缓存？"
        static let NotificationOptionsTitle: String = "推送设置"
        static let AllowNotificationTitle: String = "接收推送"
        
        static let AppStoreUnreachable: String = "App Store无法打开，请稍后再试"
    }
    
    enum City: String {
        
        case Xian = "西安市"
        case Shanghai = "上海市"
    }
    
    enum FoodInfo {
        
    }
    
    // MARK: - Colors
    enum Colors {
        static let error: UIColor = UIColor.alizarinColor()
        static let done: UIColor = UIColor.nephritisColor()
        static let Action: UIColor = UIColor.pumpkinColor()
        static let HighLight: UIColor = UIColor.orangeColor()
        static let Title: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        static let Label: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        static let Content: UIColor = UIColor.grayColor()
        static let Light: UIColor = UIColor.lightGrayColor()
        static let exLight: UIColor = UIColor.exLightGrayColor()
    }
    
    // MARK: - IconName
    enum IconName {
        
        static let LoadingBlack: String = "refresh_black"
        static let RefreshBlack: String = "refresh_black"
        
        static let UserInfoIconWithoutSignin: String = "account_circle_black"
        static let RightDisclosureIcon: String = "right_black"
        static let ClearIconBlack: String = "clear_black"
        static let HelpIconBlack: String = "help_black"
        static let InternetBlack: String = "internet_black"
        static let ShareBlack: String = "share_black"
        static let ThumbUpBlack: String = "thumb_up_black"
        static let FavoriteBlack: String = "favorite_black"
        static let FavoriteRed: String = "favorite_red"
        static let PhotosBlack: String = "photos_black"
        static let telBlack: String = "call_black"
        static let moreBlack: String = "more_black"
        static let backBlack: String = "back_black"
        static let GiftBlack: String = "gift_black"
        static let SettingsBlack: String = "settings_black"
        static let AddBlack: String = "add_black"
        static let AlarmBlack: String = "alarm_black"
        static let VideoBlack: String = "video_black"
        
        static let PlaceBlack: String = "place_black"
        static let MemberBlack: String = "member_black"
        static let MailBlack: String = "mail_black"
        static let OrderBlack: String = "order_black"
        static let CouponBlack: String = "coupon_black"
        
        static let AlipayIcon: String = "ali_68.png"
        static let WechatIcon: String = "wx_logo_64.png"
        
        static let SuccessIcon: String = "success_black"
        
        static let AppAbout: String = "AppAbout"
    }
    
    // MARK: - ConstValue
    enum ConstValue {
        
        // Const value
        static let SMSRemainingSeconds: Int = 60 // 验证码倒计时总秒数
        static let PI: CGFloat = 3.14159265358979323846 // 圆周率
        static let TopAlertStayTime: Int = 3
        static let TopAlertStayTimeLong: Int = 6
        static let LineGap: CGFloat = 10.0
        static let GrayLineWidth: CGFloat = 0.6
        static let ToplineWithNavBar: CGFloat = 80.0
        static let TextFieldHeight: CGFloat = 30.0
        static let ButtonHeight: CGFloat = 33.0
        static let UnderlineHeight: CGFloat = 3.0
        static let UserIconCellHeight: CGFloat = 72.0
        static let UserPanelCellHeight: CGFloat = 50.0
        static let UserIconCellHeaderHeight: CGFloat = 20.0
        static let UserPanelCellHeaderHeight: CGFloat = 5.0
        static let UserPanelCellIconWidth: CGFloat = 24.0
        static let ButtonCornerRadius: CGFloat = 3.0
        static let ButtonBorderWidth: CGFloat = 1.0
        static let ImageCornerRadius: CGFloat = 3.0
        static let UserInfoSectionHeaderHight: CGFloat = 40.0 // 用户信息分区标题视图高度
        static let UserInfoHeaderViewHeight: CGFloat = 80.0 // 顶部用户信息视图高度
        static let UserInfoFooterViewHeight: CGFloat = 100.0 // 底部用户信息视图高度
        static let UserPanelFooterViewHeight: CGFloat = 120.0
        static let MinLengthOfPasscode: Int = 6 // 用户密码最小长度
        static let ReachableClosures: Bool = false
        static let TextFieldShakeTime: NSTimeInterval = 0.6
        static let CheckNowBarHeight: CGFloat = 60.0
        static let IconImageCornerRadius: CGFloat = 3.0
        static let FoodImageHeight: CGFloat = 230.0
        static let BannerImageHeight: CGFloat = 200.0
        static let FoodItemCellHeight: CGFloat = 320.0
        static let FavItemCellHeight: CGFloat = 122.0
        static let VoucherItemCellHeight: CGFloat = 156.0
        static let OrderItemCellHeight: CGFloat = 122.0
        static let StockAlertPoint: Int = 5
        
        static let VideoShowTime: NSTimeInterval = 14
        
        static let DefaultItemCountPerPage: Int = 5
        static let DefaultListItemCountPerPage: Int = 10
        static let DefaultDateFormat: String = "yyyy-MM-dd HH:mm:ss"
        static let DateFormatWithoutSeconds: String = "yyyy-MM-dd HH:mm"
        static let DateWithoutTimeFormat: String = "yyyy-MM-dd"
        
        static let LocationServiceDistanceFilter: Double = 1000.0
        static let DefaultCityCode: Int = 29
        
        static let AppStoreRateURL: String = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?mt=8&sortOrdering=1&type=Purple+Software&id="
    }
    
    enum PN {
        
        static let route: String = "PushNotificationRoute"
        static let param: String = "PushNotificationParam"
    }
    
    enum LINKS {
        
        static let route: String = "LinkRoute"
        static let param: String = "LinkParam"
    }
    
    enum INDEX {
        
        static let route: String = "IndexRoute"
        static let param: String = "IndexParam"
        static let pushType: String = "IndexPushType"
    }
    
    enum PNRoute: String {
        case web = "web"
        case home = "home"
        case article = "article"
        case member = "member_center"
        case message = "message_list"
        case orderList = "order_list"
        case orderDetail = "order_detail"
        case collectionList = "collection_list"
        case voucherList = "voucher_list"
    }
    
    enum ShareSDK {
        static let appKey: String = "7bcd1d7bc200"
        
        static let SinaAppKey: String = "4012589497"
        static let SinaAppSecret: String = "cad1412fd89be70722de86337a571a54"
        static let SinaRedirectURL: String = "http://192.168.100.100"
        
        static let WeChatAppKey: String = "wx79252ca0921c523d"
        static let WeChatAppSecret: String = "18099057b2e02b22e8fed322eb74fda7"
    }
    
    enum BMK {
        static let MapKey: String = "lwnYrg9Q209NsFD22Z7lTfrv"
    }
    
    enum XGPush {
        static let appID: UInt32 = 2200125218
        static let appKey: String = "IZ83TA36M5HW"
        
        static let pushOpen: String = "push_open"
        static let pushClose: String = "push_close"
    }
    
    // MARK: - SettingName
    enum SettingName {
        
        static let optMemberInfo: String = "member_info"
        
        static let optNameIsLogin: String = "isLogin"
        static let optNameLoginType: String = "loginType"
        static let optNameCurrentMid: String = "currentMid"
        static let optVersioniOS: String = "version_ios"
        static let optNeedUpdate: String = "need_update"
        static let optTipForUpdate: String = "is_tips"
        static let optToken: String = "token"
        
        static let optShareTag: String = "share_tag"
        
        static let payWechatTag: String = "pay_wechat"
        
        static let payOrderId: String = "pay_orderid"
        
        static let payAlipayTag: String = "pay_alipay"
        static let payAlipayResultString: String = "pay_alipay_resultstring"
        static let payAlipayResultStatus: String = "pay_alipay_resultstatus"
        
        static let optDeviceToken: String = "deviceToken"
        
        static let optMemberIcon: String = "member_icon"
        
        static let orderSessionMenuIds: String = "OrderSessionMenuIds"
        static let orderSessionOrderObjs: String = "OrderSessionOrderObjs"
        
        static let userDefaultPaymentType: String = "DefaultPaymentType"
        
        static let optSelectedCity: String = "SelectedCity"
        static let LocLong: String = "LocLong"
        static let LocLat: String = "LocLat"
        
        static let VideoTag: String = "VideoTag"
    }
    
    enum ObjectIns {
        static let objPayVC: String = "PaymentVC"
        static let objNavigation: String = "Navigation"
        static let objHome: String = "FoodListVC"
        static let objOrderList: String = "OrderList"
    }
    
    enum ShareTag {
        static let shareWechat: String = "ShareWechat"
        static let shareWeibo: String = "ShareWeibo"
    }
    
    // MARK: - LoginType
    enum LoginType {
        
        static let None: String = ""
        static let PhoneReg: String = "PhoneReg"
        static let Token: String = "Token"
        static let SinaWeibo: String = "SinaWeibo"
        static let WeChat: String = "WeChat"
        
    }
    
    enum BindType {
        
        static let Wechat: String = "Wechat"
        static let Weibo: String = "Weibo"
    }
    
    enum LoginStatus {
        
        static let WechatAuthUserInfo = "WechatAuthUserInfo"
        static let WechatLog = "WechatLogin"
        static let WechatReg = "WechatReg"
        static let WechatAvatar = "WechatAvatar"
        static let WechatNickname = "WechatNickname"
        static let WechatLogInfo = "WechatLogInfo"
        
        static let SinaWeiboAuthUserInfo = "SinaWeiboAuthUserInfo"
        static let SinaWeiboLog = "SinaWeiboLogin"
        static let SinaWeiboReg = "SinaWeiboReg"
        static let SinaAvatar = "SinaAvatar"
        static let SinaNickname = "SinaNickname"
        
    }
    
    // MARK: - Alert Notice title
    enum NoticeTitle {
        
        static let Success: String = "恭喜"
        static let Error: String = "错误"
        static let Notice: String = "提示"
    }
    
    enum ErrorCode {
        
        static let MobileAlreadyExist: String = "2013"
        
        static let TokenError: String = "2002"
    }
    
    // MARK: - UserPanel
    enum UserPanel {
        
        static let MyMenus: [String: [String]] = [
//            "User"      : ["登陆/注册享丰富礼券"],
            "Order"     : ["我的订单", "我喜欢的礼遇", "我的礼券", "反馈", "关于"]
//            "Settings"  : ["反馈", "关于"]
        ]
        static let MyIcons: [String: [String]] = [
//            "user"      : ["account_circle_black"],
            "order"     : ["order_black", "favorite_black", "voucher_black", "feedback_black", "about_black"]
//            "settings"  : ["coffee", "image"]
        ]
        static let MyInfos: [String: [String]] = [
            "账号安全": ["手机号", "密码"],
            "社交网络": ["新浪微博", "微信"],
            "个人资料": ["头像", "邮箱", "昵称"]
        ]
        static let Settings: [String: [String]] = [
            "Settings"     : ["推送设置", "服务授权", "图片缓存", "赞一下"]
        ]
        static let NotificationOptions: [String: [String]] = [
            "Options"     : ["消费确认", "退款成功", "获得礼券"]
        ]
        
        static let PersonalInfo: String = "个人信息"
        static let Avatar: String = "头像"
        static let Email: String = "邮箱"
        static let Nickname: String = "昵称"
        static let AccountSecurity: String = "账号安全"
        static let PhoneNumber: String = "手机号"
        static let Passcode: String = "密码"
        static let SocialAuth: String = "其它登陆方式"
        static let SinaWeibo: String = "新浪微博"
        static let WeChat: String = "微信"
        
    }
    
    enum UserInfo {
        
        static let Mobile: String = "mobile"
        static let Email: String = "email"
        static let Nickname: String = "nickname"
        static let Icon: String = "icon"
        static let inviteCode: String = "inviteCode"
        static let inviteCount: String = "inviteCount"
        static let inviteTip: String = "inviteTip"
        static let inviteRewards: String = "inviteRewards"
        static let VerifyCode: String = "verify_code"
        static let SaltCode: String = "salt_code"
    }
    
    
    enum EditType: String {
        case Email = "Email"
        case Nickname = "Nickname"
        case Password = "Password"
        case Mobile = "Mobile"
    }
    
    enum FoodInfoType: Int {
        case spot = 1
        case menu = 2
        case info = 3
    }
    
    enum ShareToType: Int {
        case food = 1
        case invite = 2
    }
    
    enum OrderType: Int {
        case waitForPay = 10
        case paid = 20
        case paidWithoutUsed = 21
        case paidWithUsed = 22
        case refund = 30
        case refundInProgress = 31
        case refunded = 32
        case expired = 50
        case waitForPayExpired = 51
        case paidExpired = 52
        case deleted = 70
        case waitForPayDeleted = 71
        case waitForPayExpiredDeleted = 72
        case paidWithUsedDeleted = 73
        case refundedDeleted = 74
        
        var description: String {
            get {
                switch self {
                case .waitForPay: return "等待支付"
                case .paid: return "已支付"
                case .paidWithoutUsed: return "已支付未消费"
                case .paidWithUsed: return "已支付已消费"
                case .refund: return "申请退款"
                case .refundInProgress: return "退款中"
                case .refunded: return "已退款"
                case .expired: return "已过期"
                case .waitForPayExpired: return "待付款过期"
                case .paidExpired: return "已付款过期"
                case .deleted: return "已删除"
                case .waitForPayDeleted: return "待付款删除"
                case .waitForPayExpiredDeleted: return "待付款过期删除"
                case .paidWithUsedDeleted: return "已支付已消费删除"
                case .refundedDeleted: return "已退款删除"
                default: return "等待状态"
                }
            }
        }
    }
    
    enum PaymentCode: String {
        case AliPay = "alipay"
        case WechatPay = "weixin_pay"
    }
    
    
}



