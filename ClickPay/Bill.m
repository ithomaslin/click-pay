//
//  Bill.m
//  ClickPay
//
//  Created by Thomas Lin on 4/4/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "Bill.h"

@implementation Bill

- (id)initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        self.name = [jsonDictionary objectForKey:@"name"];
        self.price = [jsonDictionary objectForKey:@"price"];
        self.paid = [[jsonDictionary objectForKey:@"paid"] intValue];
        self.itemId = [[jsonDictionary objectForKey:@"id"] intValue];
        self.billId = [[jsonDictionary objectForKey:@"bill_id"] intValue];
    }
    return self;
}

@end
