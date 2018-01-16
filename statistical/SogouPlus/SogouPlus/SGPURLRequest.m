//
//  SGURLRequest.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/15.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//
#import "SGPAnalyticsConstants.h"
#import "SGPURLRequest.h"
#import "SGPUtilities.h"
#import "SGPRequestResult.h"
#import "SGPAnalyticsFactory.h"

static const double kRequestTimeout = 10; // 60 seconds

@implementation SGPURLRequest

+ (void)postRequest:(NSMutableURLRequest *)request responseHandler:(void (^)(NSDictionary *resultDic))responseHandler {
    if ([[SGPUtilities networkingStates] isEqualToString:@"NW_NONE"]) {
        responseHandler(nil);
        return;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionaryWithDictionary:@{@"statusCode":[NSNumber numberWithInteger:httpResponse.statusCode]}];
        NSDictionary *returnData =  [self JSONValueWithData:data];
        [returnDic  addEntriesFromDictionary:returnData];
        [SGPAnalyticsFactory.logger error:@"httpResponse (%@) => %@", httpResponse.URL, returnData];
        responseHandler(returnDic);
    }];
    [task resume];
}


#pragma mark - POST /api/v1/signup
+ (void)signupSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/signup%@",kBaseForgetUrl,urlQuery]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self transferToJSONDataWithParameters:parameters]];
    
    [self postRequest:request responseHandler:responseHandler];
}

#pragma mark - POST /api/v1/signin
+ (void)signinSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/signin%@",kBaseForgetUrl,urlQuery]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self transferToJSONDataWithParameters:parameters]];
    
    [self postRequest:request responseHandler:responseHandler];
}

#pragma mark - POST /api/v1/event
+ (void)postEventSGRequestWithUrlQuery:(NSString *)urlQuery parameters:(NSArray *)parameters responseHandler:(void (^)(NSDictionary *resultDic))responseHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/event%@",kBaseForgetUrl,urlQuery]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self transferToJSONDataWithParameters:parameters]];
    
    [self postRequest:request responseHandler:responseHandler];
}

#pragma mark - private
+ (id)JSONValueWithData:(NSData *)data{
    if(data==nil) return nil;
    
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) return nil;
    return result;
}

+ (NSData *)transferToJSONDataWithParameters:(id)theData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:0 error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}


@end
