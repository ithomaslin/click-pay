//
//  AddCardViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "AddCardViewController.h"

@interface AddCardViewController ()

@end

@implementation AddCardViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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

- (IBAction)creditCardCheck:(id)sender {
    
    long cardNumber = [self.creditCardField.text longLongValue];
    long digits = [self getLength:cardNumber];
    
    NSInteger digit[digits];
    for (int i = 0; i < digits; i ++) {
        int temp = cardNumber % 10;
        digit[i] = temp;
        cardNumber = cardNumber / 10;
    }
    
    long sumEven = 0;
    long sumOdd  = 0;
    long sum;
    
    for (int j = 1; j < digits; j = j + 2) {
        long x = digit[j] * 2;
        if (x >= 10) {
            sumEven = sumEven + x % 10;
            x = x / 10;
            sumEven = sumEven + x;
        } else {
            sumEven = sumEven + x;
        }
    }
    
    for (int k = 0; k < digits; k = k + 2) {
        sumOdd = sumOdd + digit[k];
    }
    
    sum = sumEven + sumOdd;
    
    long d = 0;
    for (int z = 0; z < digits; z ++) {
        if (((z >= digits - 2) && (z < digits - 1)) || ((z > digits - 2) && (z <= digits - 1))) {
            d = d * 10 + digit[z];
        }
    }
    
    [self cardTypeCheckWithSum:sum andResult:d];
}

- (long)getLength:(long)cardNumber {
    long digits = 1;
    while (cardNumber >= 10) {
        cardNumber = cardNumber / 10;
        digits++;
    }
    return digits;
}

- (void)cardTypeCheckWithSum:(long)sum andResult:(long)result {
    //If the total's last digit is 0, the number is valid!
    if (sum % 10 == 0) {
        
        if (result == 73 || result == 43) {
            NSLog(@"AMEX");
        } else if (result == 15 || result == 25 ||
                   result == 35 || result == 45 ||
                   result == 55) {
            NSLog(@"MASTERCARD");
        } else if (result % 10 == 4) {
            NSLog(@"VISA");
        } else {
            NSLog(@"INVALID");
        }
        
    } else {
        NSLog(@"INVALID");
    }
}

@end