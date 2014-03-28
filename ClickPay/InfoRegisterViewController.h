//
//  InfoRegisterViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/28/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoRegisterViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *birthdayTextField;
@end
