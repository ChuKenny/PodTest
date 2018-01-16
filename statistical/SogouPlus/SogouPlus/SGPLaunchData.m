//
//  SGResponseData.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPLaunchData.h"

@implementation SGResponseData


@end

@implementation SGPLaunchData
+ (SGPLaunchData *)launchData {
    return [[SGPLaunchData alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        
    };
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    SGPLaunchData* copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy.type   = self.type;
        copy.ts    = self.ts;
        copy.data = [self.data copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return self;
    NSString *kindString = [decoder decodeObjectForKey:@"type"];
    self.type = [SGPActivityKindUtil activityKindFromString:kindString];
    self.ts = [decoder decodeObjectForKey:@"ts"];
    self.data = [decoder decodeObjectForKey:@"data"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSString *kindString = [SGPActivityKindUtil activityKindToString:self.type];
    [encoder encodeObject:kindString forKey:@"type"];
    [encoder encodeObject:self.ts forKey:@"ts"];
    [encoder encodeObject:self.data forKey:@"data"];
}

@end


//@implementation SGPStartEvent
//
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        self.type = SGActivityKindStart;
//    };
//    return self;
//}
//@end
//
//@implementation SGPEndEvent
//
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        self.type = SGActivityKindStart;
//    };
//    return self;
//}
//@end
//
//@implementation SGPUserEvent
//
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        self.type = SGActivityKindStart;
//    };
//    return self;
//}
//@end
