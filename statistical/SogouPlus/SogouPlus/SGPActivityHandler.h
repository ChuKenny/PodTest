//
//  SGActivityHandler.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/17.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPMobileClick.h"
#import "SGPLaunchData.h"
#import "SGPActivityPackage.h"


@protocol SGPActivityHandler <NSObject>
@property (nonatomic, strong) SGAnalyticsConfig *analyticsConfig;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

@end

@interface SGPActivityHandler : NSObject<SGPActivityHandler>

+ (id<SGPActivityHandler>)handlerWithConfig:(SGAnalyticsConfig *)analyticsConfig;

- (void)bulidEvent:(NSString *)eventId;
@end
