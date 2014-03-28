//
//  WalletViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/26/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface WalletViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, detailDelegate>

@property (nonatomic, retain) NSMutableArray *results;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
