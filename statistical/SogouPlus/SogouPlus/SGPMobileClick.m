//
//  SGMobileClick.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/10.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPMobileClick.h"
#import "SGPDeviceInfo.h"
#import "SGPAnalyticsFactory.h"
#import "SGPUtilities.h"
#import "SGPURLRequest.h"
#import "SGPActivityHandler.h"
#import "SGPAnalyticsFactory.h"

@interface SGAnalyticsConfig ()

@end


@implementation SGAnalyticsConfig

+ (instancetype)sharedInstance{
    static SGAnalyticsConfig *sogouAnalytics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sogouAnalytics = [[self alloc] init];
        sogouAnalytics.channelId = @"AppStore";
        sogouAnalytics.appVersion = [SGPUtilities appVersion];
        sogouAnalytics.sessionTimeout = SGPAnalyticsFactory.sessionTimeout;
        sogouAnalytics.logLevel = SGPLogLevelVerbose;
        sogouAnalytics.usingAnalytics = YES;
#ifdef PLUS_DEBUG
        sogouAnalytics.forTest = YES;
#else
        sogouAnalytics.forTest = NO;
#endif
    });
    return sogouAnalytics;
}

- (void)deleteKeyChain{
    [SGPUtilities deleteSgAnaliyticsUuidAndToken];
}

- (void)setChannelId:(NSString *)channelId {
    if (![SGPUtilities validateString:channelId withRegex:REGEX_CONTENT_CHANNEL]) {
        [NSException raise:@"Invalid channelId value" format:@"channelId of %@ is invalid", channelId];
    }
    _channelId = channelId;
}

- (void)setClientId:(NSString *)clientId {
    if (![SGPUtilities validateString:clientId withRegex:REGEX_UNSINGED_INTEGER]) {
        [NSException raise:@"Invalid appId value" format:@"appId of %@ is invalid", clientId];
    }
    _clientId = clientId;
}

- (void)setForTest:(BOOL)forTest{
    _forTest = forTest;
    if (forTest) {

        NSLog(@"SANDBOX: Analytics is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing");
    }else{
        NSLog(@"PRODUCTION: Analytics is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!");
    }
}

@end

@interface SGPMobileClick ()

@property (nonatomic, strong) SGAnalyticsConfig *config;
@property (nonatomic, strong) id<SGPLogger> logger;

+ (instancetype)sharedInstanceWithConfig:(SGAnalyticsConfig *)configure;

@end

@implementation SGPMobileClick

+ (instancetype)sharedInstanceWithConfig:(SGAnalyticsConfig *)configure{
    static SGPMobileClick *mobileClick;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mobileClick = [[self alloc] init];
        mobileClick.config = configure;
    });
    return mobileClick;
}

+ (void)appDidLaunch:(SGAnalyticsConfig *)configure{
    SGPMobileClick *mobileClick = [SGPMobileClick  sharedInstanceWithConfig:configure];
    if (mobileClick==nil) return;
    [SGPActivityHandler handlerWithConfig:configure];
}

+ (void)event:(NSString *)eventId{
    if (![SGPUtilities validateString:eventId withRegex:REGEX_CONTENT_EVENTID]) {
        [NSException raise:@"Invalid eventId value" format:@"appId of %@ is invalid", eventId];
    }
    SGPActivityHandler *handler = [SGPActivityHandler handlerWithConfig:SGConfigInstance];
    [handler bulidEvent:eventId];
}
@end
