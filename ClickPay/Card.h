//
//  Card.h
//  ClickPay
//
//  Created by Thomas Lin on 3/26/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 {
 "card_name" = "My Black American Express Card";
 "created_at" = "2014-03-25 08:51:28";
 "credit_card" = 1234098767852345;
 default = 0;
 expiry = "2022-10-19";
 id = 5;
 "updated_at" = "2014-03-25 08:51:28";
 "user_id" = 24;
 }
 
 */

@interface Card : NSDictionary

@property (nonatomic, copy) NSString *cardName;
@property (nonatomic, copy) NSString *fourDigits;
@property (nonatomic, copy) NSString *expiry;
@property (nonatomic) int isDeafult;
@property (nonatomic) int cardID;

@end
