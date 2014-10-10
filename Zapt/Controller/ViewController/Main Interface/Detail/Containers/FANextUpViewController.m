//
//  FANextUpViewController.m
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FANextUpViewController.h"
#import "FADetailViewController.h"

#import "FAHorizontalProgressView.h"

#import "FATrakt.h"
#import "FAInterfaceStringProvider.h"

#import "FANextUpTableViewCell.h"

@interface FANextUpViewController () {
    FATraktShowProgress *_progress;
    FATraktEpisode *_nextUpEpisode;
}

@property FANextUpTableViewCell *cell;

@end

@implementation FANextUpViewController {
    BOOL _dismissesModalOnDisplay;
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
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([parent respondsToSelector:@selector(setNextUpViewController:)]) {
        [(id)parent setNextUpViewController : self];
    }
}

- (void)preferredContentSizeChanged
{
    // This is called when dynamic type settings are changed
    /*[self.view recursiveSetNeedsUpdateConstraints];
     [self.view recursiveSetNeedsLayout];
     [self.view recursiveLayoutIfNeeded];*/
    
    [self.view setNeedsUpdateConstraints];
    [self.progressView setNeedsLayout];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat height = 0;
    if (_displaysNextUp) {
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        height = [self tableView:(self.tableView) heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    self.tableViewHeightConstraint.constant = height;
    
    if (!_displaysProgress) {
        if (!self.progressViewHeightConstraint) {
            self.progressViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
            [self.progressView addConstraint:self.progressViewHeightConstraint];
        }
    } else {
        if (self.progressViewHeightConstraint) {
            [self.progressView removeConstraint:self.progressViewHeightConstraint];
            self.progressViewHeightConstraint = nil;
        }
    }
}

- (void)displayProgress:(FATraktShowProgress *)progress
{
    _displaysProgress = YES;
    _progress = progress;
    CGFloat percentage = (CGFloat)progress.percentage.unsignedIntegerValue / 100;
    
    self.progressView.progress = percentage;
    self.progressView.textLabel.text = [FAInterfaceStringProvider progressForProgress:progress long:YES];
    
    [self.view recursiveSetNeedsUpdateConstraints];
    [self.view recursiveSetNeedsLayout];
}

- (void)displayNextUp:(FATraktEpisode *)episode
{
    if (episode.seasonNumber && episode.episodeNumber && episode.detailLevel > FATraktDetailLevelMinimal) {
        _displaysNextUp = YES;
        _nextUpEpisode = episode;
    } else {
        [[FATrakt sharedInstance] detailsForEpisode:episode callback:^(FATraktEpisode *episode) {
            [self displayNextUp:episode];
        } onError:nil];
    }
    
    [self.tableView reloadData];
    [self.view recursiveSetNeedsUpdateConstraints];
    [self.view recursiveSetNeedsLayout];
}

- (void)hideNextUp
{
    _displaysNextUp = NO;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_nextUpEpisode.title) {
        FANextUpTableViewCell *cell = (FANextUpTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        return [FANextUpTableViewCell cellHeightForTitle:_nextUpEpisode.title cell:cell];
    }
    
    return [FANextUpTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"nextUpCell";
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"nextUpCell"];
    
    if (!self.cell) {
        self.cell = [[FANextUpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    self.cell.frameHeight = [FANextUpTableViewCell cellHeight];
    
    if (_nextUpEpisode) {
        FATraktEpisode *episode = _nextUpEpisode;
        self.cell.seasonLabel.text = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
        self.cell.nameLabel.text = episode.title;
    }
    
    if (self.nextUpText) {
        self.cell.nextUpLabel.text = self.nextUpText;
    }
    
    if (self.dismissesModalToDisplay) {
        self.cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self.cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = self.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    [detailViewController loadContent:[_nextUpEpisode cachedVersion]];
    
    if (self.dismissesModalToDisplay) {
        UIViewController *presentingViewController = self.parentViewController.presentingViewController;
        
        if ([presentingViewController isKindOfClass:[UINavigationController class]]) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:^{
                UINavigationController *nc = (UINavigationController *)presentingViewController;
                [nc pushViewController:detailViewController animated:YES];
            }];
        } else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:^{
                [presentingViewController presentViewController:detailViewController animated:YES completion:nil];
            }];
        }
    } else {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (CGSize)preferredContentSize
{
    CGSize size = CGSizeZero;
    
    if (_displaysProgress) {
        size = [self.view.subviews[0] systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        // Simulate the height because otherwise it won't be ready for state restoration
        if (size.height <= 0 || (_displaysNextUp && size.height <= 22)) {
            if (_displaysNextUp) {
                size.height = 73;
            } else {
                size.height = 22;
            }
        }
    }
    
    return size;
}

- (void)setDismissesModalToDisplay:(BOOL)dismissesModalToDisplay
{
    _dismissesModalOnDisplay = dismissesModalToDisplay;
    [self.tableView reloadData];
}

- (BOOL)dismissesModalToDisplay
{
    return _dismissesModalOnDisplay;
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_progress forKey:@"_progress"];
    [coder encodeObject:_nextUpEpisode forKey:@"_nextUpEpisode"];
    
    [coder encodeBool:self.displaysProgress forKey:@"displaysProgress"];
    [coder encodeBool:self.displaysNextUp forKey:@"displaysNextUp"];
    
    [coder encodeObject:self.nextUpText forKey:@"nextUpText"];
    [coder encodeBool:self.dismissesModalToDisplay forKey:@"dismissesModalToDisplay"];
    [coder encodeObject:self.tableView forKey:@"tableView"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    _progress = [coder decodeObjectForKey:@"_progress"];
    _nextUpEpisode = [coder decodeObjectForKey:@"_nextUpEpisode"];
    
    _displaysProgress = [coder decodeBoolForKey:@"displaysProgress"];
    _displaysNextUp = [coder decodeBoolForKey:@"displaysNextUp"];
    
    self.nextUpText = [coder decodeObjectForKey:@"nextUpText"];
    self.dismissesModalToDisplay = [coder decodeBoolForKey:@"dismissesModalToDisplay"];
    //self.tableView = [coder decodeObjectForKey:@"tableView"];
    
    if (_displaysProgress) {
        [self displayProgress:_progress];
    }
    
    if (_displaysNextUp) {
        [self displayNextUp:_nextUpEpisode];
    }
    
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

- (Class<UIViewControllerRestoration>)restorationClass
{
    return self.class;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    FAAppDelegate *appDelegate = (FAAppDelegate *)[[UIApplication sharedApplication] delegate];
    FANextUpViewController *nextUpVC = [appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"nextUp"];
    return nextUpVC;
}

@end
