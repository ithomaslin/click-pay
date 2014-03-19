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
<CDPickerDelegate>

- (IBAction)countryCodePicker:(id)sender;
- (IBAction)modeSwitchPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UIButton *countryCode;
@property (strong, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *modeSwitchButton;

@end
