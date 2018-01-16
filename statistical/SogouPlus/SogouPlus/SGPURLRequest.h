//
//  SGURLRequest.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/15.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPActivityHandler.h"
#import "SGPDeviceInfo.h"
#import "SGPRequestResult.h"

@interface SGPURLRequest : NSObject{
    
}
+ (void)postRequest:(NSMutableURLRequest *)request responseHandler:(void (^)(NSDictionary *resultDic))responseHandler;

#pragma mark - POST /api/v1/signup
+ (void)signupSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandle;
#pragma mark - POST /api/v1/signin
+ (void)signinSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandler;
#pragma mark - POST /api/v1/event
+ (void)postEventSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSArray *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandler;

@end
