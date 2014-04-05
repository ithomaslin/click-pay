//
//  InfoViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/19/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "InfoViewController.h"
#import "Application.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

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
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 40, 24, 24)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [Application versionBuild]];
}

- (void)closeInfoPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
