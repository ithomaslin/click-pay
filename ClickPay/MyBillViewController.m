//
//  MyBillViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/24/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "MyBillViewController.h"
#import "SVProgressHUD.h"
#import "ClickpayAPI.h"
#import "Bill.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MyBillViewController ()

@property (nonatomic, copy) NSString *amountDue;
@property (nonatomic) int paid;
@property (nonatomic) UIRefreshControl *refreshController;

@end

@implementation MyBillViewController

- (void)refresh {
    [self.billArray removeAllObjects];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds *NSEC_PER_SEC);
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, backgroundQueue, ^{
        [[ClickpayAPI sharedAPIManager] GET:[NSString stringWithFormat:@"/v1/bill/%@", self.bedgeIdentifier]
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSDictionary *bill = [responseObject objectForKey:@"bill"];
                                        NSDictionary *billItem = [bill objectForKey:@"billitem"];
                                        
                                        self.amountDue = [NSString stringWithFormat:@"$%@", [bill objectForKey:@"amount_due"]];
                                        
                                        NSMutableArray *results = [NSMutableArray array];
                                        for (id item in billItem) {
                                            Bill *bill = [[Bill alloc] initWithJsonDictionary:item];
                                            [results addObject:bill];
                                        }
                                        self.billArray = results;
                                        [self.tableView reloadData];
                                        [SVProgressHUD dismiss];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"%@", error);
                                    }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshController endRefreshing];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(closeCurrentView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.bedgeIdentifier = @"G6aB0g";
    
    self.refreshController = [[UIRefreshControl alloc] init];
    self.refreshController.tintColor = UIColorFromRGB(0x03A78CA);
    [self.refreshController addTarget:self
                               action:@selector(refresh)
                     forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshController];
    
    [SVProgressHUD show];
    self.amountDue = @"loading...";
    [self refresh];
    
}

- (void)closeCurrentView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.billArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 90;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"Total amount: %@", self.amountDue];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGFloat headerHeight = 50.0;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, headerHeight)];
    headerView.backgroundColor = UIColorFromRGB(0x0F8F8F8);
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerHeight / 2, tableView.bounds.size.width, 40.0)];
    headerLabel.textColor = UIColorFromRGB(0x03A78CA);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    
    switch (section) {
        case 0:
            headerLabel.text = [NSString stringWithFormat:@"Amount to pay: %@", self.amountDue];
            break;
    }
    
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BillItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Bill *bill = [self.billArray objectAtIndex:indexPath.row];
    cell.textLabel.text = bill.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", bill.price];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textColor = UIColorFromRGB(0x04ADABF);
    
    return cell;
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
