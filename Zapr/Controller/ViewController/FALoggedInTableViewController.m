//
//  FALoggedInTableViewController.m
//  Zapr
//
//  Created by Finn Wilke on 29.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FALoggedInTableViewController.h"
#import "FAGlobalEventHandler.h"
#import "FAGlobalSettings.h"
#import "FATraktConnection.h"

@interface FANeedsLoginTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
@property NSString *contentName;
@end

@interface FALoggedInTableViewController ()
@property FANeedsLoginTableViewDelegate *needsLoginTableViewDataSource;
@property UITableView *needsLoginTableView;
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
    
    if (indexPath.row == 0 || indexPath.row == 3) {
        cell.textLabel.text = nil;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"You need to be logged in", nil);
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 2) {
        if (!self.contentName) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"to view this", nil), self.contentName];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"to view %@", nil), self.contentName];
        }
        
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textColor = [FAGlobalSettings sharedInstance].tintColor;
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
        [[FAGlobalEventHandler handler] performLoginAnimated:YES showInvalidCredentialsPrompt:NO];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self displayNeedsLoginTableViewIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNeedsLoginTableViewAnimated:(BOOL)animated
{
    if (!self.needsLoginTableView) {
        self.needsLoginTableView = [[UITableView alloc] init];
    }
    
    self.needsLoginTableView.frame = self.tableView.frame;
    [self.tableView.superview addSubview:self.needsLoginTableView];
    
    self.needsLoginTableView.scrollEnabled = NO;
    
    if (!self.needsLoginTableViewDataSource) {
        self.needsLoginTableViewDataSource = [[FANeedsLoginTableViewDelegate alloc] init];
    }
    
    self.needsLoginTableViewDataSource.contentName = self.needsLoginContentName;
    
    self.needsLoginTableView.dataSource = self.needsLoginTableViewDataSource;
    self.needsLoginTableView.delegate = self.needsLoginTableViewDataSource;
    
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    
    self.showingNeedsLoginTableView = YES;
    
    [self.needsLoginTableView reloadData];
}

- (void)hideNeedsLoginTableViewAnimated:(BOOL)animated
{
    if (self.showingNeedsLoginTableView) {
        [self.needsLoginTableView removeFromSuperview];
        [self.tableView reloadData];
        
        self.showingNeedsLoginTableView = NO;
    }
}

- (void)displayNeedsLoginTableViewIfNeeded
{
    BOOL usernameAndPasswordValid = [[FATraktConnection sharedInstance] usernameAndPasswordValid];
    
    if (usernameAndPasswordValid) {
        [self hideNeedsLoginTableViewAnimated:YES];
    } else {
        [self showNeedsLoginTableViewAnimated:YES];
    }
}

@end
