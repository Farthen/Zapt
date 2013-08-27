//
//  FAContentBookmarkViewController.m
//  Trakr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAContentBookmarkViewController.h"
#import "FASemiModalEnabledViewController.h"
#import "FATraktContent.h"
#import "FATrakt.h"
#import "FAProgressHUD.h"

@interface FAContentBookmarkViewController ()

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
}

- (CGSize)preferredContentSize
{
    // Calculate height
    [self.tableView layoutIfNeeded];
    CGSize size = self.tableView.contentSize;
    // UGLY HACK
    size.height -= 66; // This is the automatically applied headers and footers - we don't want them
    return size;
}

- (NSString *)title
{
    return @"Bookmarks";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadContent:(FATraktContent *)content
{
    if (content.in_watchlist) {
        self.watchlistLabel.text = NSLocalizedString(@"Remove from Watchlist", nil);
    } else {
        self.watchlistLabel.text = NSLocalizedString(@"Add to Watchlist", nil);
    }
    
    if (content.in_collection) {
        self.libraryLabel.text = NSLocalizedString(@"Remove from library", nil);
    } else {
        self.libraryLabel.text = NSLocalizedString(@"Add to library", nil);
    }
    
    int count = [FATraktList cachedCustomLists].count;
    self.customListsDetailLabel.text = [NSString stringWithFormat:@"%i", count];
    
    if (_accountSettings) {
        if (_accountSettings.viewing.ratings_mode == FATraktRatingsModeSimple) {
            self.ratingDetailLabel.text = [FATrakt interfaceNameForRating:content.rating capitalized:YES];
        } else {
            self.ratingDetailLabel.text = [NSString stringWithFormat:@"%i", content.rating_advanced];
        }
    } else {
        self.ratingDetailLabel.text = [FATrakt interfaceNameForRating:content.rating capitalized:YES];
    }
}

- (void)displayContent:(FATraktContent *)content
{
    _currentContent = content;
    [[FATrakt sharedInstance] accountSettings:^(FATraktAccountSettings *settings) {
        _accountSettings = settings;
        [self loadContent:content];
    }];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.parentViewController.view];
        if (indexPath.row == 0) {
            // Watchlist add/remove button
            if (_currentContent.in_watchlist) {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
                [[FATrakt sharedInstance] removeFromWatchlist:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    _currentContent.in_watchlist = NO;
                    [self loadContent:_currentContent];
                } onError:^(LRRestyResponse *response) {
                    [hud showProgressHUDFailed];
                }];
            } else {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to watchlist", nil)];
                [[FATrakt sharedInstance] addToWatchlist:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    _currentContent.in_watchlist = YES;
                    [self loadContent:_currentContent];
                } onError:^(LRRestyResponse *response) {
                    [hud showProgressHUDFailed];
                }];
            }
        } else if (indexPath.row == 1) {
            // Library add/remove button
            if (_currentContent.in_collection) {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from library", nil)];
                [[FATrakt sharedInstance] removeFromWatchlist:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    _currentContent.in_collection = NO;
                    [self loadContent:_currentContent];
                } onError:^(LRRestyResponse *response) {
                    [hud showProgressHUDFailed];
                }];
            } else {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to library", nil)];
                [[FATrakt sharedInstance] addToLibrary:_currentContent callback:^(void) {
                    [hud showProgressHUDSuccess];
                    _currentContent.in_collection = YES;
                    [self loadContent:_currentContent];
                } onError:^(LRRestyResponse *response) {
                    [hud showProgressHUDFailed];
                }];
            }
        }
    }
}

@end