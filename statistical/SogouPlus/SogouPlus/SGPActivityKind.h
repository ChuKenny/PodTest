//
//  SGActivityKindUtil.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, SGActivityKind) {
    SGActivityKindStart     = 0,
    SGActivityKindLaunch     = 1,
    SGActivityKindClick      = 5,
    SGActivityKindPage       = 3,
    SGActivityKindUnknown    =-1
};


@interface SGPActivityKindUtil : NSObject
+ (SGActivityKind)activityKindFromString:(NSString *)activityKindString;
+ (NSString*)activityKindToString:(SGActivityKind)activityKind;
@end
