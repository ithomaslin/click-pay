//
//  ProfileViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/31/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface ProfileViewController : UITableViewController <RESideMenuDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UILabel *countryCode;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *dobField;
@property (nonatomic, retain) NSArray *result;

@end
