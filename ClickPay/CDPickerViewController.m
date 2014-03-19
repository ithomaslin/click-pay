//
//  CDPickerViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/19/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import "CDPickerViewController.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CDPickerViewController () <UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, retain) NSArray *sortedArray;
@property (nonatomic, strong) NSDictionary *diallingCodesDictionary;

@property (nonatomic, strong) UIView *scrollingNub;
@property (nonatomic, assign) BOOL scrubbing;

@end

@implementation CDPickerViewController

@synthesize cdDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *searchBunnton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = searchBunnton;
    self.navigationItem.title = @"Country Code";
    
    // Table view data & search bar set up
    {
        // Create the path to the file path of dialling codes
        // and pass it to the diallingCodeDictionary
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DiallingCode" ofType:@"plist"];
        self.diallingCodesDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        // Getting all the keys from the diallingCodeDictionary
        NSArray *tempKeys = [_diallingCodesDictionary allKeys];
        
        // Sort it alphabetically
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
        _sortedArray = [tempKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
        [self setupSearchBar];
        self.searchResults = [NSMutableArray array];
    }
    
    // Scrolling nub
    {
        self.scrollingNub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.scrollingNub.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"scroll-nub"]];
        self.scrollingNub.layer.cornerRadius = 12;
        self.scrollingNub.alpha = 0;
        [self.view addSubview:self.scrollingNub];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onNubScrub:)];
        [self.scrollingNub addGestureRecognizer:pan];
    }
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchButtonPressed:(id)sender {
    [self.searchController setActive:YES animated:YES];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return _sortedArray.count;
    } else {
        return self.searchResults.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setTextColor:UIColorFromRGB(0x05B6FE7)];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (tableView == self.tableView) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [_sortedArray objectAtIndex:indexPath.row]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.searchResults objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *code = (tableView == self.tableView) ? [_diallingCodesDictionary objectForKey:[_sortedArray objectAtIndex:indexPath.row]] : [_diallingCodesDictionary objectForKey:[self.searchResults objectAtIndex:indexPath.row]];
    [cdDelegate didselectWith:self withCode:code];
}

#pragma mark - Search Bar

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    
    // scroll just past the search bar initially
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
}

- (void)filterCountryForTerm:(NSString *)term {
    [self.searchResults removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", term];
    NSArray *results = [_sortedArray filteredArrayUsingPredicate:predicate];
    [self.searchResults addObjectsFromArray:results];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterCountryForTerm:searchString];
    return YES;
}

#pragma mark - Scrolling nub

- (void)onNubScrub:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.scrollingNub.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"scroll-nub-pressed"]];
        self.scrubbing = YES;
    } else if (pan.state != UIGestureRecognizerStateChanged) {
        self.scrollingNub.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"scroll-nub"]];
        self.scrubbing = NO;
        [self hideNubAfterDelay];
    }
    
    CGFloat translation = [pan translationInView:self.view].y;
    
    CGFloat minY = self.tableView.contentInset.top + 10;
    CGFloat maxY = self.view.bounds.size.height - self.scrollingNub.bounds.size.height - 10;
    
    CGRect rect = self.scrollingNub.frame;
    rect.origin.y += translation;
    rect.origin.y = MAX(rect.origin.y, minY);
    rect.origin.y = MIN(rect.origin.y, maxY);
    self.scrollingNub.frame = rect;
    
    // y = p * (maxY - minY) + minY
    // y - minY
    // ---------     = p
    // (maxY - minY)
    CGFloat percent = (rect.origin.y - minY ) / (maxY - minY );
    percent = MIN(percent, 1);
    percent = MAX(percent, 0);
    
    CGFloat minOffset = - self.tableView.contentInset.top;
    CGFloat maxOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    CGFloat scrollOffset = percent * (maxOffset - minOffset) + minOffset;
    
    CGPoint offset = CGPointMake(0, scrollOffset);
    [self.tableView setContentOffset:offset];
    
    [pan setTranslation:CGPointZero inView:self.view];
}


- (CGFloat)percentageThroughContent {
    CGFloat bottomY = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    if (bottomY == 0) {
        return 0;
    }
    
    return self.tableView.contentOffset.y / bottomY;
}

- (CGFloat)nubY {
    CGFloat minY = self.tableView.contentInset.top + 10;
    CGFloat maxY = self.view.bounds.size.height - self.scrollingNub.bounds.size.height - 10;
    
    return [self percentageThroughContent] * (maxY - minY ) + minY;
}

- (void)repositionNub {
    CGRect rect = self.scrollingNub.frame;
    rect.origin.x = self.view.bounds.size.width - self.scrollingNub.frame.size.width - 10;
    rect.origin.y = [self nubY];
    self.scrollingNub.frame = rect;
}

- (void)animateNumbAlpha:(CGFloat)alpha {
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollingNub.alpha = alpha;
    }];
}

- (void)hideNubAfterDelay {
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!self.scrubbing && ![self.tableView isDecelerating]) {
            [self animateNumbAlpha:0];
        }
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrubbing) {
        return;
    }
    
    if (self.scrollingNub.alpha == 0) {
        [self animateNumbAlpha:1];
    }
    
    [self repositionNub];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self hideNubAfterDelay];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hideNubAfterDelay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
