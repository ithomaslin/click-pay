//
//  UIColor+Alpha.m
//  ClickPay
//
//  Created by Thomas Lin on 3/30/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "UIColor+Alpha.h"

@implementation UIColor (Alpha)

- (UIColor *)colorByChangingAlpha:(CGFloat)alpha {
    CGColorRef oldColor = CGColorCreateCopyWithAlpha([self CGColor], alpha);
    UIColor *newColor = [UIColor colorWithCGColor:oldColor];
    CGColorRelease(oldColor);
    
    return newColor;
}

- (UIColor *)lighterColor {
    CGFloat hue, saturation, bright, alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&bright alpha:&alpha]) {
        return  [UIColor colorWithHue:hue
                           saturation:saturation
                           brightness:MIN(bright * 1.3, 1.0)
                                alpha:alpha];
    }
    return nil;
}

- (UIColor *)darkerColor {
    CGFloat hue, saturation, bright, alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&bright alpha:&alpha]) {
        return  [UIColor colorWithHue:hue
                           saturation:saturation
                           brightness:bright * 0.9
                                alpha:alpha];
    }
    return nil;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *hex = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) {
        return nil;
    }
    return [self colorWithRGBHex:hexNum];
}

+ (NSString *)stringFromUIColor:(UIColor *)color {
    return [NSString stringWithFormat:@"%@", color];
}

+ (UIColor *)colorFromNSString:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    NSArray *values = [string componentsSeparatedByString:@" "];
    CGFloat red = [[values objectAtIndex:1] floatValue];
    CGFloat green = [[values objectAtIndex:2] floatValue];
    CGFloat blue = [[values objectAtIndex:3] floatValue];
    CGFloat alpha = [[values objectAtIndex:4] floatValue];
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return color;
}

@end

