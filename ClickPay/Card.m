//
//  Card.m
//  ClickPay
//
//  Created by Thomas Lin on 3/26/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    
    if (self) {
        self.cardName = [otherDictionary objectForKey:@"name"];
        self.fourDigits = [otherDictionary objectForKey:@"last4"];
        self.expiry = [otherDictionary objectForKey:@"expiry"];
        self.isDeafult = [[otherDictionary objectForKey:@"default"] intValue];
        self.cardID = [[otherDictionary objectForKey:@"id"] intValue];
    }
    
    return self;
}

@end
