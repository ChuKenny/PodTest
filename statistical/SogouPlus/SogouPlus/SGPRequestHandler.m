//
//  SGRequestHandler.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/20.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPRequestHandler.h"
#import "SGPAnalyticsFactory.h"
#import "SGPURLRequest.h"
#import "SGPUtilities.h"

static const char * const kInternalQueueName = "io.sgAnalytics.RequestQueue";

@interface SGPRequestHandler ()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<SGPackageHandler> packageHandler;
@property (nonatomic, strong)NSString *fileName;
@end

@implementation SGPRequestHandler
+ (id<SGRequestHandler>) handlerWithPackageHandler:(id<SGPackageHandler>)packageHandler{
    return [[SGPRequestHandler alloc] initWithPackageHandler:packageHandler];
}


- (id)initWithPackageHandler:(id<SGPackageHandler>)packageHandler{
    self = [super init];
    if (self == nil) return nil;
    
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    return self;
}

- (void)sendPackage:(NSMutableArray *)activityPackage withFileName:(NSString *)fileName
{
    self.fileName = fileName;
    dispatch_async(self.internalQueue, ^{
        [self sendPackage:activityPackage hasSignUp:NO hasSignIn:NO];
    });
}

- (NSArray *)activityPackageToEventsWithPackage:(NSArray *)activityPackage
{
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:capacityOfSending];
    for (SGResponseData *event in activityPackage) {
        if ([event isKindOfClass:[SGResponseData class]]) {
            switch (event.type) {
                case SGActivityKindLaunch:{
                    SGPLaunchData *launchData = (SGPLaunchData *)event;
                    [events addObject:@{@"type":[NSNumber numberWithInt:launchData.type],
                                        @"ts":launchData.ts,
                                        @"data":@{@"start":[launchData.data objectForKey:@"start"],
                                                  @"duration":[launchData.data objectForKey:@"duration"]}}];
                }break;
                case SGActivityKindStart:{
                    SGPLaunchData *launchData = (SGPLaunchData *)event;
                    [events addObject:@{@"type":[NSNumber numberWithInt:launchData.type],
                                        @"ts":launchData.ts,
                                        @"data":@{@"start":[launchData.data objectForKey:@"start"],
                                                  @"interval":[launchData.data objectForKey:@"interval"]}}];
                }break;
                case SGActivityKindClick:{
                    SGPLaunchData *clickData = (SGPLaunchData *)event;
                    [events addObject:@{@"type":[NSNumber numberWithInt:clickData.type],
                                        @"ts":clickData.ts,
                                        @"data":@{@"start":[clickData.data objectForKey:@"start"],
                                                  @"counts":[clickData.data objectForKey:@"counts"]}}];
                }break;
                default:
                    break;
            }
        }
    }
    return events;
}

#pragma mark - internal
- (BOOL)sendPackage:(NSMutableArray *)activityPackage hasSignUp:(BOOL)hasSignUp hasSignIn:(BOOL)hasSignIn
{
    if (SGConfigInstance.appUdid==nil) {
        if (hasSignUp) return NO;
        [self postEventsWhenUdidNotFoundWithActivityPackage:activityPackage hasSignUp:hasSignUp hasSignIn:hasSignIn];
    }else if (SGConfigInstance.appToken==nil){
        if (hasSignIn) return NO;
        [self postEventsWithUnauthorizedWithActivityPackage:activityPackage hasSignUp:hasSignUp hasSignIn:hasSignIn];
    }else{
        [self postEventsWhenHasSignUpInWithPackage:activityPackage hasSignUp:hasSignUp hasSignIn:hasSignIn];
    }
    return YES;
}

- (void)clearCurrentQueueWhenPostSuccess {
    [self.packageHandler writePackageQueueWithArray:[NSMutableArray array] toFile:self.fileName];
    if ([self.fileName isEqualToString:kLaunchPackageQueueFilename]) {
        self.packageHandler.launchPackageQueue = [[NSMutableArray alloc] init];
    }else{
        self.packageHandler.clickPackageQueue = [[NSMutableArray alloc] init];
    }
}

- (void)writeCurrentQueueWhenFailPost:(NSArray *)activityPackage {
    [SGPAnalyticsFactory.logger assert:@"Write %d events to file %@, post Events When Has SignUpIn fail!",activityPackage.count, self.fileName];
    [self.packageHandler writePackageQueueWithArray:activityPackage toFile:self.fileName];
}

- (void)postEventsWhenHasSignUpInWithPackage:(NSMutableArray *)activityPackage hasSignUp:(BOOL)hasSignUp hasSignIn:(BOOL)hasSignIn{
    NSArray *events = [self activityPackageToEventsWithPackage:activityPackage];
    NSString *urlQuery = [SGPUtilities eventsStringQueryWithSGAnalyticsConfig:SGConfigInstance];
    [SGPURLRequest postEventSGRequestWithUrlQuery:urlQuery parameters:events responseHandler:^(NSDictionary *resultDic) {
        SGPRequestResult *result = [SGPRequestResult resultWithReturnDictionary:resultDic];
        if (result!=nil && result.statusCode==200) {
            switch (result.code) {
                case OK:{
                    [SGPAnalyticsFactory.logger info:@"=Posted %d events succeed!", events.count];
                    [SGPAnalyticsFactory.logger assert:@"clear file %@",self.fileName];
                    return;
                }break;
                case NOT_FOUND: {//udId不存在，需重新注册
                    [SGConfigInstance deleteKeyChain];
                    SGConfigInstance.appUdid=nil;
                    SGConfigInstance.appToken=nil;
                    if ([self sendPackage:activityPackage hasSignUp:hasSignUp hasSignIn:hasSignIn]) {
                        return;
                    }
                }break;
                case UNAUTHORIZED: {//token失效或验签失败，需重新登录
                    [SGConfigInstance deleteKeyChain];
                    SGConfigInstance.appToken=nil;
                    if ([self sendPackage:activityPackage hasSignUp:hasSignUp hasSignIn:hasSignIn]) {
                        return;
                    }
                }break;
                default:
                    break;
            }
        }
        [self writeCurrentQueueWhenFailPost:activityPackage];
    }];
}

//NOT_FOUND
- (void)postEventsWhenUdidNotFoundWithActivityPackage:(NSMutableArray *)activityPackage hasSignUp:(BOOL)hasSignUp hasSignIn:(BOOL)hasSignIn{
    NSDictionary *parameters =  [SGPUtilities signupDictionaryWithSGDeviceInfo:[SGPDeviceInfo deviceInfo]];
    NSString *signupStringQuery = [SGPUtilities signupStringQueryWithSGAnalyticsConfig:SGConfigInstance];
    [SGPURLRequest signupSGRequestWithUrlQuery:signupStringQuery parameters:parameters responseHandler:^(NSDictionary *resultDic) {
        SGPRequestResult *result = [SGPRequestResult resultWithReturnDictionary:resultDic];
        if (result!=nil && result.statusCode==200 && result.code==OK) {
            [SGPUtilities setSgAnaliyticsUuid:[result.data objectForKey:@"udId"]];
            [SGPUtilities setSgAnaliyticsToken:[result.data objectForKey:@"token"]];
            SGConfigInstance.appToken = [result.data objectForKey:@"token"];
            SGConfigInstance.appUdid = [result.data objectForKey:@"udId"];
            if ([self sendPackage:activityPackage hasSignUp:YES hasSignIn:hasSignIn]) {
                return;
            }
        }
        [self writeCurrentQueueWhenFailPost:activityPackage];
    }];
}

//UNAUTHORIZED
- (void)postEventsWithUnauthorizedWithActivityPackage:(NSMutableArray *)activityPackage hasSignUp:(BOOL)hasSignUp hasSignIn:(BOOL)hasSignIn{
    NSDictionary *parameters = [SGPUtilities signinDictionaryWithSGDeviceInfo:[SGPDeviceInfo deviceInfo]];
    NSString *signinStringQuery = [SGPUtilities signinStringQueryWithSGAnalyticsConfig:SGConfigInstance];
    [SGPURLRequest signinSGRequestWithUrlQuery:signinStringQuery parameters:parameters responseHandler:^(NSDictionary *resultDic)
    {
        SGPRequestResult *result = [SGPRequestResult resultWithReturnDictionary:resultDic];
        if (result!=nil && result.statusCode==200){
            switch (result.code) {
                case OK:{
                    [SGPUtilities setSgAnaliyticsToken:[result.data objectForKey:@"token"]];
                    SGConfigInstance.appToken = [result.data objectForKey:@"token"];
                    if ([self sendPackage:activityPackage hasSignUp:hasSignUp hasSignIn:YES]) {
                        return;
                    }
                }break;
                case NOT_FOUND: {//token失效或验签失败，需重新登录
                    [SGConfigInstance deleteKeyChain];
                    SGConfigInstance.appUdid=nil;
                    SGConfigInstance.appToken=nil;
                    if ([self sendPackage:activityPackage hasSignUp:hasSignUp hasSignIn:YES]) {
                        return;
                    }
                }break;
                default:{
                } break;
            }
        }
        [self writeCurrentQueueWhenFailPost:activityPackage];
    }];
}


@end
