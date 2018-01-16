//
//  SGRequestResult.h
//  SGMobClick
//
//  Created by zhuqunye on 16/9/6.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
//(4) 返回状态码
//状态码	含义              可能原因
//0	OK	成功
//400	BAD_REQUEST     缺少参数或参数非法
//401	UNAUTHORIZED	token失效或验签失败，需重新登录
//403	FORBIDDEN       appId不存在，或appId与appName, appSign不匹配
//404	NOT_FOUND       udId不存在，需重新注册
//406	NOT_ACCEPT
//500	INTERNAL_ERROR	数据库错误
typedef NS_ENUM(NSUInteger, StatusCode) {
    OK=0,
    BAD_REQUEST     =400,
    UNAUTHORIZED    =401,
    FORBIDDEN       =403,
    NOT_FOUND       =404,
    NOT_ACCEPT      =406,
    INTERNAL_ERROR  =500
};

@interface SGPRequestResult : NSObject
+ (SGPRequestResult *)resultWithReturnDictionary:(NSDictionary *)returnDic;
@property (nonatomic, assign)   NSUInteger statusCode;
@property (nonatomic, assign)   StatusCode code;
@property (nonatomic, copy)     NSString *message;
@property (nonatomic, strong)   NSDictionary *data;
@end
