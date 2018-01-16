//
//  SGPLogger.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-11-15.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "SGPLogger.h"

static NSString * const kLogTag = @"SGAnalytiscs";

@interface SGPLogger()

@property (nonatomic, assign) SGPLogLevel loglevel;

@end

#pragma mark -
@implementation SGPLogger


- (void)setLogLevel:(SGPLogLevel)logLevel {
    self.loglevel = logLevel;
}

- (void)verbose:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

- (void)assert:(NSString *)format, ... {
    if (self.loglevel > SGPLogLevelAssert) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"a" format:format parameters:parameters];
}

// private implementation
- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list)parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logLevel, line);
    }
}

+ (SGPLogLevel)LogLevelFromString:(NSString *)logLevelString {
    if ([logLevelString isEqualToString:@"verbose"])
        return SGPLogLevelVerbose;

    if ([logLevelString isEqualToString:@"debug"])
        return SGPLogLevelDebug;

    if ([logLevelString isEqualToString:@"info"])
        return SGPLogLevelInfo;

    if ([logLevelString isEqualToString:@"warn"])
        return SGPLogLevelWarn;

    if ([logLevelString isEqualToString:@"error"])
        return SGPLogLevelError;

    if ([logLevelString isEqualToString:@"assert"])
        return SGPLogLevelAssert;

    // default value if string does not match
    return SGPLogLevelInfo;
}

@end
