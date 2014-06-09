//
//  FAHomeViewController.m
//  Zapt
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAHomeViewController.h"
#import "FANextUpViewController.h"
#import "FADetailViewController.h"
#import "FAListsViewController.h"
#import "FARecommendationsListViewController.h"
#import "FAShowListViewController.h"
#import "FACalendarTableViewController.h"

#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"

#import "FAContentTableViewCell.h"

#import <FATrakt/FATrakt.h>
#import "FAGlobalEventHandler.h"
#import "FAGlobalSettings.h"

@interface FAHomeViewController ()
@property FAWeightedTableViewDataSource *arrayDataSource;
@property FAArrayTableViewDelegate *arrayDelegate;

@property BOOL tableViewContainsCurrentlyWatching;
@property BOOL tableViewContainsProgress;

@property NSArray *showsWithProgress;
@property (nonatomic) FATraktContent *currentlyWatchingContent;

@property (nonatomic) BOOL initialDataFetchDone;

@property (nonatomic) BOOL displaysInvalidCredentialsInfo;
@end

@implementation FAHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usernameAndPasswordValidityChanged:) name:FATraktUsernameAndPasswordValidityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.arrayDelegate) {
        self.arrayDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
        
        self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
        self.arrayDelegate.delegate = self;
        
        self.arrayDataSource.cellClass = [FAContentTableViewCell class];
        
        self.tableView.delegate = self.arrayDelegate;

        
        [self setupTableView];
        [self.arrayDataSource reloadData];
        
        [self displayUserSection];
    }
    
    __weak typeof(self) weakSelf = self;
    [self setUpRefreshControlWithActivityWithRefreshDataBlock:^(FARefreshControlWithActivity *refreshControlWithActivity) {
        [weakSelf reloadData:YES];
    }];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadData:NO];
    self.initialDataFetchDone = YES;    
}

- (void)preferredContentSizeChanged
{
    [self.view setNeedsLayout];
    [self.arrayDataSource reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)usernameAndPasswordValidityChanged:(NSNotification *)aNotification
{
    [self reloadData:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowWithKey:(id)rowKey
{
    if ([rowKey isEqual:@"login"] ||
        [rowKey isEqual:@"register"]) {
        return 44;
    } else {
        return [FAContentTableViewCell cellHeight];
    }
}

- (void)reloadData:(BOOL)animated
{
    if ([[FATraktConnection sharedInstance] usernameAndPasswordValid]) {
        if (self.displaysInvalidCredentialsInfo) {
            self.displaysInvalidCredentialsInfo = NO;
            [self.arrayDataSource removeAllSections];
            [self displayUserSection];
        }
        
        if (animated) [self.refreshControlWithActivity startActivityWithCount:2];
        
        [[FATrakt sharedInstance] currentlyWatchingContentCallback:^(FATraktContent *content) {
            if (content) {
                if (!self.tableViewContainsCurrentlyWatching || ![self.currentlyWatchingContent isEqual:content]) {
                    self.tableViewContainsCurrentlyWatching = YES;
                    
                    [self.arrayDataSource createSectionForKey:@"currentlyWatching" withWeight:0 headerTitle:NSLocalizedString(@"Currently Watching", nil)];
                    [self.arrayDataSource clearSection:@"currentlyWatching"];
                    [self.arrayDataSource insertRow:content.cacheKey inSection:@"currentlyWatching" withWeight:0];
                    [self.arrayDataSource recalculateWeight];
                    
                    NSString *contentCacheKey = content.cacheKey;
                    
                    if (![content posterImageWithWidth:42]) {
                        [[FATrakt sharedInstance] loadImageFromURL:content.posterImageURL withWidth:42 callback:^(UIImage *image) {
                            FAContentTableViewCell *cell = [self.arrayDataSource cellForRowWithKey:contentCacheKey];
                            
                            if (cell) {
                                cell.image = image;
                            }
                        } onError:nil];
                    }
                }
            } else {
                if (self.tableViewContainsCurrentlyWatching) {
                    self.tableViewContainsCurrentlyWatching = NO;
                    
                    [self.arrayDataSource removeSectionForKey:@"currentlyWatching"];
                    [self.arrayDataSource recalculateWeight];
                }
            }
            
            if (animated) [self.refreshControlWithActivity finishActivity];
        } onError:nil];
        
        [[FATrakt sharedInstance] watchedProgressForAllShowsCallback:^(NSArray *result) {
            self.showsWithProgress = result;
            [self displayProgressData];
            
            for (FATraktShow *show in self.showsWithProgress) {
                if (![show.images posterImageWithWidth:42]) {
                    NSString *showCacheKey = show.cacheKey;
                    
                    [[FATrakt sharedInstance] loadImageFromURL:show.images.poster withWidth:100 callback:^(UIImage *image) {
                        FAContentTableViewCell *cell = [self.arrayDataSource cellForRowWithKey:showCacheKey];
                        
                        if (cell) {
                            cell.image = image;
                        }
                    } onError:nil];
                }
            }
            
            if (animated) [self.refreshControlWithActivity finishActivity];
        } onError:nil];
    } else {
        
        self.displaysInvalidCredentialsInfo = YES;
        self.tableViewContainsProgress = NO;
        
        [self.arrayDataSource removeAllSections];
        [self.arrayDataSource createSectionForKey:@"invalidCredentials" withWeight:0];
        [self.arrayDataSource insertRow:@"message" inSection:@"invalidCredentials" withWeight:0];
        
        [self.arrayDataSource createSectionForKey:@"invalidCredentials2" withWeight:1 andHeaderTitle:NSLocalizedString(@"Actions", nil) hidden:NO];
        [self.arrayDataSource insertRow:@"login" inSection:@"invalidCredentials2" withWeight:0];
        [self.arrayDataSource insertRow:@"register" inSection:@"invalidCredentials2" withWeight:1];
        
        [self.arrayDataSource recalculateWeight];
        [self.refreshControlWithActivity finishActivity];
    }
}

- (void)setupTableView
{
    __weak typeof(self) weakSelf = self;
    self.arrayDataSource.reuseIdentifierBlock = ^NSString *(id sectionKey, id object) {
        if ([sectionKey isEqualToString:@"user"]) {
            return @"user";
        } else if ([sectionKey isEqualToString:@"invalidCredentials2"]) {
            return @"invalidCredentials";
        } else {
            return @"content";
        }
    };
    
    self.arrayDataSource.weightedCellCreationBlock = ^(id sectionKey, id object) {
        id cell = nil;
        
        NSString *reuseIdentifier = weakSelf.arrayDataSource.reuseIdentifierBlock(sectionKey, object);
        
        cell = [weakSelf.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if (!cell) {
            if ([sectionKey isEqualToString:@"user"]) {
                // Use the content table view cell for unified experience
                cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            } else if ([sectionKey isEqualToString:@"invalidCredentials2"]) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            } else {
                cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
        }
        
        return cell;
    };
    
    self.arrayDataSource.weightedConfigurationBlock = ^(id cell, id sectionKey, id key) {
        if ([sectionKey isEqualToString:@"currentlyWatching"]) {
            FATraktContent *content = [FATraktContent objectWithCacheKey:key];
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.twoLineMode = YES;
            [contentCell displayContent:content];
            
            contentCell.shouldDisplayImage = YES;
            [content posterImageWithWidth:42 callback:^(UIImage *image) {
                contentCell.image = image;
            }];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([sectionKey isEqualToString:@"showProgress"]) {
            NSString *showCacheKey = key;
            FATraktShow *show = [FATraktShow objectWithCacheKey:showCacheKey];
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.showsProgressForShows = YES;
            contentCell.twoLineMode = YES;
            [contentCell displayContent:show];
            
            contentCell.shouldDisplayImage = YES;
            [show.images posterImageWithWidth:42 callback:^(UIImage *image) {
                contentCell.image = image;
            }];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([sectionKey isEqualToString:@"user"]) {
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.twoLineMode = YES;
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if ([key isEqualToString:@"lists"]) {
                contentCell.textLabel.text = NSLocalizedString(@"Lists", nil);
                contentCell.detailTextLabel.text = NSLocalizedString(@"Watchlists, Library, Custom lists", nil);
            } else if ([key isEqualToString:@"recommendations"]) {
                contentCell.textLabel.text = NSLocalizedString(@"Recommendations", nil);
                contentCell.detailTextLabel.text = NSLocalizedString(@"Recommendations just for you.", nil);
            } else if ([key isEqualToString:@"shows"]) {
                contentCell.textLabel.text = NSLocalizedString(@"TV Shows", nil);
                contentCell.detailTextLabel.text = NSLocalizedString(@"All your TV shows", nil);
            } else if ([key isEqualToString:@"calendar"]) {
                contentCell.textLabel.text = NSLocalizedString(@"Calendar", nil);
                contentCell.detailTextLabel.text = NSLocalizedString(@"Your upcoming episodes", nil);
            }
        } else if ([sectionKey isEqualToString:@"invalidCredentials"]) {
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.twoLineMode = YES;
            contentCell.textLabel.text = NSLocalizedString(@"You are not logged in", nil);
            contentCell.detailTextLabel.text = NSLocalizedString(@"Log in to use all features!", nil);
            contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            contentCell.shouldDisplayImage = NO;
            contentCell.image = nil;
            contentCell.accessoryType = UITableViewCellAccessoryNone;
            
        } else if ([sectionKey isEqualToString:@"invalidCredentials2"]) {
            UITableViewCell *tableViewCell = cell;
            tableViewCell.textLabel.textColor = [FAGlobalSettings sharedInstance].tintColor;
            tableViewCell.textLabel.textAlignment = NSTextAlignmentCenter;
            tableViewCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            if ([key isEqualToString:@"login"]) {
                tableViewCell.textLabel.text = NSLocalizedString(@"Log In", nil);
            } else if ([key isEqualToString:@"register"]) {
                tableViewCell.textLabel.text = NSLocalizedString(@"Register", nil);
            }
            
        }
    };
}

- (void)displayUserSection
{
    [self.arrayDataSource createSectionForKey:@"user" withWeight:1 headerTitle:NSLocalizedString(@"Trakt User", nil)];
    [self.arrayDataSource insertRow:@"lists" inSection:@"user" withWeight:0];
    [self.arrayDataSource insertRow:@"recommendations" inSection:@"user" withWeight:1];
    [self.arrayDataSource insertRow:@"shows" inSection:@"user" withWeight:2];
    [self.arrayDataSource insertRow:@"calendar" inSection:@"user" withWeight:3];
    [self.arrayDataSource recalculateWeight];
}

- (void)displayProgressData
{
    static NSString *sectionName = @"showProgress";
    
    if (self.showsWithProgress.count > 0) {
        self.tableViewContainsProgress = YES;
        
        [self.arrayDataSource createSectionForKey:sectionName withWeight:2 headerTitle:NSLocalizedString(@"Recent Shows", nil)];
        
        NSArray *shows = [self.showsWithProgress filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if (idx >= 5) {
                return NO;
            }
            
            return YES;
        }];
        
        // Remove old shows
        for (NSString *showCacheKey in [self.arrayDataSource rowKeysForSection:sectionName]) {
            [self.arrayDataSource removeRow:showCacheKey inSection:sectionName];
        }
        
        for (NSUInteger i = 0; i < shows.count && i < 5; i++) {
            FATraktShow *show = shows[i];
            
            [self.arrayDataSource insertRow:show.cacheKey inSection:sectionName withWeight:i];
        }
    } else {
        if (self.tableViewContainsProgress) {
            [self.arrayDataSource removeSectionForKey:sectionName];
        }
        
        self.tableViewContainsProgress = NO;
    }
    
    [self.arrayDataSource recalculateWeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowWithKey:(id)rowKey
{
    if (self.displaysInvalidCredentialsInfo && [rowKey isEqualToString:@"message"]) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowWithKey:(id)rowKey
{
    if ([rowKey isKindOfClass:[NSString class]]) {
        if (self.displaysInvalidCredentialsInfo) {
            if ([rowKey isEqualToString:@"login"]) {
                [[FAGlobalEventHandler handler] performLoginAnimated:YES showInvalidCredentialsPrompt:NO];
            } else if ([rowKey isEqualToString:@"register"]) {
                [[FAGlobalEventHandler handler] performRegisterAccount];
            }
            
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        } else if ([rowKey isEqualToString:@"lists"]) {
            
            FAListsViewController *listsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"lists"];
            [self.navigationController pushViewController:listsVC animated:YES];
            
        } else if ([rowKey isEqualToString:@"recommendations"]) {
            
            FARecommendationsListViewController *recommendationsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"recommendations"];
            [recommendationsListVC loadRecommendations];
            [self.navigationController pushViewController:recommendationsListVC animated:YES];
        } else if ([rowKey isEqualToString:@"shows"]) {
            
            FAShowListViewController *showListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showList"];
            [showListVC loadShows];
            [self.navigationController pushViewController:showListVC animated:YES];
        } else if ([rowKey isEqualToString:@"calendar"]) {
            
            FACalendarTableViewController *calendarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"calendar"];
            [calendarVC loadData];
            [self.navigationController pushViewController:calendarVC animated:YES];
        } else {
            // It's a cache key
            
            FATraktContent *content = [FATraktContent objectWithCacheKey:rowKey];
            
            if (content) {
                FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
                [detailVC loadContent:content];
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
    }
}

- (void)connectionUsernameAndPasswordValidityChanged
{
    if (self.initialDataFetchDone) {
        [self reloadData:NO];
    }
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.arrayDelegate forKey:@"arrayDelegate"];
    [coder encodeBool:self.tableViewContainsCurrentlyWatching forKey:@"tableViewContainsCurrentlyWatching"];
    [coder encodeBool:self.tableViewContainsProgress forKey:@"tableViewContainsProgress"];
    [coder encodeBool:self.displaysInvalidCredentialsInfo forKey:@"displaysInvalidCredentialsInfo"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.tableViewContainsCurrentlyWatching = [coder decodeBoolForKey:@"tableViewContainsCurrentlyWatching"];
    self.tableViewContainsProgress = [coder decodeBoolForKey:@"tableViewContainsProgress"];
    self.displaysInvalidCredentialsInfo = [coder decodeBoolForKey:@"displaysInvalidCredentialsInfo"];
    
    self.arrayDelegate = [coder decodeObjectForKey:@"arrayDelegate"];
    self.arrayDelegate.tableView = self.tableView;
    self.arrayDelegate.delegate = self;
    self.arrayDataSource = (FAWeightedTableViewDataSource *)self.arrayDelegate.dataSource;
    self.arrayDataSource.tableView = self.tableView;
    
    self.tableView.dataSource = self.arrayDataSource;
    self.tableView.delegate = self.arrayDelegate;
    
    [self setupTableView];
    [self.arrayDataSource reloadData];
}

@end
