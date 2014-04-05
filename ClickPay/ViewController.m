//
//  ViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ADVAnimationController.h"
#import "MenuViewController.h"
#import "SignUpViewController.h"
#import "AFNetworking.h"
#import "ContainerViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import "CredentialStore.h"
#import "ScanningViewController.h"
#import "RESideMenu.h"
#import "UIColor+Alpha.h"
#import "Utils.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property (nonatomic, strong) CredentialStore *credentialStore;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    NSString* color = [[NSUserDefaults standardUserDefaults] objectForKey:@"kBlurredGradientStartColor"];
    
    if (!color) {
        NSString* startColor = [UIColor stringFromUIColor:UIColorFromRGB(0x04CE4BE)];
        NSString* endColor = [UIColor stringFromUIColor:UIColorFromRGB(0x03869CC)];
        
        [[NSUserDefaults standardUserDefaults] setObject:startColor forKey:@"kBlurredGradientStartColor"];
        [[NSUserDefaults standardUserDefaults] setObject:endColor forKey:@"kBlurredGradientEndColor"];
    }
    [Utils customizeView:self.view];
    
    self.credentialStore = [[CredentialStore alloc] init];
    
    // Create the data model
    _pageTitles = @[@"Welcome to clickpay", @"Step 1: Scan code", @"Step 2: View your bill", @"Step 3: Pay", @""];
    _pageSubtitles = @[@"Swipe left to learn more", @"Check your table for a clickpay QR code", @"Confirm your bill, split or pay the total.", @"Pay your bill with your credit card.", @""];
    _pageImages = @[@"hello", @"scan", @"bill-check", @"secure-pay.png", @"bill-pay.png"];
    
    // Create page view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"PageView"];
    self.pageViewController.dataSource = self;
    
    MainPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 160);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    UIFont *font = [UIFont boldSystemFontOfSize:25];
	[self.navigationController setNavigationBarHidden:NO];
    [_menuButton setImage:[UIImage imageNamed:@"button-menu.png"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(showMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    _addTableButton.titleLabel.font = font;
    _addTableButton.layer.cornerRadius = 1;
    [_addTableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addTableButton setBackgroundColor:UIColorFromRGB(0x042C3AD)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showMenuViewController:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MenuViewController *menuViewController = (MenuViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [self presentLeftMenuViewController:menuViewController];
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [Utils customizeView:self.view];
}

- (MainPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    MainPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPageContent"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.subtitleText = self.pageSubtitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MainPageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MainPageContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)addTablePressed:(id)sender {
    
    if (![self.credentialStore isLoggedIn]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        SignUpViewController *signUpView = (SignUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SignUpView"];
        [self willRequireDropAnimationWith:signUpView];
    } else {
        [SVProgressHUD showWithStatus:@"Preparing your scanner..." maskType:SVProgressHUDMaskTypeGradient];
        ScanningViewController *scanView = [[ScanningViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanView];
        [self presentViewController:nav animated:YES completion:^{
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)willRequireDropAnimationWith:(SignUpViewController *)controller {
    ContainerViewController *containerVC = [[ContainerViewController alloc] initWithViewController:controller];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:containerVC];
    containerVC.navigationItem.title = @"Sign Up";
    
    [self presentViewController:nav animated:YES completion:nil];
}
@end
