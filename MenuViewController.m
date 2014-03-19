//
//  MenuViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"
#import "SignUpViewController.h"
#import "UIImage+ImageEffects.h"
#import "BlurryModalSegue.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


const CGFloat PanelHeight = 400.0;

@interface MenuViewController ()

@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIImage *blurImage;
@property (nonatomic, strong) UIImageView *blurImageView;

@end

@implementation MenuViewController

@synthesize menuDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *fontHelveticaNeue = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:28];
    [self.view setTintColor:[UIColor whiteColor]];
    [_homeButton.titleLabel setFont:fontHelveticaNeue];
    [_accountButton.titleLabel setFont:fontHelveticaNeue];
    [_walletButton.titleLabel setFont:fontHelveticaNeue];
    
    _homeButton.contentHorizontalAlignment =
    _accountButton.contentHorizontalAlignment =
    _walletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    UIButton *homeButton = sender;
    switch (homeButton.tag) {
        case 100: {
            [menuDelegate didSelectWith:self withIdentifier:@"home"];
        }
            break;
        case 101: {
            [menuDelegate didSelectWith:self withIdentifier:@"account"];
        }
            break;
        case 102: {
            [menuDelegate didSelectWith:self withIdentifier:@"wallet"];
        }
            break;
        default:
            break;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
