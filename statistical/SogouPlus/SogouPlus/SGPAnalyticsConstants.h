//
//  SGAnalyticsConstants.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/15.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ISIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ? YES : NO)
#define ISIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0 ? YES : NO)
#define ISIOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >=9.0 ? YES : NO)

#define XcodeAppVersion [NSString stringWithFormat:@"%@(%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]]
//modules.features.bugs.bulids
static NSString * const kClientSdkVersion      = @"1.1.2.4";

typedef enum {
    SGPLogLevelVerbose = 1,
    SGPLogLevelDebug   = 2,
    SGPLogLevelInfo    = 3,
    SGPLogLevelWarn    = 4,
    SGPLogLevelError   = 5,
    SGPLogLevelAssert  = 6
} SGPLogLevel;

extern NSString * const kParamIdfv;
extern NSString * const kParamAppToken;
extern NSString * const kBaseForgetUrl;

extern NSString * const kAppToken;
extern NSString * const kEventToken1;
extern NSString * const kEventToken2;
extern NSString * const kEventToken3;
extern NSString * const kEventToken4;
