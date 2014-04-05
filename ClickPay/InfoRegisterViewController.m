//
//  InfoRegisterViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/28/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "InfoRegisterViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import "CredentialStore.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface InfoRegisterViewController ()
@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, strong) CredentialStore *credentialStore;

@end

@implementation InfoRegisterViewController

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
    self.credentialStore = [[CredentialStore alloc] init];
    self.navigationController.navigationBarHidden = NO;
    
    if ([self.credentialStore isLoggedIn]) {
        NSLog(@"YES");
    } else {
        NSLog(@"NO");
    }
    
    [self.tableView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveInfo:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.picker = [[UIDatePicker alloc] init];
    self.picker.datePickerMode = UIDatePickerModeDate;
    [self.birthdayTextField setInputView:self.picker];
    
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
    
    
    self.birthdayTextField.inputAccessoryView =
    self.nameTextField.inputAccessoryView =
    self.emailTextField.inputAccessoryView = toolbar;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)saveInfo:(id)sender {
    if ([self.nameTextField.text isEqualToString:@""]) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"OOPS!"
                                                          message:@"Your name can't be blank"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil];
        [alert1 show];
    } else if ([self.emailTextField.text isEqualToString:@""]) {
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"OOPS!"
                                                         message:@"Your email can't be blank"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
        [alert2 show];
    } else {
        [SVProgressHUD showWithStatus:@"Updating your detail..."];
        
        
        NSDictionary *param = @{
                                @"name": self.nameTextField.text,
                                @"email": self.emailTextField.text,
                                @"dob": self.birthdayTextField.text
                                };
        NSLog(@"%@", param);
        
        [[AuthAPIClient sharedClient] POST:@"/account/register"
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSLog(@"%@", responseObject);
                                       NSString *success = [responseObject objectForKey:@"success"];
                                       NSString *message = [responseObject objectForKey:@"message"];
                                       
                                       if ([success isEqualToString:@"YES"]) {
                                           NSLog(@"%@", message);
                                           [self dismissViewControllerAnimated:YES completion:^{
                                               [SVProgressHUD dismiss];
                                           }];
                                       } else {
                                           NSLog(@"%@", message);
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

- (void)dismissKeyboard:(id)sender {
    if ([self.birthdayTextField isFirstResponder]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        self.picker = (UIDatePicker *)self.birthdayTextField.inputView;
        self.birthdayTextField.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.picker.date]];
        [self.birthdayTextField resignFirstResponder];
        
    } else if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    } else {
        [self.emailTextField resignFirstResponder];
    }
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
    return 3;
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
