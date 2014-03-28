//
//  WalletViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/26/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "WalletViewController.h"
#import "DetailViewController.h"
#import "AddCardViewController.h"
#import "SVProgressHUD.h"
#import "AuthAPIClient.h"
#import "Card.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WalletViewController ()

@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation WalletViewController

- (void)refresh {
    [self.results removeAllObjects];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, backgroundQueue, ^{
        [[AuthAPIClient sharedClient] GET:@"/wallet"
                               parameters:nil
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      NSMutableArray *results = [NSMutableArray array];
                                      for (id cardDictionary in [responseObject objectForKey:@"card"]) {
                                          Card *card = [[Card alloc] initWithDictionary:cardDictionary];
                                          [results addObject:card];
                                      }
                                      self.results = results;
                                      [self.tableView reloadData];
                                      [SVProgressHUD dismiss];
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      
                                  }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Wallet";
    [self.tableView setBackgroundColor:UIColorFromRGB(0x0F8F8F8)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UIBarButtonItem *addCardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewCard)];
    self.navigationItem.rightBarButtonItem = addCardButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = UIColorFromRGB(0x0139DEB);
    [self.refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [SVProgressHUD showWithStatus:@"Getting your wallet..." maskType:SVProgressHUDMaskTypeClear];
    [self refresh];
}

- (void)addNewCard {
    AddCardViewController *addCard = [[AddCardViewController alloc] init];
    [self.navigationController pushViewController:addCard animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
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
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = UIColorFromRGB(0x0F8F8F8);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = UIColorFromRGB(0x05B6FE7);
    }
    
    Card *card = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = card.cardName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Ending with: %@", card.fourDigits];
    
    return cell;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"CellDetail" sender:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CellDetail"]) {
        DetailViewController *detailView = [segue destinationViewController];
        detailView.detailDelegate = self;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Card *card = [self.results objectAtIndex:indexPath.row];
        detailView.name = card.cardName;
        detailView.number = card.fourDigits;
        detailView.exp = card.expiry;
        detailView.isDefault = (card.isDeafult == 1) ? YES : NO;
        detailView.cardID = card.cardID;
    }
}

#pragma mark - Delegate

- (void)didUpdateWith:(DetailViewController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD showWithStatus:@"Updating..."];
    [self refresh];
}

@end
