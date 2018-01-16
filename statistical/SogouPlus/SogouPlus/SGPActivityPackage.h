//
//  SGActivityPackage.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPActivityKind.h"

@interface SGPActivityPackage : NSObject<NSCoding>
@property (nonatomic, retain) NSDictionary *parameters;
//事件类型
@property (nonatomic, assign) SGActivityKind type;

@end
