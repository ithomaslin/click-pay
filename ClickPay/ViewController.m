//
//  ViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "DropAnimationController.h"
#import "ZoomAnimationController.h"
#import "ADVAnimationController.h"
#import "MenuViewController.h"
#import "AccountViewController.h"
#import "WalletViewController.h"
#import "SignUpViewController.h"
#import "AFNetworking.h"
#import "ContainerViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import "CredentialStore.h"
#import "ScanningViewController.h"
#import "RESideMenu.h"

@interface ViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;

@property (nonatomic, strong) CredentialStore *credentialStore;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    // Prepare the requireed custom settings
    UIColor* color0 = [UIColor colorWithRed: 0.076 green: 0.615 blue: 0.92 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIFont *fontCarda = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:30];
    
	[self.navigationController setNavigationBarHidden:YES];
    [_menuButton setImage:[UIImage imageNamed:@"button-menu.png"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(showMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    _addTableButton.titleLabel.font = fontCarda;
    [_addTableButton setTitleColor:color1 forState:UIControlStateNormal];
    [_addTableButton setBackgroundColor:color0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showMenuViewController:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MenuViewController *menuViewController = (MenuViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    menuViewController.menuDelegate = self;
    self.animationController = [[ZoomAnimationController alloc] init];
    menuViewController.transitioningDelegate = self;
    [self presentViewController:menuViewController animated:YES completion:nil];
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

- (void)didSelectWith:(MenuViewController *)controller withIdentifier:(NSString *)identifier {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SignUpViewController *signUpView = (SignUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SignUpView"];
    
    if ([identifier isEqualToString:@"account"]) {
        if (![[controller presentedViewController] isBeingDismissed]) {
            [controller dismissViewControllerAnimated:YES completion:^{
                if (![self.credentialStore isLoggedIn]) {
                    [self willRequireDropAnimationWith:signUpView];
                } else {
                    AccountViewController *accountView = (AccountViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AccountView"];
                    [self.navigationController pushViewController:accountView animated:YES];
                }
            }];
        }
    } else if ([identifier isEqualToString:@"wallet"]) {
        if (![[controller presentedViewController] isBeingDismissed]) {
            [controller dismissViewControllerAnimated:YES completion:^{
                if (![self.credentialStore isLoggedIn]) {
                    [self willRequireDropAnimationWith:signUpView];
                    
                } else {
                    WalletViewController *walletView = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WalletView"];
                    [self.navigationController pushViewController:walletView animated:YES];
                }
            }];
        }
    } else {
        if (![[controller presentedViewController] isBeingDismissed]) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)willRequireDropAnimationWith:(SignUpViewController *)controller {
    ContainerViewController *containerVC = [[ContainerViewController alloc] initWithViewController:controller];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:containerVC];
    containerVC.navigationItem.title = @"Sign Up";
    
    self.animationController = [[DropAnimationController alloc] init];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nav.transitioningDelegate = self;
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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
@end
