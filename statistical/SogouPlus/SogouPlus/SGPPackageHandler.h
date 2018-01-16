//
//  SGLaunchHandler.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPLaunchData.h"
#import "SGPActivityHandler.h"
#import "SGPActivityPackage.h"

static NSString   *const kLaunchPackageQueueFilename = @"kLaunchPackageQueueFilename";
static NSString   *const kClickPackageQueueFilename = @"kClickPackageQueueFilename";


@protocol  SGPackageHandler<NSObject>
@property (nonatomic, assign) long long lastSendTime;

@property (nonatomic, strong) NSMutableArray *launchPackageQueue;
@property (nonatomic, strong) NSMutableArray *clickPackageQueue;
@property (nonatomic, strong) SGAnalyticsConfig *analyticsConfig;

- (id)initWithActivityHandler:(id<SGPActivityHandler>)activityHandler;
- (BOOL)sendLuanchPackageAndRenewLastSendTime:(long long)now;
- (void)addPackage:(SGResponseData *)package toFile:(NSString *)filename;
- (void)sendPackageWithFile:(NSString *)filename;
- (void)writePackageQueueWithArray:(NSArray *)packages toFile:(NSString *)filename;
- (void)readPackageQueueWithFileName:(NSString *)filename;

- (id<SGPActivityHandler>)activityHandler;
@end

@interface SGPPackageHandler : NSObject<SGPackageHandler>

+ (id<SGPackageHandler>)handlerWithActivityHandler:(id<SGPActivityHandler>)activityHandler;

@end
