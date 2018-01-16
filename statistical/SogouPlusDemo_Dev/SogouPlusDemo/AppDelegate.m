//
//  AppDelegate.m
//  SogouPlusDemo
//
//  Created by zhuqunye on 16/9/21.
//  Copyright © 2016年 zhuqunye. All rights reserved.
//

#import "AppDelegate.h"
#import <SogouPlus/SGPMobileClick.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SGConfigInstance.clientId = @"2063";
    SGConfigInstance.channelId = @"AppStore";
    SGConfigInstance.forTest = YES;
    [SGPMobileClick appDidLaunch:SGConfigInstance];
    
    return YES;
}

@end
