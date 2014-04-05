//
//  UIColor+Alpha.h
//  ClickPay
//
//  Created by Thomas Lin on 3/30/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Alpha)

- (UIColor *)colorByChangingAlpha:(CGFloat)alpha;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (NSString *)stringFromUIColor:(UIColor *)color;
+ (UIColor *)colorFromNSString:(NSString *)string;

@end
