//
//  ContainerViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/22/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "ContainerViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (id)initWithViewController:(UIViewController*)viewController{
    
    if(self = [super init]){
        self.currentViewController = viewController;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self addChildViewController: self.currentViewController];
    [self.view addSubview: self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//This function performs tha exchange between the CURRENT and the NEXT view
- (void)presentViewController:(UIViewController *)viewController{

    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:viewController];
    viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [viewController beginAppearanceTransition:YES animated:YES];
    
    
    UIImageView *currentView = [self takeScreenshot:self.view.layer];
    UIView *blackView = [self blackView];
    [blackView addSubview:currentView];
    
    CGRect oldFrame = [currentView.layer frame];
    currentView.layer.anchorPoint = CGPointMake(0,0.5);
    currentView.layer.frame = oldFrame;

    [self.currentViewController.view setHidden:YES];
    [self.view addSubview:viewController.view];
    
    UIImageView *nextView = [self takeScreenshot:self.view.layer];
    oldFrame = [nextView.layer frame];
    nextView.layer.anchorPoint = CGPointMake(0,0.5);
    nextView.layer.frame = oldFrame;
    nextView.frame = CGRectMake(-self.view.frame.size.width, 0, nextView.frame.size.width, nextView.frame.size.height);
    [blackView addSubview:nextView];
    [self.view addSubview:blackView];
    
    CATransform3D tp = CATransform3DIdentity;
    tp.m34 = 5.0/ -100;
    tp = CATransform3DTranslate(tp, -300.0f, -10.0f, 30.0f);
    tp = CATransform3DRotate(tp, radianFromDegree(20), 0.0f,1.0f, 0.8f);
    nextView.layer.transform = tp;
    nextView.layer.opacity = 0.0f;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         CATransform3D t = CATransform3DIdentity;
                         t.m34 = 1.0/ -500;
                         t = CATransform3DRotate(t, radianFromDegree(1.0f), 0.0f,0.0f, 1.0f);
                         t = CATransform3DTranslate(t, viewController.view.frame.size.width * 2, 0.0f, -10.0);
                         t = CATransform3DRotate(t, radianFromDegree(0), 1.0f,0.0f, 0.0f);
                         t = CATransform3DRotate(t, radianFromDegree(0), 1.0f,0.0f, 0.0f);
                         currentView.layer.transform = t;
                         currentView.layer.opacity = 0.0;
                         
                         //9d. Create transition for the NEXT view.
                         CATransform3D t2 = CATransform3DIdentity;
                         t2.m34 = 1.0/ -500;
                         t2 = CATransform3DTranslate(t2, viewController.view.frame.size.width, 0.0f, 0.0);
                         nextView.layer.transform = t2;
                         nextView.layer.opacity = 1.0;
                         
                     } completion:^(BOOL finished) {
                         [self.currentViewController beginAppearanceTransition:NO animated:YES];
                         [self.currentViewController.view removeFromSuperview];
                         [self.currentViewController removeFromParentViewController];
                         self.currentViewController = viewController;
                         [self.currentViewController didMoveToParentViewController:self];
                         [blackView removeFromSuperview];
                         
                     }];
    
    
    
}

- (UIView*)blackView{
    
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = UIColorFromRGB(0x0F8F8F8);
    return bgView;
}

- (UIImageView*)takeScreenshot:(CALayer*)layer{
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *screnshot = [[UIImageView alloc] initWithImage:image];
    
    return screnshot;
}



#pragma mark - Convert Degrees to Radian
double radianFromDegree(float degrees) {
    return (degrees / 180) * M_PI;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
