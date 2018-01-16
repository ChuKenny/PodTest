//
//  ADJAdjustFactory.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "SGPAnalyticsFactory.h"
#import "SGPLogger.h"


static id<SGPackageHandler> internalPackageHandler = nil;
static id<SGRequestHandler> internalRequestHandler = nil;
static id<SGPLogger> internalLogger = nil;

static double internalSessionInterval    = -1;
static NSTimeInterval internalTimerInterval = -1;
static NSTimeInterval intervalTimerStart = -1;

@implementation SGPAnalyticsFactory


//发送周期
+ (NSTimeInterval)reportInterval {
    if (internalSessionInterval == -1) {
#ifdef PLUS_DEBUG
        return 0*NSEC_PER_USEC; //60s
#else
        return 60*60*NSEC_PER_USEC;//0*NSEC_PER_USEC;//60*60; // 60 minutes
#endif
    }
    return internalSessionInterval;
}
//后台时间
+ (NSTimeInterval)sessionTimeout {
    if (internalTimerInterval == -1) {
#ifdef PLUS_DEBUG
        return 0*NSEC_PER_USEC;  //3s
#else
        return 30*NSEC_PER_USEC; //30 second
#endif
    }
    return internalTimerInterval;
}

+ (NSTimeInterval)timerStart {
    if (intervalTimerStart == -1) {
        return 1*NSEC_PER_USEC;   // 1 second
    }
    return intervalTimerStart;
}

+ (id<SGPLogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[SGPLogger alloc] init];
        [internalLogger setLogLevel:SGConfigInstance.logLevel];
    }
    return internalLogger;
}

+ (void)setLogger:(id<SGPLogger>)logger {
    internalLogger = logger;
}

+ (void)setSessionInterval:(double)sessionInterval {
    internalSessionInterval = sessionInterval;
}

+ (void)setTimerInterval:(NSTimeInterval)timerInterval {
    internalTimerInterval = timerInterval;
}

+ (void)setTimerStart:(NSTimeInterval)timerStart {
    intervalTimerStart = timerStart;
}

+ (id<SGPackageHandler>)launchHandlerWithLaunchHandler:(id<SGPActivityHandler>)activityHandler{
    if (internalPackageHandler == nil) {
        return [SGPPackageHandler handlerWithActivityHandler:activityHandler];
    }
    return [internalPackageHandler initWithActivityHandler:activityHandler];
}


+ (void)setLaunchHandler:(id<SGPackageHandler>)launchHandler{
    internalPackageHandler = launchHandler;
}

+ (id<SGRequestHandler>)requestHandlerForPackageHandler:(id<SGPackageHandler>)packageHandler {
    if (internalRequestHandler == nil) {
        return [SGPRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return [internalRequestHandler initWithPackageHandler:packageHandler];
}

@end
