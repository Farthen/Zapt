//
//  FAArrayTableViewDataSource.m
//  Zapt
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDataSource.h"
#import "FADictionaryHashLocator.h"

@interface FAArrayTableViewDataSource ()
@property NSString *cellIdentifier;

// An object to index path mapping. It contains NSSets with index paths
@property NSMutableDictionary *objects;

@end

@implementation FAArrayTableViewDataSource {
    NSMutableArray *_tableViewData;
    NSMutableArray *_sectionIndexTitles;
    NSMutableArray *_headerTitles;
    NSMutableArray *_footerTitles;
    
    UITableView *_tableView;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.cellIdentifier = [NSString uuidString];
        self.cellClass = [UITableViewCell class];
        self.reloadsDataOnDataChange = YES;
    }
    
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [self init];
    
    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self) {
        self.reloadsDataOnDataChange = NO;
        _objects =            [coder decodeObjectForKey:@"objects"];
        _tableViewData =      [coder decodeObjectForKey:@"tableViewData"];
        _cellIdentifier =     [coder decodeObjectForKey:@"cellIdentifier"];
        _sectionIndexTitles = [coder decodeObjectForKey:@"sectionIndexTitles"];
        _headerTitles =       [coder decodeObjectForKey:@"headerTitles"];
        _footerTitles =       [coder decodeObjectForKey:@"footerTitles"];
        _editableObjects =    [coder decodeObjectForKey:@"editableIndexPaths"];
        _movableObjects =     [coder decodeObjectForKey:@"movableIndexPaths"];
        
        _cellClass = NSClassFromString([coder decodeObjectForKey:@"cellClassName"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.objects            forKey:@"objects"];
    [coder encodeObject:self.tableViewData      forKey:@"tableViewData"];
    [coder encodeObject:self.cellIdentifier     forKey:@"cellIdentifier"];
    [coder encodeObject:self.sectionIndexTitles forKey:@"sectionIndexTitles"];
    [coder encodeObject:self.headerTitles       forKey:@"headerTitles"];
    [coder encodeObject:self.footerTitles       forKey:@"footerTitles"];
    [coder encodeObject:self.editableObjects    forKey:@"editableIndexPaths"];
    [coder encodeObject:self.movableObjects     forKey:@"movableIndexPaths"];
    
    [coder encodeObject:NSStringFromClass(self.cellClass) forKey:@"cellClassName"];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    tableView.dataSource = self;
}

- (UITableView *)tableView
{
    return _tableView;
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
    
    if (self.reloadsDataOnDataChange) {
        [self.tableView reloadData];
    }
}

- (NSArray *)tableViewData
{
    return _tableViewData;
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    NSArray *section = self.tableViewData[indexPath.section];
    id object = [section objectAtIndex:indexPath.row];
    
    if (!self.cellCreationBlock) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        
        if (!cell) {
            cell = [[self.cellClass alloc] init];
        }
    } else {
        cell = self.cellCreationBlock(object);
    }
    
    if (self.configurationBlock) {
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
    return [self.sectionIndexTitles mapUsingBlock:^id(id obj, NSUInteger idx) {
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        }
        
        return @"";
    }];
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
    return [self.editableObjects containsObject:[self rowKeyAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.movableObjects containsObject:[self rowKeyAtIndexPath:indexPath]];
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
- (void)setHeaderTitle:(NSString *)title forSection:(NSUInteger)section
{
    [self.headerTitles replaceObjectAtIndex:section withObject:title];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setFooterTitle:(NSString *)title forSection:(NSUInteger)section
{
    [self.footerTitles replaceObjectAtIndex:section withObject:title];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setSectionIndexTitle:(NSString *)title forSection:(NSUInteger)section
{
    if (!_sectionIndexTitles || _sectionIndexTitles.count < self.tableViewData.count) {
        _sectionIndexTitles = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < self.tableViewData.count; i++) {
            [_sectionIndexTitles addObject:[NSNull null]];
        }
    }
    
    [_sectionIndexTitles replaceObjectAtIndex:section withObject:title];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertSectionData:(NSArray *)sectionData atIndex:(NSUInteger)sectionIndex
{
    [self insertSectionData:sectionData atIndex:sectionIndex];
}

- (void)insertSectionData:(NSArray *)sectionData atIndex:(NSUInteger)sectionIndex withTitle:(NSString *)title
{
    // Shift all following rows by one
    for (NSMutableSet *indexes in self.objects) {
        
        // For all indexes the object has
        for (NSIndexPath *originalPath in indexes) {
            
            // If the section was moved, move the indexPath section too
            if (originalPath.section >= (NSInteger)sectionIndex) {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:originalPath.row inSection:originalPath.section + 1];
                [indexes removeObject:originalPath];
                [indexes addObject:newPath];
            }
        }
    }
    
    // Insert the new data
    [_tableViewData insertObject:[sectionData mutableCopy] atIndex:sectionIndex];
    
    // Shift the titles
    if (_headerTitles) {
        [_headerTitles insertObject:[NSNull null] atIndex:sectionIndex];
    }
    
    if (title) {
        [self.headerTitles replaceObjectAtIndex:sectionIndex withObject:title];
    }
    
    if (_footerTitles) {
        [_footerTitles insertObject:[NSNull null] atIndex:sectionIndex];
    }
    
    if (_sectionIndexTitles) {
        [_sectionIndexTitles insertObject:[NSNull null] atIndex:sectionIndex];
    }
    
    // Generate the index paths for the object
    for (NSUInteger i = 0; i < sectionData.count; i++)
    {
        id object = sectionData[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        [self.objects setObject:indexPath forKey:object];
    }
    
    [self.tableView reloadData];
}

- (void)removeSectionAtIndex:(NSUInteger)sectionIndex
{
    for (id obj in _tableViewData[sectionIndex]) {
        [self.objects removeObjectForKey:obj];
    }
    
    if (_headerTitles) {
        [_headerTitles removeObjectAtIndex:sectionIndex];
    }
    
    if (_footerTitles) {
        [_footerTitles removeObjectAtIndex:sectionIndex];
    }
    
    if (_sectionIndexTitles) {
        [_sectionIndexTitles removeObjectAtIndex:sectionIndex];
    }
    
    // Shift all following rows by one
    for (NSMutableSet *indexes in self.objects) {
        
        // For all indexes the object has
        for (NSIndexPath *originalPath in indexes) {
            
            // If the section was moved, move the indexPath section too
            if (originalPath.section > (NSInteger)sectionIndex) {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:originalPath.row inSection:originalPath.section - 1];
                [indexes removeObject:originalPath];
                [indexes addObject:newPath];
            }
        }
    }
    
    [_tableViewData removeObjectAtIndex:sectionIndex];
    [self.tableView reloadData];
}

- (void)reloadRowsWithKey:(id)object
{
    return [self reloadRowsWithKeys:[NSSet setWithObject:object]];
}

- (void)reloadRowsWithKey:(id)object animation:(UITableViewRowAnimation)animation
{
    return [self reloadRowsWithKeys:[NSSet setWithObject:object] animation:animation];
}

- (void)removeRowWithKey:(id)object
{
    NSSet *indexPaths = [self.objects objectForKey:object];
    [self.objects removeObjectForKey:object];
    
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *section = [_tableViewData objectAtIndex:indexPath.section];
        [section removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths.allObjects withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertRowWithKey:(id)rowKey atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *section = _tableViewData[indexPath.section];
    [section insertObject:rowKey atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)replaceRowKey:(id)oldRowKey withRowKey:(id)newRowKey
{
    NSSet *indexPaths = [self.objects objectForKey:oldRowKey];
    [self replaceRowKeysAtIndexPaths:indexPaths withRowKey:newRowKey];
}

- (void)replaceRowKeysAtIndexPaths:(NSSet *)indexPaths withRowKey:(id)newRowKey
{
    for (NSIndexPath *indexPath in indexPaths) {
        [self replaceRowKeyAtIndexPath:indexPath withRowKey:newRowKey];
    }
}

- (void)replaceRowKeyAtIndexPath:(NSIndexPath *)indexPath withRowKey:(id)newRowKey
{
    [self replaceRowKeyInSection:indexPath.section row:indexPath.row withRowKey:newRowKey];
}

- (void)replaceRowKeyInSection:(NSUInteger)section row:(NSUInteger)row withRowKey:(id)newRowKey
{
    id oldObject = self.tableViewData[section][row];
    NSMutableSet *oldIndexPaths = [self.objects objectForKey:newRowKey];
    [oldIndexPaths removeObject:oldObject];
    
    if (oldIndexPaths.count == 0) {
        [self.objects removeObjectForKey:oldObject];
    }
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableSet *newIndexPaths = [self.objects objectForKey:newRowKey];
    
    if (!newIndexPaths) {
        newIndexPaths = [NSMutableSet set];
        [self.objects setObject:newIndexPaths forKey:newRowKey];
    }
    
    [newIndexPaths addObject:newIndexPath];
    
    self.tableViewData[section][row] = newRowKey;
    [self reloadSection:section row:row];
}

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)row inSection:(NSInteger)section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadRowsWithKeys:(NSSet *)objects
{
    [self reloadRowsWithKeys:objects animation:UITableViewRowAnimationFade];
}

- (void)reloadRowsWithKeys:(NSSet *)objects animation:(UITableViewRowAnimation)animation
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

- (id)rowKeyAtIndexPath:(NSIndexPath *)indexPath
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
    return [self indexPathsForRowKey:object].anyObject;
}

- (NSSet *)indexPathsForRowKey:(id)object
{
    return self.objects[object];
}

- (void)setHeaderTitles:(NSArray *)headerTitles
{
    _headerTitles = [headerTitles mutableCopy];
}

- (NSMutableArray *)headerTitles
{
    if (!_headerTitles || _headerTitles.count != self.tableViewData.count) {
        _headerTitles = [NSMutableArray array];
        
        for (NSUInteger i = 0; i <= self.tableViewData.count; i++) {
            [_headerTitles addObject:[NSNull null]];
        }
        
        for (NSUInteger i = self.tableViewData.count - 1; i <= _headerTitles.count - 1; i++) {
            [_headerTitles removeObjectAtIndex:i];
        }
    }
    
    return _headerTitles;
}

- (void)setFooterTitles:(NSArray *)footerTitles
{
    _footerTitles = [footerTitles mutableCopy];
}

- (NSMutableArray *)footerTitles
{
    if (!_footerTitles || _footerTitles.count != self.tableViewData.count) {
        _footerTitles = [NSMutableArray array];
        
        for (NSUInteger i = 0; i <= self.tableViewData.count; i++) {
            [_footerTitles addObject:[NSNull null]];
        }
        
        for (NSUInteger i = self.tableViewData.count - 1; i <= _footerTitles.count - 1; i++) {
            [_footerTitles removeObjectAtIndex:i];
        }
    }
    
    return _footerTitles;
}

- (void)setSectionIndexTitles:(NSArray *)sectionIndexTitles
{
    _sectionIndexTitles = [sectionIndexTitles mutableCopy];
}

- (NSArray *)sectionIndexTitles
{
    return _sectionIndexTitles;
}

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[[self rowKeyAtIndexPath:idx] hash]];
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    FADictionaryHashLocator *locator = [FADictionaryHashLocator hashLocatorWithHashString:identifier];
    NSSet *indexPaths = [self.objects objectForKey:locator];
    return [indexPaths anyObject];
}

@end
