//
//  MyBillViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/24/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBillViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *bedgeIdentifier;
@property (nonatomic, retain) NSMutableArray *billArray;

@end
