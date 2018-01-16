//
//  ADJTimerCycle.m
//  adjust
//
//  Created by Pedro Filipe on 03/06/15.
//  Copyright (c) 2015 adjust GmbH. All rights reserved.
//

#import "SGPTimerCycle.h"
#import "SGPLogger.h"
#import "SGPAnalyticsFactory.h"
#import "SGPUtilities.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

#pragma mark - private
@interface SGPTimerCycle()

@property (nonatomic) dispatch_source_t source;
@property (nonatomic, assign) BOOL suspended;
@property (nonatomic, copy) NSString *name;

@end

#pragma mark -
@implementation SGPTimerCycle

+ (SGPTimerCycle *)timerWithBlock:(dispatch_block_t)block
                            queue:(dispatch_queue_t)queue
                        startTime:(NSTimeInterval)startTime
                     intervalTime:(NSTimeInterval)intervalTime
                             name:(NSString*)name
{
    return [[SGPTimerCycle alloc] initBlock:block queue:queue startTime:startTime intervalTime:intervalTime name:name];
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime
           name:(NSString*)name

{
    self = [super init];
    if (self == nil) return nil;

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.name = name;

    dispatch_source_set_timer(self.source,
                              dispatch_walltime(NULL, startTime * NSEC_PER_MSEC),
                              intervalTime * NSEC_PER_MSEC,
                              kTimerLeeway);

    dispatch_source_set_event_handler(self.source,^{ [SGPAnalyticsFactory.logger verbose:@"%@ fired", self.name];
                                          block();
                                      });

    self.suspended = YES;

    NSString * startTimeFormatted = [SGPUtilities secondsNumberFormat:startTime];
    NSString * intervalTimeFormatted = [SGPUtilities secondsNumberFormat:intervalTime];

    [SGPAnalyticsFactory.logger verbose:@"%@ fires after %@ seconds of starting and cycles every %@ seconds", self.name, startTimeFormatted, intervalTimeFormatted];

    return self;
}

- (void)resume {
    if (!self.suspended) {
        [SGPAnalyticsFactory.logger verbose:@"%@ is already started", self.name];
        return;
    }

    [SGPAnalyticsFactory.logger verbose:@"%@ starting", self.name];

    dispatch_resume(self.source);
    self.suspended = NO;
}

- (void)suspend {
    if (self.suspended) {
        [SGPAnalyticsFactory.logger verbose:@"%@ is already suspended", self.name];
        return;
    }

    [SGPAnalyticsFactory.logger verbose:@"%@ suspended", self.name];
    dispatch_suspend(self.source);
    self.suspended = YES;
}

@end
