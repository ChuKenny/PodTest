//
//  ADJTimerOnce.m
//  adjust
//
//  Created by Pedro Filipe on 03/06/15.
//  Copyright (c) 2015 adjust GmbH. All rights reserved.
//

#import "SGPTimerOnce.h"
#import "SGPLogger.h"
#import "SGPAnalyticsFactory.h"
#import "SGPUtilities.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

#pragma mark - private
@interface SGPTimerOnce()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic) dispatch_source_t source;
@property (nonatomic, strong) dispatch_block_t block;
@property (nonatomic, assign, readonly) dispatch_time_t start;
@property (nonatomic, retain) NSDate * fireDate;
@property (nonatomic, copy) NSString *name;

@end

#pragma mark -
@implementation SGPTimerOnce

+ (SGPTimerOnce *)timerWithBlock:(dispatch_block_t)block
                       queue:(dispatch_queue_t)queue
                            name:(NSString*)name
{
    return [[SGPTimerOnce alloc] initBlock:block queue:queue name:name];
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
           name:(NSString*)name
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = queue;
    self.name = name;

    self.block = ^{
        [SGPAnalyticsFactory.logger verbose:@"%@ fired", name];
        block();
    };

    return self;
}

- (NSTimeInterval)fireIn {
    if (self.fireDate == nil) {
        return 0;
    }
    return [self.fireDate timeIntervalSinceNow]*NSEC_PER_USEC;//millisecond
}

- (void)startIn:(NSTimeInterval)startIn {
    // cancel previous
    [self cancel:NO];

    self.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:startIn];
    NSString * fireInFormatted = [SGPUtilities secondsNumberFormat:[self fireIn]];
    [SGPAnalyticsFactory.logger verbose:@"%@ starting. Launching in %@ seconds", self.name, fireInFormatted];

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.internalQueue);

    dispatch_source_set_timer(self.source,
                              dispatch_walltime(NULL, startIn * NSEC_PER_SEC),
                              DISPATCH_TIME_FOREVER,
                              kTimerLeeway);


    dispatch_resume(self.source);

    dispatch_source_set_event_handler(self.source, self.block);
}

- (void)cancel:(BOOL)log {
    if (self.source != nil) {
        dispatch_cancel(self.source);
    }
    self.source = nil;
    if (log) {
        [SGPAnalyticsFactory.logger verbose:@"%@ canceled", self.name];
    }
}

- (void)cancel {
    [self cancel:YES];
}
@end
