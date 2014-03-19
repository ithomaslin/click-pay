//
//  SignUpViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/18/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "SignUpViewController.h"
#import "CDPickerViewController.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>
#import <QuartzCore/QuartzCore.h>

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
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
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

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didselectWith:(CDPickerViewController *)controller withCode:(NSString *)code {
    _countryCodeLabel.text = code;
    
    if (![[controller presentedViewController] isBeingDismissed]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)countryCodePicker:(id)sender {
    CDPickerViewController *cdPicker = (CDPickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CDPickerView"];
    cdPicker.cdDelegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cdPicker];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)modeSwitchPressed:(id)sender {
    
    [UIView animateWithDuration:1.0 animations:^{
        
    }];
    
    if ([self.navigationItem.title isEqualToString:@"Sign Up"]) {
        self.navigationItem.title = @"Login";
        _url = [NSURL URLWithString:@"/account/signin"];
    } else {
        self.navigationItem.title = @"Sign Up";
        _url = [NSURL URLWithString:@"/account/signup"];
    }
    NSLog(@"%@", _url);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
