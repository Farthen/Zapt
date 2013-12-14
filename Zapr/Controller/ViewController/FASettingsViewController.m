//
//  FASettingsViewController.m
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASettingsViewController.h"
#import "FATrakt.h"
#import "FAGlobalEventHandler.h"

#import "FATraktCache.h"

#import "FAProgressHUD.h"
#import "FATableViewCellWithActivity.h"

@interface FASettingsViewController ()

@end

@implementation FASettingsViewController {
    BOOL _loggedIn;
    FAProgressHUD *_progressHUD;
    FATableViewCellWithActivity *_checkAuthButtonCell;
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
    _progressHUD = [[FAProgressHUD alloc] initWithView:self.view];
    _progressHUD.disabledUIElements = @[self.tableView];
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
    _loggedIn = [[FATraktConnection sharedInstance] usernameAndPasswordSaved];
    
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"User", nil);
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_loggedIn) {
            return 1;
        } else {
            return 1;
        }
    } else if (section == 1) {
        if (_loggedIn) {
            return 2;
        } else {
            return 1;
        }
    } else if (section == 2) {
        return 1;
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
                
                cell.textLabel.text = NSLocalizedString(@"User", nil);
                cell.textLabel.textColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [[FATraktConnection sharedInstance] loadUsernameAndPassword];
                NSString *username = [FATraktConnection sharedInstance].apiUser;
                cell.detailTextLabel.text = username;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            /* else if (indexPath.row == 1) {
             cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
             if (cell == nil) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
             }
             cell.textLabel.text = NSLocalizedString(@"Profile", nil);
             cell.textLabel.textColor = [UIColor blackColor];
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             cell.selectionStyle = UITableViewCellSelectionStyleBlue;
             cell.textLabel.textAlignment = NSTextAlignmentLeft;
             } */
        } else {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                
                cell.textLabel.text = NSLocalizedString(@"Not logged in", nil);
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
                
                cell.textLabel.text = NSLocalizedString(@"Check", nil);
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                _checkAuthButtonCell = (FATableViewCellWithActivity *)cell;
            } else if (indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                
                cell.textLabel.text = NSLocalizedString(@"Log Out", nil);
                cell.textLabel.textColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        } else {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
                }
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = NSLocalizedString(@"Log In", nil);
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
    } else if (indexPath.section == 2) {
        // Includes the empty cache button
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Empty Cache", nil);
            cell.textLabel.textColor = [UIColor redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (_loggedIn) {
            [self checkAuthButtonPressed];
        } else {
            [[FAGlobalEventHandler handler] performLoginAnimated:YES showInvalidCredentialsPrompt:NO completion:^{
                [self reloadState];
            }];
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[FATraktConnection sharedInstance] setUsername:nil andPasswordHash:nil];
        [self reloadState];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [[FATraktCache sharedInstance] clearCaches];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkAuthButtonPressed
{
    DDLogViewController(@"Auth Button pressed");
    [_progressHUD showProgressHUDSpinner];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid) {
        if (valid) {
            [_progressHUD showProgressHUDSuccess];
        } else {
            [_progressHUD showProgressHUDFailed];
        }
    }];
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
