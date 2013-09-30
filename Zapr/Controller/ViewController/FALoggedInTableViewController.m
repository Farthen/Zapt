//
//  FALoggedInTableViewController.m
//  Zapr
//
//  Created by Finn Wilke on 29.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FALoggedInTableViewController.h"
#import "FAAppDelegate.h"
#import "FATraktConnection.h"

@interface FANeedsLoginTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@end

@interface FALoggedInTableViewController ()
@property FANeedsLoginTableViewDelegate *needsLoginTableViewDataSource;
@property BOOL wasScrollEnabled;
@property BOOL showingNeedsLoginTableView;
@end


@implementation FANeedsLoginTableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FANeedsLoginTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FAAppDelegate *appDelegate = (FAAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (indexPath.row == 0 || indexPath.row == 3) {
        cell.textLabel.text = nil;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"You need to be logged in", nil);
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"to view this", nil);
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textColor = appDelegate.tintColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0 && indexPath.row != 4) {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        FAAppDelegate *appDelegate = (FAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate performLoginAnimated:YES];
    }
}

@end

@implementation FALoggedInTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showingNeedsLoginTableView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionUsernameAndPasswordValidityChangedNotification:) name:FATraktUsernameAndPasswordValidityChangedNotification object:nil];
    [self connectionUsernameAndPasswordValidityChangedNotification:nil];
}

- (void)connectionUsernameAndPasswordValidityChangedNotification:(NSNotification *)notification
{
    BOOL usernameAndPasswordValid = [[FATraktConnection sharedInstance] usernameAndPasswordValid];
    if (usernameAndPasswordValid) {
        [self hideNeedsLoginTableViewAnimated:YES];
    } else {
        [self showNeedsLoginTableViewAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNeedsLoginTableViewAnimated:(BOOL)animated
{
    self.wasScrollEnabled = self.tableView.scrollEnabled;
    self.tableView.scrollEnabled = NO;
    if (!self.needsLoginTableViewDataSource) {
        self.needsLoginTableViewDataSource = [[FANeedsLoginTableViewDelegate alloc] init];
    }
    
    self.tableView.dataSource = self.needsLoginTableViewDataSource;
    self.tableView.delegate = self.needsLoginTableViewDataSource;
    
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    
    self.showingNeedsLoginTableView = YES;
    
    [self.tableView reloadData];
}

- (void)hideNeedsLoginTableViewAnimated:(BOOL)animated
{
    if (self.showingNeedsLoginTableView) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.scrollEnabled = self.wasScrollEnabled;
        self.tableView.userInteractionEnabled = YES;
        [self.tableView reloadData];
        
        self.showingNeedsLoginTableView = NO;
    }
}

@end
