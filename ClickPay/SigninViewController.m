//
//  SigninViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/21/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>

#import "SigninViewController.h"
#import "SignUpViewController.h"
#import "ContainerViewController.h"
#import "SVProgressHUD.h"
#import "CDPickerViewController.h"
#import "AuthAPIClient.h"
#import "CredentialStore.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SigninViewController ()
@property (nonatomic, strong) NSDictionary *codeDict;
@property (nonatomic, strong) NSArray *codes;
@property (nonatomic, strong) CredentialStore *credentialStore;
@end

@implementation SigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.credentialStore = [[CredentialStore alloc] init];
    
    [self.bottomView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    [self.signupButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"button-green"]]];
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.tintColor = [UIColor whiteColor];
    [self.signinButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"button-main"]]];
    self.signinButton.layer.cornerRadius = 5;
    self.signinButton.tintColor = [UIColor whiteColor];
    [self.forgotButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"button-orange"]]];
    self.forgotButton.layer.cornerRadius = 5;
    self.forgotButton.tintColor = [UIColor whiteColor];
    
    // Detecting user's default dialling code in current country
    {
        CTTelephonyNetworkInfo *network_Info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [network_Info subscriberCellularProvider];
        NSString *ISOCountryCode = [carrier isoCountryCode];
        
        // Instantiate the source plist file for country code dictionary
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DC" ofType:@"plist"];
        self.codeDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        // Moving all keys into an array and filter it with NSPredicate
        self.codes = [self.codeDict allKeys];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches[cd] %@", ISOCountryCode];
        self.codes = [self.codes filteredArrayUsingPredicate:predicate];
        
        NSString __autoreleasing *code = (!TARGET_IPHONE_SIMULATOR) ? [NSString stringWithFormat:@"%@", [self.codeDict objectForKey:[self.codes objectAtIndex:0]]] : @"886";
        self.countryCodeLabel.text = [NSString stringWithFormat:@"+%@", code];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signinButtonPressed:(id)sender {
    
    [self.pinTextField resignFirstResponder];
    
    [SVProgressHUD show];
    
    NSString *countryCode = [[NSString alloc] initWithFormat:@"%@", self.countryCodeLabel.text];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *number = [formatter numberFromString:[NSString stringWithFormat:@"%@", self.phoneTextField.text]];
    NSString *phoneNumber = [countryCode stringByAppendingString:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:number]]];
    NSString *pinCode = [NSString stringWithFormat:@"%@", self.pinTextField.text];
    
    NSDictionary *param = @{
        @"phone": phoneNumber,
        @"pin": pinCode
    };
    
    [[AuthAPIClient sharedClient] POST:@"/account/signin"
                            parameters:param
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSString *authToken = [responseObject objectForKey:@"auth_token"];
                                   [self.credentialStore setAuthToken:authToken];
                                   NSLog(@"%@", authToken);
                                   [self dismissViewControllerAnimated:YES completion:^{
                                       [SVProgressHUD dismiss];
                                   }];
                                   
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

- (IBAction)switchModeButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SignUpViewController *signupView = (SignUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SignUpView"];
    ContainerViewController *containerController = (ContainerViewController *) self.parentViewController;
    containerController.navigationItem.title = @"Sign Up";
    [containerController presentViewController:signupView];
}

- (IBAction)countryCodePickerPressed:(id)sender {
    CDPickerViewController *cdPicker = (CDPickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CDPickerView"];
    cdPicker.cdDelegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cdPicker];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didselectWith:(CDPickerViewController *)controller withCode:(NSString *)code {
    _countryCodeLabel.text = code;
    
    if (![[controller presentedViewController] isBeingDismissed]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
