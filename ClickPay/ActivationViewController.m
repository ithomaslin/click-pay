//
//  ActivationViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/23/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "ActivationViewController.h"
#import "InfoRegisterViewController.h"
#import "AuthAPIClient.h"
#import "CredentialStore.h"
#import "SVProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ActivationViewController ()

@property (nonatomic, strong) CredentialStore *credentialStore;

@end

@implementation ActivationViewController

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
    
    NSLog(@"%@", self.phoneNumber);
    NSLog(@"%@", self.activationCode);
    
    self.navigationItem.title = @"Activation";
    
    [self.bottomView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    [self.activeButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"button-green"]]];
    self.activeButton.tintColor = [UIColor whiteColor];
    self.activeButton.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)activeAccount:(id)sender {
    if ([self.pintextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OOPS!"
                                                            message:@"You haven't entered your pin"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        
    } else {
        [SVProgressHUD show];
        
        NSDictionary *param = @{@"pin": self.pintextField.text};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://localhost:8000/account/activate/%@", self.activationCode]
           parameters:param
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [SVProgressHUD dismiss];
                  NSLog(@"%@", responseObject);
                  
                  NSString *message = [responseObject objectForKey:@"message"];
                  NSString *success = [responseObject objectForKey:@"success"];
                  
                  if ([success isEqualToString:@"YES"]) {
                      NSLog(@"success");
                      [SVProgressHUD showWithStatus:@"Logging you in..."];
                      [self performLoginPrecedure];
                  } else {
                      [SVProgressHUD showErrorWithStatus:message];
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

- (IBAction)requestNewPin:(id)sender {
    [SVProgressHUD show];
    NSDictionary *param = @{@"phone": self.phoneNumber};
    
    [[AuthAPIClient sharedClient] POST:[NSString stringWithFormat:@"/account/newpin/%@", self.activationCode]
                            parameters:param
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   [SVProgressHUD dismiss];
                                   NSLog(@"%@", responseObject);
                                   NSString *success = [responseObject objectForKey:@"success"];
                                   NSString *message = [responseObject objectForKey:@"message"];
                                   if ([success isEqualToString:@"YES"]) {
                                       self.activationCode = message;
                                   } else {
                                       [SVProgressHUD showErrorWithStatus:message];
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

- (void)performLoginPrecedure {
    NSDictionary *param = @{
                            @"phone": self.phoneNumber,
                            @"pin": self.pintextField.text
                            };
    
    [[AuthAPIClient sharedClient] POST:@"/account/signin"
                            parameters:param
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSLog(@"%@", responseObject);
                                   NSString *success = [responseObject objectForKey:@"success"];
                                   NSString *authToken = [responseObject objectForKey:@"auth_token"];
                                   NSString *message = [responseObject objectForKey:@"message"];
                                   
                                   if ([success isEqualToString:@"YES"]) {
                                       [self.credentialStore setAuthToken:authToken];
                                       NSLog(@"%@", authToken);
                                       [SVProgressHUD dismiss];
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                       InfoRegisterViewController *infoRegister = (InfoRegisterViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoRegisterView"];
                                       [self.navigationController pushViewController:infoRegister animated:YES];
                                   } else {
                                       [self dismissViewControllerAnimated:YES completion:^{
                                           [SVProgressHUD showErrorWithStatus:message];
                                       }];
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
