
#import "SGPActivityHandler.h"
#import "SGPAnalyticsFactory.h"
#import "SGPActivityState.h"
#import "SGPDeviceInfo.h"
#import "SGPackageBuilder.h"
#import "SGPUtilities.h"
#import "SGPPackageHandler.h"
#import "SGPURLRequest.h"

static const char * const kInternalQueueName     = "io.Analytics.ActivityQueue";
static NSString   * const kActivityStateFilename = @"AnalyticsIoActivityState";
static NSString   * const kAttributionFilename   = @"AnalyticsIoAttribution";

static NSString   * const kForegroundTimerName   = @"Foreground timer";
//static NSTimeInterval kBackgroundTimerInterval;

#pragma mark - ///////////////////////////////////////////////////

@interface  SGPActivityHandler()<SGPActivityHandler>{
    
}
@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, copy)   SGPDeviceInfo *deviceInfo;
@property (nonatomic, copy) SGPActivityState *activityState;
@property (nonatomic, retain) id<SGPackageHandler> packageHandler;
@property (nonatomic, strong) SGPackageBuilder *clickBuilder;
@end

@implementation SGPActivityHandler
@synthesize analyticsConfig = _analyticsConfig;

static SGPActivityHandler *handler;

+ (id<SGPActivityHandler>)handlerWithConfig:(SGAnalyticsConfig *)analyticsConfig{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
        if ([SGPUtilities sgAnaliyticsUuid]!=nil) {
            analyticsConfig.appUdid = [SGPUtilities sgAnaliyticsUuid];
        }
        if ([SGPUtilities sgAnaliyticsToken]!=nil) {
            analyticsConfig.appToken = [SGPUtilities sgAnaliyticsToken];
        }
        handler.analyticsConfig = analyticsConfig;
        [handler handlerEvents];
    });
    return handler;
}

- (void)handlerEvents {
    [self addNotificationObserver];
    if (self.analyticsConfig == nil) {
        [SGPAnalyticsFactory.logger error:@"SGAnalyticsConfig missing"];
    }
    if (self.analyticsConfig.appToken==nil || self.analyticsConfig.appUdid==nil) {
        [SGPAnalyticsFactory.logger error:@"SGAnalyticsConfig not initialized correctly"];
    }
    
    if (self.analyticsConfig.forTest) {
        [SGPAnalyticsFactory.logger setLogLevel:self.analyticsConfig.logLevel];
    } else {
        [SGPAnalyticsFactory.logger setLogLevel:SGPLogLevelAssert];
    }
    
    [self readActivityState];
    
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.internalQueue, ^{
        [self initInternal];
    });
}

#pragma mark - ActivityState
- (BOOL)checkActivityState {
    if (self.activityState == nil) {
        [SGPAnalyticsFactory.logger error:@"Missing activity state"];
        return NO;
    }
    return YES;
}

- (void)readActivityState {
    [NSKeyedUnarchiver setClass:[SGPActivityState class] forClassName:@"ActivityState"];
    self.activityState = [SGPUtilities readObject:kActivityStateFilename objectName:@"ActivityState" class:[SGPActivityState class]];
}

- (void)writeActivityState {
    self.activityState.endTime = [SGPUtilities currentMillisecondTs];
    [SGPUtilities writeObject:self.activityState filename:kActivityStateFilename objectName:@"ActivityState"];
}

#pragma mark - internal
- (void)initInternal {
    self.packageHandler = [SGPAnalyticsFactory launchHandlerWithLaunchHandler:self];
    
    if (self.clickBuilder==nil) {
        self.clickBuilder = [[SGPackageBuilder alloc] initClickBuilderWith:self.packageHandler];
    }
}

- (void)endInternal {
    [self writeActivityState];
    [self addAndSendClickPackage];
}

- (void)addAndSendClickPackage {
    if (self.clickBuilder.clickPackage!=nil) {//当前包不为空
        self.clickBuilder.clickPackage.ts = [NSNumber numberWithLongLong:[SGPUtilities currentMillisecondTs]];
        [self.packageHandler addPackage:self.clickBuilder.clickPackage toFile:kClickPackageQueueFilename];
        [self.packageHandler sendPackageWithFile:kClickPackageQueueFilename];
        //发送后应重新计数
        self.clickBuilder = [[SGPackageBuilder alloc] initClickBuilderWith:self.packageHandler];
    }else{//发送文件里的点击事件
        [self.packageHandler sendPackageWithFile:kClickPackageQueueFilename];
    }
}

- (BOOL)launchHaveEnded{
    return self.activityState.endTime>0;
}

- (void)transferSessionPackage:(double)now interval:(double)interval{
    SGPackageBuilder *launchBuilder = [[SGPackageBuilder alloc] initLuanchBuilderWithActivityState:self.activityState createdAt:now interval:interval];
    
    SGPLaunchData *startPackage = [launchBuilder buildStartPackage];
    [self.packageHandler addPackage:startPackage toFile:kLaunchPackageQueueFilename];

    if ([self launchHaveEnded]) {//判断不是第一次使用
         SGPLaunchData *endPackage = [launchBuilder buildLuanchPackage];
        [self.packageHandler addPackage:endPackage toFile:kLaunchPackageQueueFilename];
    }
}

- (void)startInternal {
    double now = [SGPUtilities currentMillisecondTs];
    if (self.activityState == nil) {
        self.activityState = [[SGPActivityState alloc] init];
        [self.activityState resetSessionAttributes:now];
    }
    
    double lastInterval=0;
    if ([self launchHaveEnded]) {//判断不是第一次使用
        lastInterval = now - self.activityState.endTime;//lastInterval 仅是发送字段
    }
    
    if (now - self.activityState.endTime < self.analyticsConfig.sessionTimeout) {
        [SGPAnalyticsFactory.logger info:@"Time travel!"];
    }else{
        [self transferSessionPackage:now interval:lastInterval];
        [self.activityState resetSessionAttributes:now];
    }
}

#pragma mark - clickEvent
- (void)bulidEvent:(NSString *)eventId{
    dispatch_async(self.internalQueue, ^{
        [self.clickBuilder buildClickPackageForEvent:eventId];
    });
}

#pragma mark - notifications
- (void)applicationDidBecomeActive {
    dispatch_async(self.internalQueue, ^{
        [self startInternal];
        [self newLuanchSend];
    });
}

- (void)newLuanchSend {
    long long now = [SGPUtilities currentMillisecondTs];
    if ([self.packageHandler sendLuanchPackageAndRenewLastSendTime:now]) {
        
        [self.packageHandler sendPackageWithFile:kLaunchPackageQueueFilename];
    }
}

- (void)applicationWillResignActive {
    [self endInternal];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self endInternal];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.internalQueue, ^{
//    });
}

- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center removeObserver:self];
    
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(applicationWillResignActive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
    
}

- (void)removeNotificationObserver {
    //如果是周期发送，杀进程时会先调用applicationWillResignActive发送click事件，读写文件交由发送业务层处理，所以需要写launchPackageQueue
    [self.packageHandler readPackageQueueWithFileName:kLaunchPackageQueueFilename];
    [self.packageHandler writePackageQueueWithArray:self.packageHandler.launchPackageQueue toFile:kLaunchPackageQueueFilename];
    self.packageHandler.launchPackageQueue = [[NSMutableArray alloc] init];

    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
