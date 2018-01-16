//
//  SGPLogger.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-11-15.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SGPAnalyticsConstants.h"


// A simple logger with multiple log levels.
@protocol SGPLogger

- (void)setLogLevel:(SGPLogLevel)logLevel;

- (void)verbose:(NSString *)message, ...;
- (void)debug:  (NSString *)message, ...;
- (void)info:   (NSString *)message, ...;
- (void)warn:   (NSString *)message, ...;
- (void)error:  (NSString *)message, ...;
- (void)assert: (NSString *)message, ...;

@end

@interface SGPLogger : NSObject <SGPLogger>

+ (SGPLogLevel) LogLevelFromString: (NSString *) logLevelString;

@end
