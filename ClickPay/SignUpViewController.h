//
//  SignUpViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/18/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDPickerViewController.h"

@interface SignUpViewController : UIViewController
<UIViewControllerTransitioningDelegate, CDPickerDelegate>

- (IBAction)countryCodePicker:(id)sender;
- (IBAction)signUpButtonPressed:(id)sender;
- (IBAction)switchModePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UIButton *countryCode;
@property (strong, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end
