//
//  DetailViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/27/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@protocol detailDelegate <NSObject>
- (void)didUpdateWith:(DetailViewController *)controller;
@end

@interface DetailViewController : UITableViewController
{
    __weak id<detailDelegate>detailDelegate;
}

@property (strong, nonatomic) IBOutlet UITextField *cardNumber;
@property (strong, nonatomic) IBOutlet UITextField *expiryDate;
@property (strong, nonatomic) IBOutlet UITextField *cardName;
@property (weak, nonatomic) IBOutlet UISwitch *switchDefault;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *exp;
@property (nonatomic) BOOL isDefault;
@property (nonatomic) int cardID;

@property (nonatomic, weak) id<detailDelegate>detailDelegate;

@end
