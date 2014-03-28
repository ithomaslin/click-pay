//
//  AddCardViewController.h
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface AddCardViewController : UIViewController<STPViewDelegate>
@property STPView* stripeView;

@end
