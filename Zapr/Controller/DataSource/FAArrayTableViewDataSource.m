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

// An object to index path mapping. It contains NSSets with index paths
@property NSMutableDictionary *objects;

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
    NSMutableDictionary *objects = [NSMutableDictionary dictionary];
    
    NSUInteger sectionIndex = 0;
    
    for (id section in[tableViewData copy]) {
        if (![section isKindOfClass:[NSArray class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"%@ needs table view data that consists of an array of arrays of objects. %@ does not conform to this.", [self className], tableViewData];
        } else {
            [mutableTableViewData addObject:[section mutableCopy]];
            
            NSUInteger rowIndex = 0;
            
            for (id object in(NSArray *) section) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                
                NSMutableSet *indexPaths = [objects objectForKey:object];
                
                if (!indexPaths) {
                    indexPaths = [NSMutableSet set];
                    [objects setObject:indexPaths forKey:object];
                }
                
                [indexPaths addObject:indexPath];
                
                rowIndex++;
            }
        }
        
        sectionIndex++;
    }
    
    _tableViewData = mutableTableViewData;
    self.objects = objects;
    
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
    return [self reloadRowsWithObjects:[NSSet setWithObject:object]];
}

- (void)removeObject:(id)object
{
    NSSet *indexPaths = [self.objects objectForKey:object];
    [self.objects removeObjectForKey:object];
    
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *section = [_tableViewData objectAtIndex:indexPath.section];
        [section removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths.allObjects withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)replaceObject:(id)oldObject withObject:(id)newObject
{
    NSSet *indexPaths = [self.objects objectForKey:oldObject];
    [self replaceObjectsAtIndexPaths:indexPaths withObject:newObject];
}

- (void)replaceObjectsAtIndexPaths:(NSSet *)indexPaths withObject:(id)object
{
    for (NSIndexPath *indexPath in indexPaths) {
        [self replaceObjectAtIndexPath:indexPath withObject:object];
    }
}

- (void)replaceObjectAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object
{
    [self replaceObjectInSection:indexPath.section row:indexPath.row withObject:object];
}

- (void)replaceObjectInSection:(NSUInteger)section row:(NSUInteger)row withObject:(id)object
{
    id oldObject = self.tableViewData[section][row];
    NSMutableSet *oldIndexPaths = [self.objects objectForKey:oldObject];
    [oldIndexPaths removeObject:oldObject];
    
    if (oldIndexPaths.count == 0) {
        [self.objects removeObjectForKey:oldObject];
    }
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableSet *newIndexPaths = [self.objects objectForKey:object];
    
    if (!newIndexPaths) {
        newIndexPaths = [NSMutableSet set];
        [self.objects setObject:newIndexPaths forKey:object];
    }
    
    [newIndexPaths addObject:newIndexPath];
    
    self.tableViewData[section][row] = object;
    [self reloadSection:section row:row];
}

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)row inSection:(NSInteger)section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadRowsWithObjects:(NSSet *)objects
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (id object in objects) {
        NSSet *objectIndexPaths = [self.objects objectForKey:object];
        
        if (objectIndexPaths) {
            [indexPaths addObjectsFromArray:[objectIndexPaths allObjects]];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if ((NSInteger)self.tableViewData.count > indexPath.section) {
        NSArray *section = self.tableViewData[indexPath.section];
        
        if ((NSInteger)section.count > indexPath.row) {
            return section[indexPath.row];
        }
    }
    
    return nil;
}

- (NSIndexPath *)anyIndexPathForObject:(id)object
{
    return [self indexPathsForObject:object].anyObject;
}

- (NSSet *)indexPathsForObject:(id)object
{
    return self.objects[object];
}

@end
