//
//  TodayViewController.m
//  test
//
//  Created by Finn Wilke on 09/06/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <FATrakt.h>

typedef NS_ENUM(NSInteger, FATodayViewControllerDisplayMode) {
    FATodayViewControllerDisplayModeTableView,
    FATodayViewControllerDisplayModeLabel,
    FATodayViewControllerDisplayModeNoContent
};

@interface FATodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSString *apiUser;
@property (nonatomic) FATraktConnection *connection;
@property (nonatomic) UIEdgeInsets contentInsets;

@property (nonatomic) NSString *infoText;
@property (nonatomic) FATodayViewControllerDisplayMode displayMode;
@end

@implementation FATodayViewController

- (CGSize)preferredContentSize
{
    CGSize contentSize;
    
    if (self.displayMode == FATodayViewControllerDisplayModeTableView) {
        contentSize = self.tableView.contentSize;
        contentSize.height += self.contentInsets.top;
        contentSize.height += self.contentInsets.bottom;
        
        // FIXME height of the bottom of the tableView
        contentSize.height -= 30;
    } else if (self.displayMode == FATodayViewControllerDisplayModeLabel) {
        contentSize.height = self.textLabel.intrinsicContentSize.height;
    } else {
        // Nothing to display
        contentSize = CGSizeZero;
    }
    
    return contentSize;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    UIEdgeInsets newInsets = defaultMarginInsets;
    newInsets.bottom = MIN(10, defaultMarginInsets.bottom);
    
    self.contentInsets = defaultMarginInsets;
    return defaultMarginInsets;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)layoutViews
{
    if (self.displayMode == FATodayViewControllerDisplayModeTableView) {
        self.textLabel.hidden = YES;
        self.tableView.hidden = NO;
    } else {
        self.textLabel.hidden = NO;
        self.tableView.hidden = YES;
        self.textLabel.text = self.infoText;
        [self.textLabel setNeedsLayout];
    }
    
    if (self.displayMode != FATodayViewControllerDisplayModeNoContent) {
        [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:[NSBundle mainBundle].bundleIdentifier];
    }
}

- (void)updateData
{
    [self.connection loadUsernameAndPassword];
    self.apiUser = self.connection.apiUser;
    
    if (self.connection.usernameAndPasswordValid) {
        self.displayMode = FATodayViewControllerDisplayModeTableView;
    } else {
        self.displayMode = FATodayViewControllerDisplayModeLabel;
        
        if (!self.connection.usernameAndPasswordSaved) {
            self.infoText = NSLocalizedString(@"Not logged in to Trakt\nOpen the App to get started", nil);
        } else if (!self.connection.usernameAndPasswordValid) {
            self.infoText = NSLocalizedString(@"Your Trakt credentials are invalid. Tap to open the app to change them", nil);
        }
    }
    
    [self layoutViews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.connection = [FATraktConnection sharedInstance];
    self.tableView.separatorColor = [UIColor darkTextColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -30, 0);
    [self updateData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self updateData];
    
    completionHandler(NCUpdateResultNewData);
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"showCell"];
    }
    
    cell.textLabel.text = @"test";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Calendar", nil);
}

@end
