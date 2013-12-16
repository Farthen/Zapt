//
//  FAWeightedTableViewDataSource.m
//  Zapr
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAWeightedTableViewDataSource.h"

@interface FAWeightedTableViewDataSource ()
@property NSString *cellIdentifier;

@property NSMutableDictionary *weightedSections;
@property NSArray *weightedSectionData;
@property NSMutableDictionary *sectionsForIndexes;

@property NSMutableArray *tableViewActions;

@end

@interface FAWeightedTableViewDataSourceSection : NSObject

@property NSMutableDictionary *rowData;
@property BOOL hidden;
@property __weak id <NSCopying> key;
@property NSInteger weight;
@property NSString *headerTitle;
@property (readonly) NSInteger lastSectionIndex;
@property NSInteger currentSectionIndex;

@property NSMutableDictionary *rowsForIndexes;

- (instancetype)initWithKey:(id <NSCopying>)key weight:(NSInteger)weight;
+ (instancetype)sectionWithKey:(id <NSCopying>)key weight:(NSInteger)weight;

@end

@implementation FAWeightedTableViewDataSourceSection {
    NSInteger _currentSectionIndex;
    NSInteger _lastSectionIndex;
}

- (instancetype)initWithKey:(id <NSCopying>)key weight:(NSInteger)weight
{
    self = [super init];
    
    if (self) {
        self.key = key;
        self.weight = weight;
        self.hidden = NO;
        self.rowsForIndexes = [NSMutableDictionary dictionary];
        self.currentSectionIndex = -1;
    }
    
    return self;
}

+ (instancetype)sectionWithKey:(id <NSCopying>)key weight:(NSInteger)weight
{
    FAWeightedTableViewDataSourceSection *instance = [[self alloc] initWithKey:key weight:weight];
    return instance;
}

- (void)setCurrentSectionIndex:(NSInteger)currentSectionIndex
{
    _lastSectionIndex = _currentSectionIndex;
    _currentSectionIndex = currentSectionIndex;
}

- (NSInteger)currentSectionIndex
{
    return _currentSectionIndex;
}

@end

@interface FAWeightedTableViewDataSourceRow : NSObject

@property __weak id key;
@property NSInteger weight;
@property BOOL hidden;
@property (readonly) NSIndexPath *lastIndexPath;
@property NSIndexPath *currentIndexPath;

- (instancetype)initWithKey:(id)obj weight:(NSInteger)weight;
+ (instancetype)rowWithKey:(id <NSCopying>)obj weight:(NSInteger)weight;

@end

@implementation FAWeightedTableViewDataSourceRow {
    NSIndexPath *_lastIndexPath;
    NSIndexPath *_currentIndexPath;
}

- (instancetype)initWithKey:(id)obj weight:(NSInteger)weight
{
    self = [super init];
    
    if (self) {
        self.weight = weight;
        self.key = obj;
        self.hidden = NO;
    }
    
    return self;
}

+ (instancetype)rowWithKey:(id <NSCopying>)obj weight:(NSInteger)weight
{
    FAWeightedTableViewDataSourceRow *instance = [[self.class alloc] initWithKey:obj weight:weight];
    return instance;
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath
{
    _lastIndexPath = _currentIndexPath;
    _currentIndexPath = currentIndexPath;
}

- (NSIndexPath *)currentIndexPath
{
    return _currentIndexPath;
}

@end

@interface FAWeightedTableViewDataSourceAction : NSObject

typedef enum {
    FAWeightedTableViewDataSourceActionInsertRow,
    FAWeightedTableViewDataSourceActionDeleteRow,
    FAWeightedTableViewDataSourceActionMoveRow,
    
    FAWeightedTableViewDataSourceActionInsertSection,
    FAWeightedTableViewDataSourceActionDeleteSection,
    FAWeightedTableViewDataSourceActionMoveSection
} FAWeightedTableViewDataSourceActionType;

@property FAWeightedTableViewDataSourceActionType actionType;
@property FAWeightedTableViewDataSourceSection *section;
@property FAWeightedTableViewDataSourceRow *row;

@end

@implementation FAWeightedTableViewDataSourceAction
@end

@implementation FAWeightedTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    
    if (self) {
        self.tableViewActions = [NSMutableArray array];
        self.reloadsDataOnDataChange = NO;
    }
    
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = self.tableViewData[indexPath.section];
    id rowKey = [sectionArray objectAtIndex:indexPath.row];
    
    NSNumber *sectionNumber = [NSNumber numberWithUnsignedInteger:(NSUInteger)indexPath.section];
    FAWeightedTableViewDataSourceSection *section = self.sectionsForIndexes[sectionNumber];
    id sectionKey = section.key;
    
    id cell = nil;
    
    if (!self.weightedCellCreationBlock && !self.cellCreationBlock) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        
        if (!cell) {
            cell = [[self.cellClass alloc] init];
        }
    } else if (self.weightedCellCreationBlock) {
        cell = self.weightedCellCreationBlock(sectionKey, rowKey);
    } else if (self.cellCreationBlock) {
        cell = self.cellCreationBlock(rowKey);
    }
    
    if (self.weightedConfigurationBlock) {
        self.weightedConfigurationBlock(cell, sectionKey, rowKey);
    } else if (self.configurationBlock) {
        self.configurationBlock(cell, rowKey);
    }
    
    return cell;
}

- (void)recalculateWeight
{
    NSComparisonResult (^weightComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
        NSInteger weight1 = [obj1 weight];
        NSInteger weight2 = [obj2 weight];
        
        if (weight1 < weight2) {
            return NSOrderedAscending;
        }
        
        if (weight1 == weight2) {
            return NSOrderedSame;
        }
        
        return NSOrderedDescending;
    };
    
    BOOL (^hiddenFilter)(id key, id obj, BOOL *stop) = ^BOOL(id key, id obj, BOOL *stop) {
        return ![obj hidden];
    };
    
    NSMutableDictionary *filteredSections = [self.weightedSections filterUsingBlock:hiddenFilter];
    NSArray *sortedWeightedSections = [filteredSections.allValues sortedArrayUsingComparator:weightComparator];
    
    self.sectionsForIndexes = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < sortedWeightedSections.count; i++) {
        FAWeightedTableViewDataSourceSection *section = sortedWeightedSections[i];
        
        self.sectionsForIndexes[[NSNumber numberWithUnsignedInteger:i]] = section;
    }
    
    NSMutableArray *headerTitles = [NSMutableArray array];
    self.tableViewData = [sortedWeightedSections mapUsingBlock:^id(id obj, NSUInteger sectionIdx) {
        
        FAWeightedTableViewDataSourceSection *section = obj;
        
        NSMutableDictionary *filteredRows = [section.rowData filterUsingBlock:hiddenFilter];
        NSArray *sortedWeightedRows = [filteredRows.allValues sortedArrayUsingComparator:weightComparator];
        
        section.currentSectionIndex = sectionIdx;
        
        id title = section.headerTitle;
        
        if (!title) {
            title = [NSNull null];
        }
        
        [headerTitles addObject:title];
        
        return [sortedWeightedRows mapUsingBlock:^id(id obj, NSUInteger rowIdx) {
            FAWeightedTableViewDataSourceRow *row = obj;
            section.rowsForIndexes[[NSNumber numberWithUnsignedInteger:rowIdx]] = row;
            
            row.currentIndexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            
            return row.key;
        }];
    }];
    
    self.headerTitles = headerTitles;
    
    [self interpolateDataChange];
}

- (void)reloadData
{
    [self.tableViewActions removeAllObjects];
    [self.tableView reloadData];
}

- (void)interpolateDataChange
{
    [self.tableView beginUpdates];
    UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
    
    for (FAWeightedTableViewDataSourceAction *action in self.tableViewActions) {
        
        FAWeightedTableViewDataSourceActionType actionType = action.actionType;
        FAWeightedTableViewDataSourceSection *section = action.section;
        
        // This is nil for section actions
        FAWeightedTableViewDataSourceRow *row = action.row;
        
        
        if (actionType == FAWeightedTableViewDataSourceActionInsertRow) {
            [self.tableView insertRowsAtIndexPaths:@[row.currentIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionDeleteRow) {
            [self.tableView deleteRowsAtIndexPaths:@[row.currentIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionMoveRow) {
            [self.tableView moveRowAtIndexPath:row.lastIndexPath toIndexPath:row.currentIndexPath];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionInsertSection) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section.currentSectionIndex] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionDeleteSection) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section.currentSectionIndex] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionMoveSection) {
            [self.tableView moveSection:section.lastSectionIndex toSection:section.currentSectionIndex];
            
        }
    }
    
    [self.tableViewActions removeAllObjects];
    
    [self.tableView endUpdates];
}

- (void)clearFiltersForSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    for (id rowKey in section.rowData) {
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        if (row.hidden) {
            [self showRow:rowKey inSection:section.rowData];
        }
    }
}

- (void)clearFilters
{
    for (id sectionKey in self.weightedSections) {
        [self clearFiltersForSection:sectionKey];
    }
}

- (void)filterRowsUsingBlock:(BOOL (^)(id key, BOOL *stop))filterBlock
{
    BOOL stop = NO;
    
    for (id sectionKey in self.weightedSections) {
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        for (id rowKey in section.rowData) {            
            if (filterBlock(rowKey, &stop)) {
                [self showRow:rowKey inSection:sectionKey];
            } else {
                [self hideRow:rowKey inSection:sectionKey];
            }
            
            if (stop) {
                break;
            }
        }
        
        if (stop) {
            break;
        }
    }
}

- (void)showRow:(id)rowKey inSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    if (row.hidden) {
        FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
        action.actionType = FAWeightedTableViewDataSourceActionInsertRow;
        action.section = section;
        action.row = row;
        [self.tableViewActions addObject:action];
    }
    
    row.hidden = NO;
}

- (void)hideRow:(id)rowKey inSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    if (!row.hidden) {
        FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
        action.actionType = FAWeightedTableViewDataSourceActionDeleteRow;
        action.section = section;
        action.row = row;
        [self.tableViewActions addObject:action];
    }
    
    row.hidden = YES;
}

- (void)hideSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    section.hidden = YES;
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.section = section;
    action.actionType = FAWeightedTableViewDataSourceActionDeleteSection;
    
    [self.tableViewActions addObject:action];
}

- (void)showSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    section.hidden = NO;
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.section = section;
    action.actionType = FAWeightedTableViewDataSourceActionInsertSection;
    
    [self.tableViewActions addObject:action];
}

- (void)clearSection:(id <NSCopying>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    for (id rowKey in section.rowData) {
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
        action.actionType = FAWeightedTableViewDataSourceActionDeleteRow;
        action.section = section;
        action.row = row;
        [self.tableViewActions addObject:action];
    }
    
    [section.rowData removeAllObjects];
}

- (void)removeRowInSection:(id<NSCopying>)sectionKey forObject:(id)rowKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    [section.rowData removeObjectForKey:rowKey];
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.actionType = FAWeightedTableViewDataSourceActionDeleteRow;
    action.section = section;
    action.row = row;
    [self.tableViewActions addObject:action];
}

- (void)insertRow:(id)rowKey inSection:(id<NSCopying>)sectionKey withWeight:(NSInteger)weight
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    if (!section) {
        [NSException raise:NSInternalInconsistencyException format:@"FAWeightedTableViewDataSource: Tried to insert a row into a section that doesn't exist. Failing!"];
        return;
    }
    
    NSMutableDictionary *rowData = section.rowData;
    
    if (!rowData) {
        rowData = [NSMutableDictionary dictionary];
        section.rowData = rowData;
    }
    
    FAWeightedTableViewDataSourceRow *row = [FAWeightedTableViewDataSourceRow rowWithKey:rowKey weight:weight];
    rowData[rowKey] = row;
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.actionType = FAWeightedTableViewDataSourceActionInsertRow;
    action.section = section;
    action.row = row;
    [self.tableViewActions addObject:action];
}


- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:nil];
}

- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title
{
    if (!self.weightedSections) {
        self.weightedSections = [NSMutableDictionary dictionary];
    }
    
    FAWeightedTableViewDataSourceSection *section = [FAWeightedTableViewDataSourceSection sectionWithKey:key weight:weight];
    
    self.weightedSections[key] = section;
    
    if (title) {
        section.headerTitle = title;
    }
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.section = section;
    action.actionType = FAWeightedTableViewDataSourceActionInsertSection;
    
    [self.tableViewActions addObject:action];
}

- (void)removeSectionForKey:(id<NSCopying>)key
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[key];
    
    FAWeightedTableViewDataSourceAction *action = [[FAWeightedTableViewDataSourceAction alloc] init];
    action.section = section;
    action.actionType = FAWeightedTableViewDataSourceActionDeleteSection;
    
    [self.tableViewActions addObject:action];
    
    [self.weightedSections removeObjectForKey:key];
}

@end
