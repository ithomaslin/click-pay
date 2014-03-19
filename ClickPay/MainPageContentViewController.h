//
//  MainPageContentViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@property NSUInteger pageIndex;
@property NSString *imageFile;
@property NSString *titleText;
@property NSString *subtitleText;

@end
