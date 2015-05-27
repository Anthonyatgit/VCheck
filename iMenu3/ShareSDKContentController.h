//
//  ShareContent.h
//  iMenu3
//
//  Created by Gabriel Anthony on 15/5/11.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>

@interface ShareSDKContentController: UIViewController <ISSShareViewDelegate>

+(NSArray*)getCustomShareList;
+(NSMutableArray*)getUserInfoWithConnectType: (ShareType)shareType;

@end
