//
//  MenuViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface MenuViewController : UIViewController <RESideMenuDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@property (strong, nonatomic) IBOutlet UIButton *walletButton;

- (IBAction)buttonPressed:(id)sender;

@end
