//
//  SGRequestHandler.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/20.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPActivityPackage.h"
#import "SGPActivityHandler.h"
#import "SGPPackageHandler.h"


static const int capacityOfSending = 100;

@protocol SGRequestHandler
- (id)initWithPackageHandler:(id<SGPackageHandler>) packageHandler;

- (void)sendPackage:(NSMutableArray *)activityPackage withFileName:(NSString *)fileName;
@end

@interface SGPRequestHandler : NSObject<SGRequestHandler>
+ (id<SGRequestHandler>) handlerWithPackageHandler:(id<SGPackageHandler>)packageHandler;
@end
