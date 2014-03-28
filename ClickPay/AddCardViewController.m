//
//  AddCardViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "AddCardViewController.h"
#import "SVProgressHUD.h"
#import "AuthAPIClient.h"
#import "Stripe.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AddCardViewController ()
@property (strong, nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UISwitch *switchDefault;

@end

@implementation AddCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.navigationItem.title = @"Add new card";
    
    // Geting stripe view ready...
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(15,100,290,55)
                                              andKey:@"pk_test_b6gk5XZ16S2SyAdPXLGcHcTW"];
    [self.stripeView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
    
    // Other information that we need
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(22, 170, 71, 30)];
    labelName.text = @"Name";
    labelName.textColor = UIColorFromRGB(0x05C75E1);
    [self.view addSubview:labelName];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 170, 200, 30)];
    self.nameTextField.placeholder = @"e.g. My Master Card";
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameTextField];
    
    UILabel *labelDefault = [[UILabel alloc] initWithFrame:CGRectMake(22, 230, 71, 31)];
    labelDefault.text = @"Default";
    labelDefault.textColor = UIColorFromRGB(0x05C75E1);
    [self.view addSubview:labelDefault];
    
    self.switchDefault = [[UISwitch alloc] initWithFrame:CGRectMake(245, 230, 51, 31)];
    self.switchDefault.backgroundColor = UIColorFromRGB(0x0e74c3c);
    self.switchDefault.layer.cornerRadius = 16.0;
    self.switchDefault.on = NO;
    [self.view addSubview:self.switchDefault];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(dismissKeyboard:)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:self
                                                                               action:nil];
    toolbar.items = [[NSArray alloc] initWithObjects:flexSpace, doneButton, nil];
    
    self.nameTextField.inputAccessoryView = toolbar;
}

- (void)dismissKeyboard:(id)sender {
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    } else {
        [self.stripeView.paymentView resignFirstResponder];
    }
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    self.saveButton.enabled = valid;
}

- (void)save:(id)sender
{
    if ([self.nameTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS!"
                                                        message:@"The name can't be empty"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // Call 'createToken' when the save button is tapped
        [self.stripeView createToken:^(STPToken *token, NSError *error) {
            if (error) {
                // Handle error
                [self handleError:error];
            } else {
                // Send off token to your server
                [self handleToken:token];
            }
        }];
    }
}

- (void)handleError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)handleToken:(STPToken *)token
{
    [SVProgressHUD showWithStatus:@"Adding your card..."];
    NSString *expMonth = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)token.card.expMonth];
    NSString *expYear = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)token.card.expYear];
    NSString *def = (self.switchDefault.on) ? @"YES" : @"NO";
    
    NSDictionary *param = @{
                            @"token":       token.tokenId,
                            @"last4":       token.card.last4,
                            @"expMonth":    expMonth,
                            @"expYear":     expYear,
                            @"name":        self.nameTextField.text,
                            @"default":     def
                            };
    
    [[AuthAPIClient sharedClient] POST:@"/wallet"
                            parameters:param
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSLog(@"%@", responseObject);
                                   NSString *success = [responseObject objectForKey:@"success"];
                                   NSString *message = [responseObject objectForKey:@"message"];
                                   if ([success isEqualToString:@"YES"]) {
                                       [SVProgressHUD showWithStatus:message];
                                       [self.navigationController popViewControllerAnimated:YES];
                                   } else {
                                       NSLog(@"OOPS!!");
                                       
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   if (operation.response.statusCode == 500) {
                                       [SVProgressHUD showErrorWithStatus:@"Something went worng"];
                                   } else {
                                       NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:&error];
                                       
                                       NSString *errorMessage = [json objectForKey:@"error"];
                                       [SVProgressHUD showErrorWithStatus:errorMessage];
                                   }
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

@end