//
//  FASettingsViewController.m
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASettingsViewController.h"
#import "FATrakt.h"
#import "FAAppDelegate.h"

#import <MWPhotoBrowser.h>
#import <MBProgressHUD.h>
#import "FATableViewCellWithActivity.h"

@interface FASettingsViewController ()

@end

@implementation FASettingsViewController {
    BOOL _loggedIn;
    FATableViewCellWithActivity *_checkAuthButtonCell;
    MBProgressHUD *_progressHUD;
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (_progressHUD.isHidden) [_progressHUD show:YES];
        _progressHUD.labelText = message;
        _progressHUD.mode = MBProgressHUDModeCustomView;
        [_progressHUD hide:YES afterDelay:1.5];
    } else {
        [_progressHUD hide:YES];
    }
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)showProgressHUDSpinner {
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    _progressHUD.mode = MBProgressHUDModeIndeterminate;
    _progressHUD.labelText = @"Checking";
    [_progressHUD show:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
    _progressHUD.animationType = MBProgressHUDAnimationZoom;
    [self.view addSubview:_progressHUD];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadState
{
    BOOL oldLoggedIn = _loggedIn;
    _loggedIn = [[FATrakt sharedInstance] usernameAndPasswordSaved];
    if (oldLoggedIn == YES && _loggedIn == NO) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0], [NSIndexPath indexPathForItem:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"User";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_loggedIn) {
            return 2;
        } else {
            return 1;
        }
    } else if (section == 1){
        if (_loggedIn) {
            return 2;
        } else {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BasicCellIdentifier = @"Cell";
    static NSString *RightDetailCellIdentifier = @"CellRightDetail";
    static NSString *ActivityCellIdentifier = @"CellActivity";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (_loggedIn) {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:RightDetailCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RightDetailCellIdentifier];
                }
                cell.textLabel.text = @"User";
                cell.textLabel.textColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSString *username = [[FATrakt sharedInstance] storedUsername];
                cell.detailTextLabel.text = username;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if (indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                cell.textLabel.text = @"Profile";
                cell.textLabel.textColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
            }
        } else {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                cell.textLabel.text = @"Not logged in";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    } else if (indexPath.section == 1) {
        if (_loggedIn) {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:ActivityCellIdentifier];
                if (cell == nil) {
                    cell = [[FATableViewCellWithActivity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActivityCellIdentifier];
                }
                cell.textLabel.text = @"Check";
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                _checkAuthButtonCell = (FATableViewCellWithActivity *)cell;
            } else if (indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                cell.textLabel.text = @"Log Out";
                cell.textLabel.textColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        } else {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"Log In";
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (_loggedIn) {
            [self checkAuthButtonPressed];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            UIApplication *app = [UIApplication sharedApplication];
            FAAppDelegate *delegate = (FAAppDelegate *)app.delegate;
            [delegate handleInvalidCredentials];
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[FATrakt sharedInstance] setUsername:nil andPasswordHash:nil];
        [self reloadState];
    }
}

- (void)checkAuthButtonPressed
{
    [APLog tiny:@"Button pressed"];
    [self showProgressHUDSpinner];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        if (valid) {
            [self showProgressHUDCompleteMessage:@"Success"];
        } else {
            [self showProgressHUDCompleteMessage:nil];
        }
    }];
}

@end
