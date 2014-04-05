//
//  MenuViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"
#import "DropAnimationController.h"
#import "SigninViewController.h"
#import "SignUpViewController.h"
#import "BlurryModalSegue.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "AuthAPIClient.h"
#import "CredentialStore.h"
#import "ContainerViewController.h"
#import "InfoViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

const CGFloat PanelHeight = 400.0;

@interface MenuViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property (nonatomic, strong) CredentialStore *credentialStore;
@property (nonatomic, strong) UIButton *logoutButton;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"billow"]]];
    self.credentialStore = [[CredentialStore alloc] init];
    
    UIFont *fontHelveticaNeue = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:28];
    [self.view setTintColor:[UIColor whiteColor]];
    [_homeButton.titleLabel setFont:fontHelveticaNeue];
    [_accountButton.titleLabel setFont:fontHelveticaNeue];
    [_walletButton.titleLabel setFont:fontHelveticaNeue];
    
    _homeButton.contentHorizontalAlignment =
    _accountButton.contentHorizontalAlignment =
    _walletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SignUpViewController *signUpView = (SignUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SignUpView"];
    
    switch (homeButton.tag) {
        case 100: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Home"]]];
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
        case 101: {
            if ([self.credentialStore isLoggedIn]) {
                [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AccountView"]]];
            } else {
                [self willRequireDropAnimationWith:signUpView];
            }
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
        case 102: {
            if ([self.credentialStore isLoggedIn]) {
                [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"WalletView"]]];
            } else {
                [self willRequireDropAnimationWith:signUpView];
            }
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
    }
    
}

- (void)willRequireDropAnimationWith:(SignUpViewController *)controller {
    ContainerViewController *containerVC = [[ContainerViewController alloc] initWithViewController:controller];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:containerVC];
    containerVC.navigationItem.title = @"Sign Up";
    
    [self presentViewController:nav animated:YES completion:nil];
}

@end
