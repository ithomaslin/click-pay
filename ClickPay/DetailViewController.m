//
//  DetailViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/27/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "DetailViewController.h"
#import "WalletViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DetailViewController ()
{
    UIView *footerView;
}

@end

@implementation DetailViewController

@synthesize detailDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(updateCardDetail:)];
    self.navigationItem.rightBarButtonItem = updateButton;
    
    self.navigationItem.title = @"Edit your card";
    self.cardNumber.text = [NSString stringWithFormat:@"xxxx-xxxx-xxxx-%@", self.number];
    self.expiryDate.text = [self.exp stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    self.cardName.text = self.name;
    self.switchDefault.on = (self.isDefault) ? YES : NO;
    
    NSLog(@"%@", [NSString stringWithFormat:@"/wallet/%d", self.cardID]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushBackToRootViewController {
    [detailDelegate didUpdateWith:self];
}

- (void)updateCardDetail:(id)sender {
    [SVProgressHUD show];
    
    NSString *switchValue = (self.switchDefault) ? @"YES" : @"NO";
    NSString *lastFourDigits = [self.cardNumber.text stringByReplacingOccurrencesOfString:@"xxxx-xxxx-xxxx-"
                                                                               withString:@""];
    NSDictionary *param = @{
                            @"name": self.cardName.text,
                            @"cardNumber": lastFourDigits,
                            @"default": switchValue,
                            @"expiry": self.expiryDate.text
                            };
    
    [[AuthAPIClient sharedClient] POST:[NSString stringWithFormat:@"/wallet/%d", self.cardID]
                            parameters:param
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSString *success = [responseObject objectForKey:@"success"];
                                   if ([success isEqualToString:@"YES"]) {
                                       [self pushBackToRootViewController];
                                   }
                                   [SVProgressHUD dismiss];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (footerView == nil) {
        footerView = [[UIView alloc] init];
        UIImage *image = [[UIImage imageNamed:@"button-delete"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton.layer setCornerRadius:20.0];
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [deleteButton setFrame:CGRectMake(10, 3, 300, 44)];
        [deleteButton setTitle:@"Delete this card" forState:UIControlStateNormal];
        [deleteButton setTintColor:[UIColor whiteColor]];
        [deleteButton addTarget:self action:@selector(cardDeletion) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView addSubview:deleteButton];
    }
    return footerView;
}

- (void)cardDeletion {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                    message:@"You're about to delete this card, continue?"
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
    [alert show];
}

@end
