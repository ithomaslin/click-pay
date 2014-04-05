//
//  ViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainPageContentViewController.h"
#import "RESideMenu.h"

@interface ViewController : UIViewController
<UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIPageViewControllerDataSource,
RESideMenuDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageSubtitles;

- (IBAction)addTablePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *addTableButton;

@end
