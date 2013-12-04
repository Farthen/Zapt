//
//  FAArrayTableViewDataSource.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDataSource.h"

@interface FAArrayTableViewDataSource ()
@property NSString *cellIdentifier;
@property (weak) UITableView *tableView;
@end

@implementation FAArrayTableViewDataSource {
    NSMutableArray *_tableViewData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellIdentifier = [NSString uuidString];
        self.cellClass = [UITableViewCell class];
    }
    
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [self init];
    if (self) {
        self.tableView = tableView;
    }
    
    return self;
}

- (void)setTableViewData:(NSArray *)tableViewData
{
    NSMutableArray *mutableTableViewData = [NSMutableArray arrayWithCapacity:tableViewData.count];
    
    for (id object in tableViewData) {
        if (![object isKindOfClass:[NSArray class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"%@ needs table view data that consists of an array of arrays of objects. %@ does not conform to this.", [self className], tableViewData];
        } else {
            [mutableTableViewData addObject:[object mutableCopy]];
        }
        
    }
    
    _tableViewData = mutableTableViewData;
    [self.tableView reloadData];
}

- (NSArray *)tableViewData
{
    return _tableViewData;
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (!cell) {
        cell = [[self.cellClass alloc] init];
    }
    
    if (self.configurationBlock) {
        NSArray *section = self.tableViewData[indexPath.section];
        id object = [section objectAtIndex:indexPath.row];
        
        self.configurationBlock(cell, object);
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = self.tableViewData[section];
    return sectionData.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.headerTitles) {
        if (self.headerTitles.count > (NSUInteger)section) {
            id title = self.headerTitles[section];
            if ([title isKindOfClass:[NSString class]]) {
                return title;
            }
        }
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (self.footerTitles) {
        if (self.footerTitles.count > (NSUInteger)section) {
            id title = self.footerTitles[section];
            if ([title isKindOfClass:[NSString class]]) {
                return title;
            }
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *section = self.tableViewData[indexPath.section];
        [section removeObjectAtIndex:indexPath.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.editableIndexPaths containsObject:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.movableIndexPaths containsObject:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *fromSection = self.tableViewData[fromIndexPath.section];
    NSMutableArray *toSection = self.tableViewData[toIndexPath.section];
    
    id object = fromSection[fromIndexPath.row];
    [fromSection removeObjectAtIndex:fromIndexPath.row];
    
    [toSection insertObject:object atIndex:toIndexPath.row];
}

#pragma mark convenience methods
- (void)reloadRowsWithObject:(id)object
{
    NSMutableIndexSet *reloadIndexSet = [NSMutableIndexSet indexSet];
    
    for (NSMutableArray *section in self.tableViewData) {
        [reloadIndexSet addIndexes:[section indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqual:object];
        }]];
    }
}

- (void)reloadRowsWithObjects:(NSSet *)objects
{
    NSMutableIndexSet *reloadIndexSet = [NSMutableIndexSet indexSet];
    
    for (NSMutableArray *section in self.tableViewData) {
        [reloadIndexSet addIndexes:[section indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [objects containsObject:obj];
        }]];
    }
}

@end
