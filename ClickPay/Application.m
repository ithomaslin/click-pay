//
//  Application.m
//  ClickPay
//
//  Created by Thomas Lin on 3/24/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "Application.h"

@implementation Application

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)currentBuild {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)versionBuild {
    NSString *version = [self appVersion];
    NSString *build = [self currentBuild];
    
    NSString *versionBuild = [NSString stringWithFormat:@"v%@", version];
    
    if (![version isEqualToString:build]) {
        versionBuild = [NSString stringWithFormat:@"%@(%@)", versionBuild, build];
    }
    return versionBuild;
}

@end
