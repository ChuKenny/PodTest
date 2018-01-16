//
//  SGUtilities.h
//  SGMobClick
//
//  Created by zhuqunye on 16/8/15.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGPDeviceInfo.h"
#import "SGPDeviceInfo.h"
#import "SGPActivityHandler.h"
#import "SGPRequestResult.h"

#pragma mark - 做用户输入检查的正则表达式
#define REGEX_CONTENT_LIMITED(a,b)      [NSString stringWithFormat:@"^.{%d,%d}$",a,b]
#define REGEX_CONTENT_COUNT(A)          [NSString stringWithFormat:@"^.{%d}$",A]
#define REGEX_CONTENT_CHINESE           @"(^[\u4e00-\u9fa5]+$)"
#define REGEX_TELEPHONE_NUM             @"[0-9]{11}"
#define REGEX_PHONE_NUM                 @"[0-9]{10,12}"
#define REGEX_PASSWORD_CONTENT          @"[A-Za-z0-9]{6,20}"
#define REGEX_EMAIL_CONENT              @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_UNSINGED_INTEGER          @"^[1-9]\\d*$"
#define REGEX_CONTENT_CHANNEL           @"[\\w\\(\\)_-]{1,32}"
#define REGEX_CONTENT_EVENTID           @"[0-9a-zA-Z\\(\\)_-]{1,128}"

@interface SGPUtilities : NSObject{
    
}
@property (nonatomic, strong)SGAnalyticsConfig *userConfig;
+ (NSString *)baseUrl;
+ (NSString *)clientSdk;
+ (NSString *)platform;
+ (NSString *)platformString;
+ (NSString *)appVersion;
+ (NSString *)networkingStates;
+ (id)JSONValueWithData:(NSData *)data;

+ (long long)currentMillisecondTs;

+ (NSDictionary *)signupDictionaryWithSGDeviceInfo:(SGPDeviceInfo *)di;
+ (NSDictionary *)signinDictionaryWithSGDeviceInfo:(SGPDeviceInfo *)di;
+ (NSString *)signupStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config;
+ (NSString *)signinStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config;
+ (NSString *)eventsStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config;

+ (void)setSgAnaliyticsUuid:(NSString *)uuid;
+ (void)setSgAnaliyticsToken:(NSString *)token;
+ (void)setSgAnaliyticsUuid:(NSString *)uuid token:(NSString *)token;
+ (void)deleteSgAnaliyticsUuidAndToken;

+ (NSString *)sgAnaliyticsUuid;
+ (NSString *)sgAnaliyticsToken;

#pragma mark - file utils
+ (BOOL)isNull:(id)value;
+ (BOOL)isNotNull:(id)value;
+ (NSDate *)dateLastHour:(NSDate *)now;
//字符正则检测
+ (BOOL)validateString:(NSString*)stringToSearch withRegex:(NSString*)regexString;
+ (NSString *)secondsNumberFormat:(double)seconds;

+ (NSString *)getFullFilename:(NSString *)baseFilename;
+ (void)excludeFromBackup:(NSString *)path;

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName
           class:(Class) classToRead;
+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName;
@end
