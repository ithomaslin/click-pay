//
//  ActivationViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/23/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *pintextField;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *activeButton;
@property (strong, nonatomic) NSString *activationCode;
@property (strong, nonatomic) NSString *phoneNumber;

- (IBAction)activeAccount:(id)sender;
- (IBAction)requestNewPin:(id)sender;
@end
