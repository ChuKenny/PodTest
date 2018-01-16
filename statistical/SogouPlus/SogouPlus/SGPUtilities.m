//
//  SGUtilities.m
//  SGMobClick
//
//  Created by zhuqunye on 16/8/15.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "SGPUtilities.h"
#import "SGKeychain/SGPKeychain.h"
#import <Foundation/Foundation.h>
#import <sys/sysctl.h>
#include <sys/xattr.h>
#import "SGPURLRequest.h"
#import "SGPActivityHandler.h"
#import "SGPAnalyticsFactory.h"
#import "SGPAnalyticsConstants.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <arpa/inet.h>

#define KEY_KEYCHAIN_SERVICE_UUID   [NSString stringWithFormat:@"KEY_UUID%@", [SGAnalyticsConfig sharedInstance].clientId]
#define KEY_KEYCHAIN_SERVICE_TOKEN  [NSString stringWithFormat:@"KEY_TONKEN%@", [SGAnalyticsConfig sharedInstance].clientId]

static NSNumberFormatter * secondsNumberFormatter = nil;


@implementation SGPUtilities

+ (NSTimeInterval)timeIntervalNumberSince1970{
    double lDate = [[NSDate date] timeIntervalSince1970];
    return lDate;
}

+ (long long)currentMillisecondTs
{
    long long ts = [[NSDate date] timeIntervalSince1970]*NSEC_PER_USEC;
    return ts;
}

+ (NSString *)baseUrl {
    return kBaseForgetUrl;
}

+ (NSString *)clientSdk {
    return kClientSdkVersion;
}

+ (NSString *)appVersion{
    if (ISIOS9) {
        return  XcodeAppVersion;
    }else{
        return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
}

+ (id)JSONValueWithData:(NSData *)data{
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) return nil;
    return result;
}

+ (NSString *)networkingStates {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress); //创建测试连接的引用：
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){
        return @"NW_NONE";
    }
    
    NSString *returnValue = @"NW_NONE";
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0){
        returnValue = @"NW_WIFI";
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)){
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
            returnValue = @"NW_WIFI";
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
        
        NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
        
        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
            NSString *accessString = teleInfo.currentRadioAccessTechnology;
            if ([typeStrings4G containsObject:accessString]) {
                returnValue =  @"NW_4G";
            } else if ([typeStrings3G containsObject:accessString]) {
                returnValue =  @"NW_3G";
            } else if ([typeStrings2G containsObject:accessString]) {
                returnValue =  @"NW_2G";
            } else {
                returnValue =  @"NW_MOBILE";
            }
        } else {
            returnValue =  @"NW_MOBILE";
        }
    }
    return returnValue;
}

+ (NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])
        return @"iPhone Simulator";
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s Plus(A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,3"]) return @"iPhone se (A1549/A1586)";
    
    return platform;
}

+ (NSDictionary *)signupDictionaryWithSGDeviceInfo:(SGPDeviceInfo *)di {
    NSDictionary *signup = @{@"softId": di.softId,
                             @"cpu":    di.cpuSubtype,
                             @"brand":  @"Apple",
                             @"model":  di.deviceName,
                             @"resolution": di.resolution,
                             @"osName": di.osName,
                             @"osVer":  di.systemVersion,
                             @"lang":   di.languageCode,
                             @"country":di.countryCode,
                             @"appName":di.bundeIdentifier,
                             @"appVer": di.bundleVersion,
                             @"sdk":    di.clientSdk                             };
    return signup;
}

+ (NSString *)signupStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config {
    long long now = [self currentMillisecondTs];
    NSNumber *nowTime = [NSNumber numberWithLongLong:now];//millisecond
    NSString *network = [self networkingStates];
    NSString *stringQuery = [NSString stringWithFormat:@"?appId=%@&channel=%@&network=%@&ts=%@", config.clientId, config.channelId, network, nowTime];
    return stringQuery;
}

+ (NSDictionary *)signinDictionaryWithSGDeviceInfo:(SGPDeviceInfo *)di {
    NSDictionary *signin = @{@"cpu":    di.cpuSubtype,
                             @"brand":  @"Apple",
                             @"model":  di.deviceName,
                             @"resolution": di.resolution,
                             @"osName": di.osName,
                             @"osVer":  di.systemVersion,
                             @"lang":   di.languageCode,
                             @"country":di.countryCode,
                             @"appName":di.bundeIdentifier,
                             @"appVer": di.bundleVersion,
                             @"sdk":    di.clientSdk,
                             @"softId": di.softId
                             };
    return signin;
}

+ (NSString *)signinStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config {
    long long now = [self currentMillisecondTs];
    NSNumber *nowTime = [NSNumber numberWithLongLong:now];//millisecond
    NSString *network = [self networkingStates];
    NSString *stringQuery = [NSString stringWithFormat:@"?appId=%@&channel=%@&network=%@&udId=%@&ts=%@", config.clientId, config.channelId, network, config.appUdid, nowTime];
    return stringQuery;
}

+ (NSString *)eventsStringQueryWithSGAnalyticsConfig:(SGAnalyticsConfig *)config {
    long long now = [self currentMillisecondTs];
    NSNumber *nowTime = [NSNumber numberWithLongLong:now];//millisecond
    
    NSString *network = [self networkingStates];
    NSString *stringQuery = [NSString stringWithFormat:@"?appId=%@&channel=%@&network=%@&udId=%@&ts=%@&token=%@&appVer=%@&osName=IOS&sdk=%@",config.clientId, config.channelId, network, config.appUdid, nowTime, config.appToken, config.appVersion, kClientSdkVersion];
    return stringQuery;
}

#pragma mark - utils
+ (NSDate *)dateLastHour:(NSDate *)now {
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

+ (NSString *)getFullFilename:(NSString *)baseFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:baseFilename];
    return filename;
}

+ (BOOL)isNull:(id)value {
    return value == nil || value == (id)[NSNull null];
}

+ (BOOL)isNotNull:(id)value {
    return value != nil && value != (id)[NSNull null];
}

+ (BOOL)validateString:(NSString*)stringToSearch withRegex:(NSString*)regexString {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF matches %@", regexString];
    return [regex evaluateWithObject:stringToSearch];
}

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName
           class:(Class) classToRead
{
    id<SGPLogger> logger = SGPAnalyticsFactory.logger;
    @try {
        NSString *fullFilename = [SGPUtilities getFullFilename:filename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:fullFilename];
        if ([object isKindOfClass:classToRead]) {
            [logger debug:@"Read %@: %@", objectName, object];
            return object;
        } else if (object == nil) {
            [logger verbose:@"%@ file not found", objectName];
        } else {
            [logger error:@"Failed to read %@ file", objectName];
        }
    } @catch (NSException *ex ) {
        [logger error:@"Failed to read %@ file (%@)", objectName, ex];
    }
    
    return nil;
}

+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName {
    id<SGPLogger> logger = SGPAnalyticsFactory.logger;
    NSString *fullFilename = [SGPUtilities getFullFilename:filename];
    BOOL result = [NSKeyedArchiver archiveRootObject:object toFile:fullFilename];
    if (result == YES) {
        [SGPUtilities excludeFromBackup:fullFilename];
        [logger debug:@"Wrote %@: %@", objectName, object];
    } else {
        [logger error:@"Failed to write %@ file", objectName];
    }
}

// inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<SGPLogger> logger = SGPAnalyticsFactory.logger;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    if (&NSURLIsExcludedFromBackupKey == nil) {
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result != 0) {
            [logger debug:@"Failed to exclude '%@' from backup", url.lastPathComponent];
        }
    } else { // iOS 5.0 and higher
        // First try and remove the extended attribute if it is present
        ssize_t result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                [logger debug:@"Removed extended attribute on file '%@'", url];
            }
        }
        
        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        if (!success || error != nil) {
            [logger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
        }
    }
#pragma clang diagnostic pop
    
}

+ (NSString *)secondsNumberFormat:(double)seconds {
    if (secondsNumberFormatter == nil) {
        secondsNumberFormatter = [[NSNumberFormatter alloc] init];
        [secondsNumberFormatter setPositiveFormat:@"0.0"];
    }
    
    // normalize negative zero
    if (seconds < 0) {
        seconds = seconds * -1;
    }
    
    return [secondsNumberFormatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
}

+ (double)randomInRange:(double) minRange maxRange:(double) maxRange {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand48(arc4random());
    });
    
    double random = drand48();
    double range = maxRange - minRange;
    double scaled = random  * range;
    double shifted = scaled + minRange;
    return shifted;
}

#pragma mark - keyChain
+ (void)setSgAnaliyticsUuid:(NSString *)uuid token:(NSString *)token{
    [SGPKeychain setPassword:uuid forService:KEY_KEYCHAIN_SERVICE_UUID account:KEY_KEYCHAIN_SERVICE_UUID];
    [SGPKeychain setPassword:token forService:KEY_KEYCHAIN_SERVICE_TOKEN account:KEY_KEYCHAIN_SERVICE_TOKEN];
}

+ (void)deleteSgAnaliyticsUuidAndToken{
    if ([self sgAnaliyticsUuid]) {
        [SGPKeychain deletePasswordForService:KEY_KEYCHAIN_SERVICE_UUID account:KEY_KEYCHAIN_SERVICE_UUID];
    }
    if ([self sgAnaliyticsToken]) {
        [SGPKeychain deletePasswordForService:KEY_KEYCHAIN_SERVICE_TOKEN account:KEY_KEYCHAIN_SERVICE_TOKEN];
    }
}

+ (void)setSgAnaliyticsUuid:(NSString *)uuid{
    [SGPKeychain setPassword:uuid forService:KEY_KEYCHAIN_SERVICE_UUID account:KEY_KEYCHAIN_SERVICE_UUID];
}

+ (void)setSgAnaliyticsToken:(NSString *)token{
    [SGPKeychain setPassword:token forService:KEY_KEYCHAIN_SERVICE_TOKEN account:KEY_KEYCHAIN_SERVICE_TOKEN];
}

+ (NSString *)sgAnaliyticsUuid{
    return [SGPKeychain passwordForService:KEY_KEYCHAIN_SERVICE_UUID account:KEY_KEYCHAIN_SERVICE_UUID];
}

+ (NSString *)sgAnaliyticsToken{
    return [SGPKeychain passwordForService:KEY_KEYCHAIN_SERVICE_TOKEN account:KEY_KEYCHAIN_SERVICE_TOKEN];
}

@end
