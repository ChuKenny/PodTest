//
//  SGRequestResult.m
//  SGMobClick
//
//  Created by zhuqunye on 16/9/6.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPRequestResult.h"

@implementation SGPRequestResult

+ (NSUInteger)statusCodeWithReturnDictionary:(NSDictionary *)returnDic{
    NSInteger statusCode = [[returnDic objectForKey:@"statusCode"] integerValue];
    return statusCode;
}

+ (StatusCode)errorCodeWithReturnDictionary:(NSDictionary *)returnDic {
    if ([returnDic objectForKey:@"code"]==nil) {
        return -1;
    }
    NSInteger statusCode = [[returnDic objectForKey:@"code"] integerValue];
    return statusCode;
}

+ (NSString *)messageWithReturnDictionary:(NSDictionary *)returnDic {
    NSString *message = [returnDic objectForKey:@"message"];
    return message;
}

+ (NSDictionary *)dataWithReturnDictionary:(NSDictionary *)returnDic {
    NSDictionary *data = [returnDic objectForKey:@"data"];
    return data;
}

+ (SGPRequestResult *)resultWithReturnDictionary:(NSDictionary *)returnDic {
    if (returnDic==nil) {
        return nil;
    }
    SGPRequestResult *result = [[SGPRequestResult alloc] init];
    result.statusCode = [self statusCodeWithReturnDictionary:returnDic];
    result.code = [self errorCodeWithReturnDictionary:returnDic];
    result.message = [self messageWithReturnDictionary:returnDic];
    result.data = [self dataWithReturnDictionary:returnDic];
    return result;
}

@end
