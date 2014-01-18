//
//  FACustomListsMembershipViewController.m
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACustomListsMembershipTableViewController.h"
#import "FACustomListsMembershipViewController.h"
#import "FATrakt.h"

#import "FAInterfaceStringProvider.h"

@interface FACustomListsMembershipTableViewController ()
@property NSMutableArray *customLists;
@property FATraktContent *content;
@property NSMutableSet *reloadingIndexPaths;
@end

@implementation FACustomListsMembershipTableViewController

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
    
    self.reloadingIndexPaths = [NSMutableSet set];
    self.tableView.rowHeight = 44;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContent:(FATraktContent *)content
{
    self.content = content;
    [self refreshDataAnimated:NO];
    
    NSString *contentTypeName = [FAInterfaceStringProvider nameForContentType:content.contentType withPlural:NO capitalized:NO];
    self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Select the lists you want this %@ to be in", nil), contentTypeName];
}

- (void)refreshDataAnimated:(BOOL)animated
{
    [[FATrakt sharedInstance] allCustomListsCallback:^(NSArray *lists) {
        self.customLists = [lists mutableCopy];
        [self.tableView reloadData];
        
        for (NSUInteger i = 0; i < self.customLists.count; i++) {
            FATraktList *list = self.customLists[i];
            [[FATrakt sharedInstance] detailsForCustomList:list callback:^(FATraktList *newList) {
                [self.customLists setObject:newList atIndexedSubscript:i];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            } onError:nil];
        }
    } onError:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.customLists.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *id = @"FACustomListsMembershipTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    
    FATraktList *list = [[self.customLists objectAtIndex:indexPath.row] cachedVersion];
    cell.textLabel.text = list.name;
    
    if ([self.reloadingIndexPaths containsObject:indexPath] || list.items == nil) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicator;
        [activityIndicator startAnimating];
    } else {
        if (cell.accessoryView) {
            cell.accessoryView = nil;
        }
        
        if ([list containsContent:self.content]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.separatorInset = self.tableView.separatorInset;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FATraktList *list = [[self.customLists objectAtIndex:indexPath.row] cachedVersion];
        BOOL add;
        
        if ([list containsContent:self.content]) {
            add = NO;
        } else {
            add = YES;
        }
        
        [self.reloadingIndexPaths addObject:indexPath];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSLog(@"add: %i", add);
        
        [[FATrakt sharedInstance] addContent:self.content toCustomList:list add:add callback:^{
            [self.reloadingIndexPaths removeObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } onError:^(FATraktConnectionResponse *connectionError) {
            [self.reloadingIndexPaths removeObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
