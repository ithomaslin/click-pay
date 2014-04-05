//
//  User.m
//  ClickPay
//
//  Created by Thomas Lin on 3/31/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    if ([self init]) {
        self.name = [otherDictionary objectForKey:@"name"];
        self.email = [otherDictionary objectForKey:@"email"];
        self.countryCode = [otherDictionary objectForKey:@"country_code"];
        self.phone = [otherDictionary objectForKey:@"phone"];
        self.dob = [otherDictionary objectForKey:@"dob"];
    }
    return self;
}

@end
