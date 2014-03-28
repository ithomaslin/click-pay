//
//  SignUpViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/18/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>
#import <QuartzCore/QuartzCore.h>
#import "SignUpViewController.h"
#import "SigninViewController.h"
#import "ContainerViewController.h"
#import "ActivationViewController.h"
#import "CDPickerViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SignUpViewController ()

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSDictionary *codeDict;
@property (nonatomic, strong) NSArray *codes;
@property (nonatomic, copy) NSMutableArray *searchResults;

@end

@implementation SignUpViewController

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
    
    [self.bottomView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    self.signupButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"button-main"]];
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.tintColor = [UIColor whiteColor];
    self.loginButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"button-green"]];
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.tintColor = [UIColor whiteColor];
    
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
        
        NSString *code = (!TARGET_IPHONE_SIMULATOR) ? [NSString stringWithFormat:@"%@", [self.codeDict objectForKey:[self.codes objectAtIndex:0]]] : @"886";
        self.countryCodeLabel.text = [NSString stringWithFormat:@"+%@", code];
    }
}

- (void)filterCountryForTerm:(NSString *)term {
    [self.searchResults removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches[cd] %@", term];
    NSArray *results = [self.codes filteredArrayUsingPredicate:predicate];
    [self.searchResults addObjectsFromArray:results];
}

#pragma mark - Country code picker

- (IBAction)countryCodePicker:(id)sender {
    CDPickerViewController *cdPicker = (CDPickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CDPickerView"];
    cdPicker.cdDelegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cdPicker];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Sign up -

- (IBAction)signUpButtonPressed:(id)sender {
    
    [self.phoneTextField resignFirstResponder];
    
    if ([self.phoneTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your phone number can't be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [SVProgressHUD show];
        
        NSString *countryCode = [[NSString alloc] initWithFormat:@"%@", self.countryCodeLabel.text];
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *number = [formatter numberFromString:[NSString stringWithFormat:@"%@", self.phoneTextField.text]];
        NSString *phoneNumber = [countryCode stringByAppendingString:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:number]]];
        
        NSDictionary *param = @{@"phone": [NSString stringWithFormat:@"%@", phoneNumber]};
        NSLog(@"%@", phoneNumber);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"http://localhost:8000/account/signup"
           parameters:param
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [SVProgressHUD dismiss];
                  NSLog(@"%@", responseObject);
                  
                  NSString *message = [responseObject objectForKey:@"message"];
                  NSString *success = [responseObject objectForKey:@"success"];
                  
                  if ([success isEqualToString:@"YES"]) {
                      
                      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                      ActivationViewController *activationView = (ActivationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ActivationView"];
                      activationView.activationCode = message;
                      activationView.phoneNumber = phoneNumber;
                      [self.navigationController pushViewController:activationView animated:YES];
                      
                  } else {
                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OOPS!"
                                                                          message:message
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                      [alertView show];
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
    
}

- (IBAction)switchModePressed:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SigninViewController *signinView = (SigninViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SignInView"];
    ContainerViewController *containerController = (ContainerViewController *) self.parentViewController;
    containerController.navigationItem.title = @"Sign In";
    [containerController presentViewController:signinView];
    
}

- (void)didselectWith:(CDPickerViewController *)controller withCode:(NSString *)code {
    _countryCodeLabel.text = code;
    
    if (![[controller presentedViewController] isBeingDismissed]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    [super prepareForSegue:segue sender:sender];
//    
//    SigninViewController *signinView = segue.destinationViewController;
//    
//    signinView.transitioningDelegate = self;
//    signinView.modalPresentationStyle
//}

@end
