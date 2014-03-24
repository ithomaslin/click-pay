//
//  ContainerViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/22/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) UIViewController *currentViewController;

- (id)initWithViewController:(UIViewController*)viewController;
- (void)presentViewController:(UIViewController *)viewController;

@end
