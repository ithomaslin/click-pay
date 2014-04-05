//
//  Utils.h
//  ClickPay
//
//  Created by Thomas Lin on 3/30/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void)customizeView:(UIView *)view;
+ (UIImage *)createGradientImageFromColor:(UIColor *)startColor toColor:(UIColor *)endColor withSize:(CGSize)size;

@end
