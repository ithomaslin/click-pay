//
//  MenuViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/16/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuViewController;
@protocol menuDelegate <NSObject>
@required
- (void)didSelectWith:(MenuViewController *)controller withIdentifier:(NSString *)identifier;
@end

@interface MenuViewController : UIViewController
{
    __weak id<menuDelegate>menuDelegate;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@property (strong, nonatomic) IBOutlet UIButton *walletButton;

- (IBAction)buttonPressed:(id)sender;

@property (nonatomic, weak) id<menuDelegate>menuDelegate;

@end
