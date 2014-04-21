//
//  FAContentBookmarkViewController.m
//  Zapt
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAContentBookmarkViewController.h"
#import "FACustomListsMembershipViewController.h"
#import "FADetailViewController.h"
#import "FARatingsViewController.h"
#import "FATraktContent.h"
#import "FATrakt.h"
#import "FAProgressHUD.h"
#import "FAInterfaceStringProvider.h"

#import "FAGlobalEventHandler.h"

@interface FAContentBookmarkViewController ()
@property BOOL displaysSeenButton;
@end

@implementation FAContentBookmarkViewController {
    FATraktAccountSettings *_accountSettings;
    FATraktContent *_currentContent;
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
    // Make the tableView begin at the very top
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, -30, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (CGSize)preferredContentSize
{
    // Calculate height
    [self.tableView layoutIfNeeded];
    CGSize size = self.tableView.contentSize;
    // FIXME: UGLY HACK
    size.height -= 66; // This is the automatically applied headers and footers - we don't want them
    return size;
}

- (NSString *)title
{
    return @"Actions";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadContent:(FATraktContent *)content
{
    self.displaysSeenButton = YES;
    
    if (content.contentType == FATraktContentTypeShows) {
        FATraktShow *show = (FATraktShow *)content;
        
        self.displaysSeenButton = !show.isWatched;
    }
    
    [self.tableView reloadData];
    
    /*if (_accountSettings) {
     if (_accountSettings.viewing.ratings_mode == FATraktRatingsModeSimple) {
     self.ratingDetailLabel.text = [FAInterfaceStringProvider nameForRating:content.rating capitalized:YES];
     } else {
     self.ratingDetailLabel.text = [NSString stringWithFormat:@"%i", content.rating_advanced];
     }
     } else {
     self.ratingDetailLabel.text = [FAInterfaceStringProvider nameForRating:content.rating capitalized:YES];
     }*/
}

- (void)displayContent:(FATraktContent *)content
{
    _currentContent = content;
    [[FATrakt sharedInstance] accountSettings:^(FATraktAccountSettings *settings) {
        _accountSettings = settings;
        [self loadContent:[content cachedVersion]];
    } onError:nil];
    
    [self loadContent:content];
}

- (void)didReceiveMemoryWarning1
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.displaysSeenButton) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger offset = 0;
    
    if (!self.displaysSeenButton) {
        offset = 1;
    }
    
    section = section + offset;
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contentBookmark";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSUInteger offset = 0;
    
    if (!self.displaysSeenButton) {
        offset = 1;
    }
    
    if (indexPath.section + offset == 0) {
        if (_currentContent.contentType == FATraktContentTypeShows) {
            cell.textLabel.text = NSLocalizedString(@"Mark everything as seen", nil);
        } else {
            if (_currentContent.isWatched) {
                cell.textLabel.text = NSLocalizedString(@"Mark as not seen", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Mark as seen", nil);
            }
        }
    } else if (indexPath.section + offset == 1) {
        if (indexPath.row == 0) {
            if ([_currentContent.in_watchlist boolValue]) {
                cell.textLabel.text = NSLocalizedString(@"Remove from Watchlist", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Add to Watchlist", nil);
            }
        } else if (indexPath.row == 1) {
            if ([_currentContent.in_collection boolValue]) {
                cell.textLabel.text = NSLocalizedString(@"Remove from Collection", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Add to Collection", nil);
            }
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Custom Lists", nil);
        }
    } else if (indexPath.section + offset == 2) {
        cell.textLabel.text = NSLocalizedString(@"Cancel", nil);
        cell.textLabel.tintColor = self.view.tintColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger offset = 0;
    
    if (!self.displaysSeenButton) {
        offset = 1;
    }
    
    if (![[FATraktConnection sharedInstance] usernameAndPasswordValid] && indexPath.section + offset != 2) {
        [[FAGlobalEventHandler handler] showNeedsLoginAlertWithActionName:NSLocalizedString(@"do any content action", nil)];
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
        return;
    }
    
    if (indexPath.section + offset == 0) {
        // Seen button
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.parentViewController.view];
        
        if (indexPath.row == 0) {
            if (_currentContent.isWatched) {
                [hud showProgressHUDSpinnerWithText:[NSString stringWithFormat:NSLocalizedString(@"Unwatching the %@ for you", nil), [FAInterfaceStringProvider nameForContentType:_currentContent.contentType withPlural:NO capitalized:NO longVersion:NO]]];
                [[FATrakt sharedInstance] setContent:_currentContent seenStatus:NO callback:^{
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            } else {
                [hud showProgressHUDSpinnerWithText:[NSString stringWithFormat:NSLocalizedString(@"Watching the %@ for you", nil), [FAInterfaceStringProvider nameForContentType:_currentContent.contentType withPlural:NO capitalized:NO longVersion:NO]]];
                [[FATrakt sharedInstance] setContent:_currentContent seenStatus:YES callback:^{
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            }
            
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (indexPath.section + offset == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.navigationController.view];
        
        if (indexPath.row == 0) {
            // Watchlist add/remove button
            if (_currentContent.in_watchlist) {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
                [[FATrakt sharedInstance] removeFromWatchlist:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            } else {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to watchlist", nil)];
                [[FATrakt sharedInstance] addToWatchlist:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            }
            
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (indexPath.row == 1) {
            // Library add/remove button
            if ([_currentContent.in_collection boolValue]) {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from collection", nil)];
                [[FATrakt sharedInstance] removeFromLibrary:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            } else {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to collection", nil)];
                [[FATrakt sharedInstance] addToLibrary:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    [self.delegate changedPropertiesOfContent:_currentContent];
                    
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            }
            
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (indexPath.row == 2) {
            // Custom Lists Button
            UIStoryboard *storyboard = self.storyboard;
            FACustomListsMembershipViewController *customListsMembershipViewController = [storyboard instantiateViewControllerWithIdentifier:@"customListsMembership"];
            
            UIViewController *parentViewController = self.parentViewController;
            
            [parentViewController dismissViewControllerAnimated:YES completion:^{
                [customListsMembershipViewController loadContent:_currentContent];
                [parentViewController presentViewController:customListsMembershipViewController animated:YES completion:nil];
            }];
        }
    } else if (indexPath.section + offset == 2) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
