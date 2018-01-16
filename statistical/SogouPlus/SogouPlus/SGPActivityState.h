//
//  ADJActivityState.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SGPActivityState : NSObject <NSCoding, NSCopying>


@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double endTime;
- (void)resetSessionAttributes:(double)now;
@end
