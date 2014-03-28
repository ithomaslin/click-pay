//
//  MainPageContentViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/17/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "MainPageContentViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MainPageContentViewController ()

@end

@implementation MainPageContentViewController

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
    UIFont *font0 = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:25];
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:14];
	
    self.imageView.image = [UIImage imageNamed:_imageFile];
    self.titleLabel.text = self.titleText;
    [self.titleLabel setFont:font0];
    self.subtitleLabel.text = self.subtitleText;
    [self.subtitleLabel setFont:font1];
    self.titleLabel.textColor = self.subtitleLabel.textColor = [UIColor whiteColor];
    [self.view setTintColor:[UIColor whiteColor]];
    
    UIButton *startButton = [[UIButton alloc] init];
    [startButton setTitle:@"START" forState:UIControlStateNormal];
    [startButton setBackgroundColor:UIColorFromRGB(0x05C75E1)];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    startButton.frame = CGRectMake(32, 100, 256, 64);
    startButton.layer.cornerRadius = 5;
    
    if ([_titleLabel.text isEqualToString:@""]) {
        [self.view addSubview:startButton];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start" message:@"You just pressed the start button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
