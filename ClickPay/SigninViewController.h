//
//  SigninViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/21/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDPickerViewController.h"

@interface SigninViewController : UIViewController
<CDPickerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *pinTextField;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotButton;


- (IBAction)signinButtonPressed:(id)sender;
- (IBAction)switchModeButtonPressed:(id)sender;
- (IBAction)countryCodePickerPressed:(id)sender;


@end
