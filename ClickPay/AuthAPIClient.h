//
//  AuthAPIClient.h
//  ClickPay
//
//  Created by Thomas Lin on 3/24/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "AFNetworking.h"

@interface AuthAPIClient : AFHTTPSessionManager

+ (id)sharedClient;

@end
