//
//  FAShowListViewController.m
//  Zapt
//
//  Created by Finn Wilke on 26.02.14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAShowListViewController.h"
#import "FATrakt.h"
#import "FAContentTableViewCell.h"
#import "FADetailViewController.h"

#import "FAGlobalSettings.h"

@interface FAShowListViewController ()
@property NSArray *showsWithProgress;
@property FAWeightedTableViewDataSource *weightedDataSource;
@property FAArrayTableViewDelegate *arrayDelegate;

@property UIBarButtonItem *hideCompletedButton;
@property BOOL hidingCompleted;

@property (nonatomic) NSMutableDictionary *showImages;
@end

@implementation FAShowListViewController {
    BOOL _hidingCompleted;
}

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.weightedDataSource) {
        self.weightedDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
        
        self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.weightedDataSource];
        self.arrayDelegate.delegate = self;
        
        self.weightedDataSource.cellClass = [FAContentTableViewCell class];
        
        self.tableView.dataSource = self.weightedDataSource;
        self.tableView.delegate = self.arrayDelegate;
        
        [self setUpTableView];
        [self.tableView reloadData];
    }
    
    __weak typeof(self) weakSelf = self;
    [self setUpRefreshControlWithActivityWithRefreshDataBlock:^(FARefreshControlWithActivity *refreshControlWithActivity) {
        [weakSelf reloadData:YES];
    }];
    
    self.hideCompletedButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(toggleHideCompleted)];
    self.hideCompletedButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Hide Completed", nil), NSLocalizedString(@"Show All", nil), nil];
    
    self.navigationItem.rightBarButtonItem = self.hideCompletedButton;
    
    self.hidingCompleted = [FAGlobalSettings sharedInstance].hideCompletedShows;
}

- (void)toggleHideCompleted
{
    self.hidingCompleted = !self.hidingCompleted;
}

- (BOOL)hidingCompleted
{
    return _hidingCompleted;
}

- (void)setHidingCompleted:(BOOL)hidingCompleted
{
    _hidingCompleted = hidingCompleted;
    [FAGlobalSettings sharedInstance].hideCompletedShows = hidingCompleted;
    
    if (_hidingCompleted) {
        self.hideCompletedButton.title = NSLocalizedString(@"Show All", nil);
        
        [self.weightedDataSource filterRowsUsingBlock:^BOOL(id key, BOOL *stop) {
            FATraktShow *show = [FATraktShow objectWithCacheKey:key];
            
            if (show.progress && [show.progress.left unsignedIntegerValue] == 0) {
                return NO;
            }
            
            return YES;
        }];
        
        [self.weightedDataSource recalculateWeight];
    } else {
        self.hideCompletedButton.title = NSLocalizedString(@"Hide Completed", nil);
        
        [self.weightedDataSource clearFilters];
        [self.weightedDataSource recalculateWeight];
    }
}

- (void)setUpTableView
{
    self.weightedDataSource.cellClass = [FAContentTableViewCell class];
    
    __weak FAShowListViewController *weakSelf = self;
    self.weightedDataSource.weightedConfigurationBlock = ^(id cell, id sectionKey, id key) {
        if ([sectionKey isEqualToString:@"shows"]) {
            FATraktShow *show = [FATraktShow objectWithCacheKey:key];
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.showsProgressForShows = YES;
            contentCell.twoLineMode = YES;
            [contentCell displayContent:show];
            
            contentCell.shouldDisplayImage = YES;
            contentCell.image = weakSelf.showImages[key];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    };
    
    self.tableView.rowHeight = [FAContentTableViewCell cellHeight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)preferredContentSizeChanged
{
    [self.view layoutIfNeeded];
}

- (void)tableView:(UITableView *)tableView didSelectRowWithObject:(id)key
{
    FATraktContent *content = [FATraktShow objectWithCacheKey:key];
    
    FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [detailVC loadContent:content];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)displayProgressData
{
    [self.weightedDataSource createSectionForKey:@"shows" withWeight:0];
    
    [self.showsWithProgress enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FATraktShow *show = obj;
        
        if (self.hidingCompleted && show.progress && [show.progress.left unsignedIntegerValue] == 0) {
            [self.weightedDataSource insertRow:[obj cacheKey] inSection:@"shows" withWeight:idx hidden:YES];
        } else {
            [self.weightedDataSource insertRow:[obj cacheKey] inSection:@"shows" withWeight:idx hidden:NO];
        }
    }];
    
    [self.weightedDataSource recalculateWeight];
}

- (void)loadShows
{
    [self reloadData:NO];
}

- (void)reloadData:(BOOL)animated
{
    [[FATrakt sharedInstance] watchedProgressForAllShowsCallback:^(NSArray *result) {
        
        if (!self.showImages) {
            self.showImages = [NSMutableDictionary dictionary];
        }
        
        for (FATraktShow *show in result) {
            [[FATrakt sharedInstance] loadImageFromURL:show.images.poster withWidth:100 callback:^(UIImage *image) {
                [self.showImages setObject:image forKey:show.cacheKey];
                [self.weightedDataSource reloadRowsWithObject:show.cacheKey];
            } onError:nil];
        }
        
        self.showsWithProgress = result;
        [self displayProgressData];
        
        if (animated) [self.refreshControlWithActivity finishActivity];
    } onError:nil];
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.arrayDelegate forKey:@"arrayDelegate"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    
    self.arrayDelegate = [coder decodeObjectForKey:@"arrayDelegate"];
    self.arrayDelegate.tableView = self.tableView;
    self.arrayDelegate.delegate = self;
    self.weightedDataSource = (FAWeightedTableViewDataSource *)self.arrayDelegate.dataSource;
    
    self.tableView.dataSource = self.weightedDataSource;
    self.tableView.delegate = self.arrayDelegate;
    
    [self setUpTableView];
    
    [self.tableView reloadData];
}

@end
