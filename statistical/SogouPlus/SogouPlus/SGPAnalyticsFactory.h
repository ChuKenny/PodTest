//
//  ADJAdjustFactory.h
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "SGPLogger.h"
#import "SGPActivityPackage.h"
#import "SGPRequestHandler.h"
#import "SGPPackageHandler.h"

@interface SGPAnalyticsFactory : NSObject

+ (NSTimeInterval)reportInterval;
+ (NSTimeInterval)sessionTimeout;
+ (NSTimeInterval)timerStart;

+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;
+ (void)setTimerStart:(NSTimeInterval)timerStart;

+ (id<SGPLogger>)logger;
+ (id<SGPackageHandler>)launchHandlerWithLaunchHandler:(id<SGPActivityHandler>)activityHandler;
+ (void)setLaunchHandler:(id<SGPackageHandler>)activityHandler;
+ (id<SGRequestHandler>)requestHandlerForPackageHandler:(id<SGPackageHandler>)packageHandler;
@end
