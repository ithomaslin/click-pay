//
//  AddCardViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCardViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *creditCardField;

- (IBAction)creditCardCheck:(id)sender;
@end
