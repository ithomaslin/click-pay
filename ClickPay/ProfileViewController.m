//
//  ProfileViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/31/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "ProfileViewController.h"
#import "MenuViewController.h"
#import "CDPickerViewController.h"
#import "CredentialStore.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface ProfileViewController ()
{
    UIView *footerView;
}
@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, strong) CredentialStore *credentialStore;
@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.credentialStore = [[CredentialStore alloc] init];
    
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        self.tableView.scrollEnabled = NO;
    }
    self.navigationItem.title = @"Profile";
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation-btn-menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStyleBordered target:self action:@selector(logoutActionSheet)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
    [self fetchingUserData];
    
}

- (void)fetchingUserData {
    [[AuthAPIClient sharedClient] GET:@"/account/"
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  User *user = [[User alloc] initWithDictionary:[responseObject objectForKey:@"user"]];
                                  self.nameField.text = user.name;
                                  self.countryCode.text = user.countryCode;
                                  self.phoneField.text = user.phone;
                                  self.emailField.text = user.email;
                                  self.dobField.text = user.dob;
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                              }];
}

- (void)backToHome {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MenuViewController *menuViewController = (MenuViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [self presentLeftMenuViewController:menuViewController];
}

- (void)logoutActionSheet {
    UIActionSheet *logoutActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Log out"
                                                          otherButtonTitles:nil, nil];
    [logoutActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self logoutButtonPressed];
            break;
    }
}

- (void)logoutButtonPressed {
    [SVProgressHUD show];
    [[AuthAPIClient sharedClient] GET:@"/account/signout"
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self.credentialStore clearSavedCredentials];
                                  NSLog(@"%@", [self.credentialStore authToken]);
                                  [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Home"]]];
                                  [SVProgressHUD dismiss];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                              }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return footerView;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
