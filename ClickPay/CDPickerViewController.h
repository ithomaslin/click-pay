//
//  CDPickerViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/19/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDPickerViewController;
@protocol CDPickerDelegate <NSObject>
- (void)didselectWith:(CDPickerViewController *)controller withCode:(NSString *)code;
@end

@interface CDPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    __weak id<CDPickerDelegate>cdDelegate;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<CDPickerDelegate>cdDelegate;
@end
