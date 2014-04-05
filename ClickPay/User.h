//
//  User.h
//  ClickPay
//
//  Created by Thomas Lin on 3/31/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSDictionary

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *dob;

@end
