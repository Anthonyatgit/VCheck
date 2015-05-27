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
    }
    
    // MARK: - StringLing
    // Const String Defination
    enum StringLine {
        
        // MEMBER LOGIN
        static let AppName: String = "VCheck"
        static let SaltKey: String = "siyo_vcheck"
        static let isLoading: String = "努力加载中.."
        static let InternetUnreachable: String = "网络不给力，快检查一下吧"
        static let UpdateNowButtonTitle: String = "立即更新"
        static let UpdateNoticeTitle: String = "更新提示"
        static let UpdateDescription: String = "有最新的可用版本，建议升级应用保持内容为最新"
        static let UserPanelTitle: String = "我的账户"
        static let LoginPageTitle: String = "登陆"
        static let RegPageTitle: String = "注册"
        static let UserInfoWithoutSignin: String = "登陆/注册享丰富礼券"
        static let LoginTitle: String = "使用VCheck账号登陆，赢取丰富礼券"
        static let LoginName: String = "手机号/邮箱"
        static let LoginPass: String = "密码"
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
        static let Gotit: String = "我知道了"
        static let FindBackMyPassTitle: String = "找回密码"
        static let SMSCode: String = "验证码"
        static let InputSMSCode: String = "短信验证码"
        static let ResetYourPasscode: String = "重置密码"
        static let Next: String = "下一步"
        static let Preview: String = "上一步"
        static let Resent: String = "重新发送"
        static let NewPasscode: String = "新密码"
        static let AgainPasscode: String = "再输一次"
        static let PasscodeTooShort: String = "您的密码应当不少于6位"
        static let PhoneNumber: String = "手机号码"
        static let SendAutoCode: String = "发送验证码"
        static let InventCodeOption: String = "邀请码(选填)"
        static let NoInventCodeYet: String = "还没有邀请码？没关系，以后还可以补填"
        static let AgreeTermsString: String = "点击下一步，代表理解并同意 VCheck 的用户协议"
        static let UserTerms: String = "用户协议"
        static let TermsURL: String = "http://218.244.158.175/static/userterms.html"
        static let InitPasscode: String = "请设置您的登陆密码"
        static let BlackUserIconURL: String = "http://218.244.158.175/siyocc/t/account_circle_black.png"
        static let NotSetYet: String = "未设置"
        static let PassCodeString = "••••••"
        static let NotAuthYet: String = "未认证"
        static let UserInfoSettings: String = "账户设置"
        static let Logout: String = "退出登录"
    }
    
    // MARK: - IconName
    enum IconName {
        
        static let UserInfoIconWithoutSignin: String = "account_circle_black"
        static let RightDisclosureIcon: String = "right_black"
        static let ClearIconBlack: String = "clear_black"
        static let HelpIconBlack: String = "help_black"
        static let InternetBlack: String = "internet_black"
    }
    
    // MARK: - ConstValue
    enum ConstValue {
        
        // Const value
        static let SMSRemainingSeconds: Int = 5 // 验证码倒计时总秒数
        static let PI: CGFloat = 3.14159265358979323846 // 圆周率
        static let TopAlertStayTime: Int = 3
        static let LineGap: CGFloat = 20.0
        static let ToplineWithNavBar: CGFloat = 80.0
        static let TextFieldHeight: CGFloat = 30.0
        static let ButtonHeight: CGFloat = 30.0
        static let UnderlineHeight: CGFloat = 3.0
        static let UserIconCellHeight: CGFloat = 72.0
        static let UserPanelCellHeight: CGFloat = 50.0
        static let UserIconCellHeaderHeight: CGFloat = 20.0
        static let UserPanelCellHeaderHeight: CGFloat = 1.0
        static let UserPanelCellIconWidth: CGFloat = 24.0
        static let ButtonCornerRadius: CGFloat = 3.0
        static let ButtonBorderWidth: CGFloat = 1.0
        static let ImageCornerRadius: CGFloat = 3.0
        static let UserInfoSectionHeaderHight: CGFloat = 40.0 // 用户信息分区标题视图高度
        static let UserInfoHeaderViewHeight: CGFloat = 80.0 // 顶部用户信息视图高度
        static let UserInfoFooterViewHeight: CGFloat = 80.0 // 底部用户信息视图高度
        static let MinLengthOfPasscode: Int = 6 // 用户密码最小长度
        static let ReachableClosures: Bool = false
    }
    
    // MARK: - SettingName
    enum SettingName {
        
        static let optNameIsLogin: String = "isLogin"
        static let optNameLoginType: String = "loginType"
        static let optNameCurrentMid: String = "currentMid"
        static let optVersioniOS: String = "version_ios"
        static let optNeedUpdate: String = "need_update"
        static let optTipForUpdate: String = "is_tips"
        static let optToken: String = "token"
        static let verifyCode: String = "verify_code"
        static let saltCode: String = "salt_code"
        static let mobile: String = "mobile"
    }
    
    // MARK: - LoginType
    enum LoginType {
        
        static let None: String = ""
        static let PhoneReg: String = "PhoneReg"
        static let Token: String = "Token"
        static let SinaWeibo: String = "SinaWeibo"
        static let WeChat: String = "WeChat"
    }
    
    // MARK: - Alert Notice title
    enum NoticeTitle {
        
        static let Success: String = "恭喜"
        static let Error: String = "错误"
        static let Notice: String = "提示"
    }
    
    // MARK: - UserPanel
    enum UserPanel {
        
        static let MyMenus: [String: [String]] = [
//            "User"      : ["登陆/注册享丰富礼券"],
            "Order"     : ["我的订单", "我喜欢的礼遇", "我的礼券", "分享赢取礼券"],
            "Settings"  : ["反馈", "关于"]
        ]
        static let MyIcons: [String: [String]] = [
//            "user"      : ["account_circle_black"],
            "order"     : ["ticket", "gift", "cards", "like"],
            "settings"  : ["coffee", "image"]
        ]
        static let MyInfos: [String: [String]] = [
            "账号安全": ["手机号", "密码"],
            "社交网络": ["新浪微博", "微信"],
            "个人资料": ["邮箱", "昵称"]
        ]
        
        static let PersonalInfo: String = "个人信息"
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
    }
    
}



