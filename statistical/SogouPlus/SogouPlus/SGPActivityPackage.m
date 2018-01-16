//
//  SGActivityPackage.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPActivityPackage.h"
#import "SGPActivityKind.h"

@implementation SGPActivityPackage

- (NSString *)description {
    return [NSString stringWithFormat:@"%@",
            [SGPActivityKindUtil activityKindToString:self.type]];
}

- (NSString *)successMessage {
    return [NSString stringWithFormat:@"Tracked %@",
            [SGPActivityKindUtil activityKindToString:self.type]];
}

- (NSString *)failureMessage {
    return [NSString stringWithFormat:@"Failed to track %@",
            [SGPActivityKindUtil activityKindToString:self.type]];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return self;
    self.parameters = [decoder decodeObjectForKey:@"parameters"];
    
    NSString *kindString = [decoder decodeObjectForKey:@"kind"];
    self.type = [SGPActivityKindUtil activityKindFromString:kindString];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSString *kindString = [SGPActivityKindUtil activityKindToString:self.type];
    
    [encoder encodeObject:self.parameters forKey:@"parameters"];
    [encoder encodeObject:kindString forKey:@"kind"];
}

@end
