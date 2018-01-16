//
//  SGLaunchHandler.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/19.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPPackageHandler.h"
#import "SGPUtilities.h"
#import "SGPRequestHandler.h"
#import "SGPAnalyticsFactory.h"
#import "SGPUtilities.h"
#import "SGPURLRequest.h"

static const char * const kInternalQueueName       = "io.Analytics.PackageQueue";


@interface SGPPackageHandler ()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, assign) id<SGPActivityHandler> activityHandler;
@property (nonatomic, retain) id<SGRequestHandler> requestHandler;

@end

@implementation SGPPackageHandler

@synthesize analyticsConfig = _analyticsConfig;
@synthesize launchPackageQueue = _launchPackageQueue;
@synthesize clickPackageQueue = _clickPackageQueue;
@synthesize lastSendTime = _lastSendTime;

+ (id<SGPackageHandler>)handlerWithActivityHandler:(id<SGPActivityHandler>)activityHandler{
    return [[SGPPackageHandler alloc] initWithActivityHandler:activityHandler];
}

#pragma mark - internal
- (void)initInternal:(id<SGPActivityHandler>)activityHandler{
    self.activityHandler = activityHandler;
    self.lastSendTime = 0.0;
    self.requestHandler = [SGPRequestHandler handlerWithPackageHandler:self];
    self.launchPackageQueue = [[NSMutableArray alloc] init];
    self.clickPackageQueue = [[NSMutableArray alloc] init];
    self.sendingSemaphore = dispatch_semaphore_create(1);
}

- (id)initWithActivityHandler:(id<SGPActivityHandler>)activityHandler{
    self = [super init];
    if (self == nil) return nil;
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.internalQueue, ^{
        [self initInternal:activityHandler];
    });
    return self;
}

- (BOOL)sendLuanchPackageAndRenewLastSendTime:(long long)now {
    return (now - self.lastSendTime > SGPAnalyticsFactory.reportInterval);
}

#pragma mark - add
- (void)addPackage:(SGResponseData *)newPackage toFile:(NSString *)filename{
    if ([filename isEqualToString:kLaunchPackageQueueFilename]) {
        [self.launchPackageQueue addObject:newPackage];
        [SGPAnalyticsFactory.logger debug:@"*Added package to queue, count=%d :(%@)", self.launchPackageQueue.count, filename];
    }else if ([filename isEqualToString:kClickPackageQueueFilename]) {
        [self.clickPackageQueue addObject:newPackage];
        [SGPAnalyticsFactory.logger debug:@"*Added package to queue, count=%d :(%@)", self.launchPackageQueue.count, filename];
    }
}

- (void)writePackageQueueWithArray:(NSArray *)packages toFile:(NSString *)filename{
    NSString *filePath = [self packageQueueFilenamePath:filename];;
    BOOL result = [NSKeyedArchiver archiveRootObject:packages toFile:filePath];
    if (result == YES) {
        [SGPUtilities excludeFromBackup:filePath];
        [SGPAnalyticsFactory.logger debug:@"Package handler wrote %d packages", packages.count];
    } else {
        [SGPAnalyticsFactory.logger error:@"Failed to write package queue"];
    }
}

- (void)readPackageQueueWithFileName:(NSString *)filename {
    // start with a fresh package queue in case of any exception
    @try {
        if ([self eventsFileSize:filename]>=32*1024*1024) {//大于32MB
            [self writePackageQueueWithArray:[NSMutableArray array] toFile:filename];
            return;
        }
        
        [NSKeyedUnarchiver setClass:[SGPActivityPackage class] forClassName:@"SGActivityPackage"];
        NSString *filePath = [self packageQueueFilenamePath:filename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if ([object isKindOfClass:[NSArray class]]) {
            if ([filename isEqualToString:kLaunchPackageQueueFilename]) {
                for (id package in object) {
                    [self.launchPackageQueue insertObject:package atIndex:0];
                }
                [SGPAnalyticsFactory.logger debug:@"Package handler read %d packages, from %@", self.launchPackageQueue.count, filename];
            }else if ([filename isEqualToString:kClickPackageQueueFilename]){
                for (id package in object) {
                    [self.clickPackageQueue insertObject:package atIndex:0];
                }
                [SGPAnalyticsFactory.logger debug:@"Package handler read %d packages, from %@", self.clickPackageQueue.count,filename];
            }
            [self writePackageQueueWithArray:[NSMutableArray array] toFile:filename];
            return;
        }else if (object == nil) {
            [SGPAnalyticsFactory.logger verbose:@"Package queue file not found"];
        } else {
            [SGPAnalyticsFactory.logger error:@"Failed to read package queue"];
        }
    } @catch (NSException *exception) {
        [SGPAnalyticsFactory.logger error:@"Failed to read package queue (%@)", exception];
    }
}

#pragma mark - send
- (void)sendPackageWithFile:(NSString *)filename{
    [self readPackageQueueWithFileName:filename];
    [self sendPackageQueueWithFile:filename];
}

- (void)sendPackageQueueWithFile:(NSString *)filename{
    if (dispatch_semaphore_wait(self.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [SGPAnalyticsFactory.logger verbose:@"Package handler is already sending, Semaphore wait for sending"];
        return;
    }
    NSUInteger queueSize = 0;
    NSMutableArray *sendingPackage = nil;
    if ([filename isEqualToString:kLaunchPackageQueueFilename]) {
        self.lastSendTime = [SGPUtilities currentMillisecondTs];
        queueSize = self.launchPackageQueue.count;
        sendingPackage = [NSMutableArray arrayWithArray:self.launchPackageQueue];
        self.launchPackageQueue = [[NSMutableArray alloc] init];
    }else{
        queueSize = self.clickPackageQueue.count;
        sendingPackage = [NSMutableArray arrayWithArray:self.clickPackageQueue];
        self.clickPackageQueue = [[NSMutableArray alloc] init];
    }
    dispatch_semaphore_signal(self.sendingSemaphore);
    
    if (queueSize == 0) return;
    [SGPAnalyticsFactory.logger debug:@"Package handler is sending package with file %@", filename];
    [self.requestHandler sendPackage:sendingPackage withFileName:filename];
}

- (id<SGPActivityHandler> )activityHandler{
    return _activityHandler;
}

#pragma mark - private

//文件大小
-(NSUInteger)eventsFileSize:(NSString *)filename{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self packageQueueFilenamePath:filename];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    NSUInteger byte = [[fileAttributes objectForKey:@"NSFileSize"] integerValue];
    return byte;
}

//删除文件
-(void)deleteEventsFile:(NSString *)filename{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self packageQueueFilenamePath:filename];
    
    BOOL res=[fileManager removeItemAtPath:filePath error:nil];
    if (res) {
        NSLog(@"事件文件删除成功");
    }else
        NSLog(@"事件文件删除失败");
    NSLog(@"事件文件是否存在: %@",[fileManager isExecutableFileAtPath:filePath]?@"YES":@"NO");
}

- (NSString *)packageQueueFilenamePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:fileName];
    return filename;
}

-(void)dealloc {
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
}
@end
