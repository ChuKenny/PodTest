//
//  SGActivityKindUtil.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPActivityKind.h"

@implementation SGPActivityKindUtil
+ (SGActivityKind)activityKindFromString:(NSString *)activityKindString {
    if ([@"start" isEqualToString:activityKindString]) {
        return SGActivityKindStart;
    }else if ([@"page" isEqualToString:activityKindString]) {
        return SGActivityKindPage;
    } else if ([@"click" isEqualToString:activityKindString]) {
        return SGActivityKindClick;
    } else if ([@"launch" isEqualToString:activityKindString]) {
        return SGActivityKindLaunch;
    }else {
        return SGActivityKindUnknown;
    }
}

+ (NSString*)activityKindToString:(SGActivityKind)activityKind {
    switch (activityKind) {
        case SGActivityKindStart:       return @"start";
        case SGActivityKindPage:        return @"page";
        case SGActivityKindClick:       return @"click";
        case SGActivityKindLaunch:      return @"launch";
        default:                        return @"unknown";
    }
}
@end
