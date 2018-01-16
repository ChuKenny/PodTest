//
//  ADJActivityState.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "SGPActivityState.h"
#import "SGPUtilities.h"

//static const int kTransactionIdCount = 10;

#pragma mark public implementation
@implementation SGPActivityState

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.startTime   = 0;
    self.endTime     = 0;
    return self;
}

- (void)resetSessionAttributes:(double)now {
    self.endTime    = 0;
    self.startTime  = now;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return nil;

    self.startTime    = [decoder decodeDoubleForKey:@"startTime"];
    self.endTime      = [decoder decodeDoubleForKey:@"endTime"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.endTime      forKey:@"endTime"];
    [encoder encodeDouble:self.startTime    forKey:@"startTime"];
}

-(id)copyWithZone:(NSZone *)zone
{
    SGPActivityState* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.endTime        = self.endTime;
        copy.startTime      = self.startTime;
    }
    
    return copy;
}

@end
