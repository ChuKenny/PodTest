//
//  SGPackageBuilder.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "SGPackageBuilder.h"
#import "SGPActivityPackage.h"
#import "SGPUtilities.h"
#import "SGPMobileClick.h"

@interface SGPackageBuilder ()
//@property (nonatomic, strong) NSDate *dateLastHour;

@end

@interface SGPackageBuilder()

@property (nonatomic, copy) SGPActivityState *activityState;
@property (nonatomic, assign) double createdAt;
@property (nonatomic, assign) double interval;

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, strong)NSMutableDictionary *eventDic;
@property (nonatomic, copy) NSString *currentHour;
@property (nonatomic, strong) NSDate *currentClickEventDate;
@property (nonatomic, assign) id<SGPackageHandler> packageHandler;

@end


@implementation SGPackageBuilder
#pragma mark - LuanchBuilder
- (id)initLuanchBuilderWithActivityState:(SGPActivityState *)activityState
               createdAt:(double)createdAt
                interval:(double)interval
{
    self = [super init];
    if (self == nil) return nil;
    self.activityState = activityState;
    self.createdAt = createdAt;
    self.interval = interval;
    return self;
}

- (SGPLaunchData *)buildLuanchPackage {
    SGPLaunchData *launchPackage = [self defaultPackage];
    NSMutableDictionary *data = [self defaultLaunchData];
    launchPackage.data = data;
    
    launchPackage.type = SGActivityKindLaunch;
    launchPackage.ts = [NSNumber numberWithLongLong:self.createdAt];
    
    return launchPackage;
}

- (SGPLaunchData *)buildStartPackage {
    SGPLaunchData *startPackage = [self defaultPackage];
    NSMutableDictionary *data = [self defaultStartData];
    startPackage.data = data;
    
    startPackage.type = SGActivityKindStart;
    startPackage.ts = [NSNumber numberWithLongLong:self.createdAt];
    
    return startPackage;
}

#pragma mark - ClickBuilder
- (id)initClickBuilderWith:(id<SGPackageHandler>)packageHandler;
{
    self = [super init];
    if (self) {
        self.packageHandler = packageHandler;
    }
    return self;
}

- (SGPLaunchData *)buildClickPackageForEvent:(NSString *)eventId {
    self.eventId = eventId;
    NSDate *currentDate = [NSDate date];
    self.clickPackage = [self defaultClickPackageWithDate:currentDate];
    NSMutableDictionary *data = [self defaultClickData];
    self.clickPackage.data = data;
    return self.clickPackage;
}

- (NSString *)hourWithDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd hh"];
    NSString *hour=[format stringFromDate:date];
    return hour;
}

#pragma mark - private
- (SGPLaunchData *)defaultPackage {
    SGPLaunchData *activityPackage = [[SGPLaunchData alloc] init];
    return activityPackage;
}

- (SGPLaunchData *)defaultClickPackageWithDate:(NSDate *)date {
    if (self.currentClickEventDate==nil) {
        self.currentClickEventDate = [self dateLastHour:date];
    }else if ([date timeIntervalSince1970] > [self.currentClickEventDate timeIntervalSince1970]) {
        //每过一小时
        self.currentClickEventDate = [SGPUtilities dateLastHour:date];
        //创建新包：
        self.clickPackage = [[SGPLaunchData alloc] init];
        self.currentHour = [self hourWithDate:date];
        self.clickPackage.type = SGActivityKindClick;
    }
    
    if (self.clickPackage==nil) {
        self.currentClickEventDate = [self dateLastHour:date];
        self.clickPackage = [[SGPLaunchData alloc] init];
        self.currentHour = [self hourWithDate:date];
        self.clickPackage.type = SGActivityKindClick;
    }
    return self.clickPackage;
}

- (NSMutableDictionary *)defaultClickData {
    if (self.eventDic==nil) {
        self.eventDic = [[NSMutableDictionary alloc] init];
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd hh"];
    NSTimeInterval start = [[format dateFromString:self.currentHour] timeIntervalSince1970];
    long long millisecondTs =  start*NSEC_PER_USEC;
    [self parameters:self.eventDic setTime:millisecondTs forKey:@"start"];
    
    [self setCountsDic:self.eventDic eventId:self.eventId forKey:@"counts"];
    return self.eventDic;
}

- (NSMutableDictionary *)defaultStartData {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [self parameters:parameters setTime:self.createdAt forKey:@"start"];
    [self parameters:parameters setTime:self.interval forKey:@"interval"];
    return parameters;
}

- (NSMutableDictionary *)defaultLaunchData {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSUInteger duration = self.activityState.endTime - self.activityState.startTime;
    [self parameters:parameters setTime:duration forKey:@"duration"];
    [self parameters:parameters setTime:self.activityState.startTime forKey:@"start"];
    return parameters;
}


- (void)parameters:(NSMutableDictionary *)parameters setTime:(double)value forKey:(NSString *)key {
    if (value < 0) return;
    NSNumber *valueNum= [NSNumber numberWithDouble:value];
    [parameters setObject:valueNum forKey:key];
}

- (void)setCountsDic:(NSMutableDictionary *)countsDic eventId:(NSString *)eventId forKey:(NSString *)key{
    if (eventId ==nil || eventId.length==0) return;

    NSMutableDictionary *counts = [self.eventDic objectForKey:key];
    if (counts == nil) {
        counts = [NSMutableDictionary dictionaryWithDictionary:@{self.eventId:@1}];
        [self.eventDic setObject:counts forKey:key];
    }else{
        int eventCount = [[counts objectForKey:self.eventId] intValue];
        [counts setObject:[NSNumber numberWithInt:++eventCount] forKey:self.eventId];
    }
}

- (NSDate *)dateLastHour:(NSDate *)now {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    if (dateComponent.hour<23) {
        dateComponent.hour++;
    }else{
        dateComponent.hour=0;
        dateComponent.day++;
    }
    dateComponent.minute=0;
    dateComponent.second=0;
    
    NSDateComponents *dateComponents1 = dateComponent;
    NSDate *date = [dateComponents1 date];
    return date;
}

@end
