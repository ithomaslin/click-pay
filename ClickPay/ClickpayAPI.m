//
//  ClickpayAPI.m
//  ClickPay
//
//  Created by Thomas Lin on 4/3/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "ClickpayAPI.h"

#define API_KEY @"EKtwZAawXvanSUH2WLZZOIz1rVJSphN7"
#define APP_SECRET @"ycRS9va4KNKgXfCFBhmBS4NUBZh0YazbO36HUG41xX9eQZQNEQk7kdO3T7mcuPW4"
#define API_BASE_URL @"http://localhost:8888"

@implementation ClickpayAPI

+ (id)sharedAPIManager {
    static ClickpayAPI *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:API_BASE_URL];
        __instance = [[ClickpayAPI alloc] initWithBaseURL:baseUrl];
    });
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self setAPIHeader];
        
    }
    return self;
}

- (void)setAPIHeader {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", API_KEY, APP_SECRET];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    [self.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
}

@end
