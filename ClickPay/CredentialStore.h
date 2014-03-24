//
//  CredentialStore.h
//  ClickPay
//
//  Created by Thomas Lin on 3/23/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;

@end
