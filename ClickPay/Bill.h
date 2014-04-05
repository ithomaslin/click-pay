//
//  Bill.h
//  ClickPay
//
//  Created by Thomas Lin on 4/4/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bill : NSObject

- (id)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;
@property (nonatomic) int itemId;
@property (nonatomic) int billId;
@property (nonatomic) int paid;

@end
