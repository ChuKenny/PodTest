//
//  SGPackageBuilder
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SGPDeviceInfo.h"
#import "SGPActivityState.h"
#import "SGPActivityPackage.h"
#import "SGPMobileClick.h"
#import "SGPLaunchData.h"
#import "SGPPackageHandler.h"


@interface SGPackageBuilder : NSObject


- (id)initLuanchBuilderWithActivityState:(SGPActivityState *)activityState
                  createdAt:(double)createdAt
                   interval:(double)interval;
- (SGPLaunchData *)buildLuanchPackage;
- (SGPLaunchData *)buildStartPackage;

- (id)initClickBuilderWith:(id<SGPackageHandler>)packageHandler;
- (SGPLaunchData *)buildClickPackageForEvent:(NSString *)eventId;
@property (nonatomic, strong)SGPLaunchData *clickPackage;


@end
