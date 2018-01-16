//
//  SGMobileClick.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/10.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SGPAnalyticsConstants.h"
#import "SGPMobileClick.h"


/** @brief 统计SDK的配置实例，具体参照该类成员的参数定义
 * 示例代码: SGConfigInstance.appId = @"xxxxxxxxxxxxxx...";
 *         SGConfigInstance.channelId = @"yyyyyyyy....";
 *         [SGMobClick startWithConfigure:SGConfigInstance];
 */
#define SGConfigInstance [SGAnalyticsConfig sharedInstance]


@interface SGAnalyticsConfig : NSObject

/** required:  搜狗passport分配给公司内部每个应用的标识 string default:demo "1236"*/
@property (nonatomic, copy) NSString *clientId;
/** required:  客户端密钥 appSecretKey string */
@property (nonatomic, copy) NSString *clientSecret;

/** optional:  default: "AppStore"*/
@property (nonatomic, copy) NSString *channelId;
/** optional: 需要统计的 default: "AppStore 上线的plist版本号"*/
@property (nonatomic, copy) NSString *appVersion;
/** optional:  default: 30s */
@property (nonatomic, assign) NSUInteger sessionTimeout;
/* optional:  YES for not using, can see log, default: YES*/
@property (nonatomic, assign) BOOL usingAnalytics;
/* optional:  YES for test environment, can see log, default: NO*/
@property (nonatomic, assign) BOOL forTest;
/* optional:  default: ADJLogLevelInfo for test */
@property (nonatomic, assign) SGPLogLevel logLevel;
+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *appUdid;

@property (nonatomic, copy) NSString *appToken;

- (void)deleteKeyChain;
@end

@interface SGPMobileClick : NSObject<UIAlertViewDelegate>
#pragma mark basics
///---------------------------------------------------------------------------------------
/// @name  初始化统计
///---------------------------------------------------------------------------------------

/** 初始化搜狗统计模块
 ＊param SGAnalyticsConfig 实例类，具体参照该类成员的参数定义
 ＊return void
 */
+ (void)appDidLaunch:(SGAnalyticsConfig *)configure;


/** 自定义事件,数量统计.
 使用前，请先到Sogou+管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
 @param  eventId 网站上注册的事件Id.
 @return void.
 */
+ (void)event:(NSString *)eventId; 
@end
