//
//  FAWeightedTableViewDataSource.m
//  Zapt
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

@interface FAWeightedTableViewDataSourceSection : NSObject <NSCoding>

@property NSMutableDictionary *rowData;
@property BOOL hidden;
@property id <NSCopying, NSCoding> key;
@property NSInteger weight;
@property NSString *headerTitle;
@property (readonly) NSInteger lastSectionIndex;
@property NSInteger currentSectionIndex;

@property NSMutableDictionary *rowsForIndexes;

- (instancetype)initWithKey:(id <NSCopying, NSCoding>)key weight:(NSInteger)weight;
+ (instancetype)sectionWithKey:(id <NSCopying, NSCoding>)key weight:(NSInteger)weight;

@end

@implementation FAWeightedTableViewDataSourceSection {
    NSInteger _currentSectionIndex;
    NSInteger _lastSectionIndex;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FAWeightedTableViewDataSourceSection key:%@ weight:%ld rowCount:%ld hidden:%@ lastIndex:%ld currentIndex:%ld headerTitle:%@>", self.key, (long)self.weight, (long)self.rowData.count, self.hidden ? @"YES" : @"NO", (long)self.lastSectionIndex, (long)self.currentSectionIndex, self.headerTitle];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    if (self) {
        self.rowData = [coder decodeObjectForKey:@"rowData"];
        self.hidden = [coder decodeBoolForKey:@"hidden"];
        self.key = [coder decodeObjectForKey:@"key"];
        self.weight = [coder decodeIntegerForKey:@"weight"];
        self.headerTitle = [coder decodeObjectForKey:@"headerTitle"];
        _lastSectionIndex = [coder decodeIntegerForKey:@"lastSectionIndex"];
        _currentSectionIndex = [coder decodeIntegerForKey:@"currentSectionIndex"];
        
        self.rowsForIndexes = [coder decodeObjectForKey:@"rowsForIndexes"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.rowData forKey:@"rowData"];
    [coder encodeBool:self.hidden forKey:@"hidden"];
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeInteger:self.weight forKey:@"weight"];
    [coder encodeObject:self.headerTitle forKey:@"headerTitle"];
    [coder encodeInteger:self.lastSectionIndex forKey:@"lastSectionIndex"];
    [coder encodeInteger:self.currentSectionIndex forKey:@"currentSectionIndex"];
    
    [coder encodeObject:self.rowsForIndexes forKey:@"rowsForIndexes"];
}

- (instancetype)initWithKey:(id <NSCopying, NSCoding>)key weight:(NSInteger)weight
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

+ (instancetype)sectionWithKey:(id <NSCopying, NSCoding>)key weight:(NSInteger)weight
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

@interface FAWeightedTableViewDataSourceRow : NSObject <NSCoding>

@property id <NSCoding, NSCopying> key;
@property NSInteger weight;
@property BOOL hidden;
@property (readonly) NSIndexPath *lastIndexPath;
@property NSIndexPath *currentIndexPath;

- (instancetype)initWithKey:(id)obj weight:(NSInteger)weight;
+ (instancetype)rowWithKey:(id <NSCopying, NSCoding>)obj weight:(NSInteger)weight;

@end

@implementation FAWeightedTableViewDataSourceRow {
    NSIndexPath *_lastIndexPath;
    NSIndexPath *_currentIndexPath;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FAWeightedTableViewDataSourceRow key:%@ weight:%ld hidden:%@ lastIndexPath:%@ currentIndexPath:%@>", self.key, (long)self.weight, self.hidden ? @"YES" : @"NO", self.lastIndexPath, self.currentIndexPath];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    if (self) {
        self.key = [coder decodeObjectForKey:@"key"];
        self.weight = [coder decodeIntegerForKey:@"weight"];
        self.hidden = [coder decodeBoolForKey:@"hidden"];
        _lastIndexPath = [coder decodeObjectForKey:@"lastIndexPath"];
        _currentIndexPath = [coder decodeObjectForKey:@"currentIndexPath"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeInteger:self.weight forKey:@"weight"];
    [coder encodeBool:self.hidden forKey:@"hidden"];
    [coder encodeObject:self.lastIndexPath forKey:@"lastIndexPath"];
    [coder encodeObject:self.currentIndexPath forKey:@"currentIndexPath"];
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

+ (instancetype)rowWithKey:(id <NSCopying, NSCoding>)obj weight:(NSInteger)weight
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

typedef NS_ENUM(NSUInteger, FAWeightedTableViewDataSourceActionType) {
    FAWeightedTableViewDataSourceActionInsertRow,
    FAWeightedTableViewDataSourceActionDeleteRow,
    FAWeightedTableViewDataSourceActionMoveRow,
    
    FAWeightedTableViewDataSourceActionInsertSection,
    FAWeightedTableViewDataSourceActionDeleteSection,
    FAWeightedTableViewDataSourceActionMoveSection,
    
    FAWeightedTableViewDataSourceActionReloadRow,
    FAWeightedTableViewDataSourceActionReloadSection
};

@property FAWeightedTableViewDataSourceActionType actionType;
@property FAWeightedTableViewDataSourceSection *section;
@property FAWeightedTableViewDataSourceRow *row;
@property UITableViewRowAnimation animation;

- (instancetype)initWithSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation;

+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section actionType:(FAWeightedTableViewDataSourceActionType)actionType;
+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation;
+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType;
+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation;

@end

@implementation FAWeightedTableViewDataSourceAction

- (NSString *)description
{
    if (self.row) {
        return [NSString stringWithFormat:@"<FAWeightedTableViewDataSourceAction actionType:%@ section:%@ row:%@>", [self stringForActionType], self.section, self.row];
    }
    
    return [NSString stringWithFormat:@"<FAWeightedTableViewDataSourceAction actionType:%@ section:%@>", [self stringForActionType], self.section];
}

- (NSString *)stringForActionType
{
    switch (self.actionType) {
        case FAWeightedTableViewDataSourceActionInsertRow:
            return @"Insert Row";
        case FAWeightedTableViewDataSourceActionDeleteRow:
            return @"Delete Row";
        case FAWeightedTableViewDataSourceActionMoveRow:
            return @"Move Row";
        case FAWeightedTableViewDataSourceActionInsertSection:
            return @"Insert Section";
        case FAWeightedTableViewDataSourceActionDeleteSection:
            return @"Delete Section";
        case FAWeightedTableViewDataSourceActionMoveSection:
            return @"Move Section";
        case FAWeightedTableViewDataSourceActionReloadRow:
            return @"Reload Row";
        case FAWeightedTableViewDataSourceActionReloadSection:
            return @"Reload Section";
        default:
            return @"<unknown>";
    }
}

+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section actionType:(FAWeightedTableViewDataSourceActionType)actionType
{
    return [[self alloc] initWithSection:section row:nil actionType:actionType animation:UITableViewRowAnimationFade];
}

+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation
{
    return [[self alloc] initWithSection:section row:nil actionType:actionType animation:animation];
}

+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType
{
    return [[self alloc] initWithSection:section row:row actionType:actionType animation:UITableViewRowAnimationFade];
}

+ (instancetype)actionForSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation
{
    return [[self alloc] initWithSection:section row:row actionType:actionType animation:animation];
}

- (instancetype)initWithSection:(FAWeightedTableViewDataSourceSection *)section row:(FAWeightedTableViewDataSourceRow *)row actionType:(FAWeightedTableViewDataSourceActionType)actionType animation:(UITableViewRowAnimation)animation
{
    self = [super init];
    
    if (self) {
        self.section = section;
        self.row = row;
        self.actionType = actionType;
        self.animation = animation;
    }
    
    return self;
}

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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        self.weightedSections = [coder decodeObjectForKey:@"weightedSections"];
        self.weightedSectionData = [coder decodeObjectForKey:@"weightedSectionData"];
        self.sectionsForIndexes = [coder decodeObjectForKey:@"sectionsForIndexes"];
        self.tableViewActions = [coder decodeObjectForKey:@"tableViewActions"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.weightedSections forKey:@"weightedSections"];
    [coder encodeObject:self.weightedSectionData forKey:@"weightedSectionData"];
    [coder encodeObject:self.sectionsForIndexes forKey:@"sectionsForIndexes"];
    [coder encodeObject:self.tableViewActions forKey:@"tableViewActions"];
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
    
    for (FAWeightedTableViewDataSourceSection *section in self.weightedSections.allValues) {
        if (section.hidden) {
            section.currentSectionIndex = -1;
        }
        
        for (FAWeightedTableViewDataSourceRow *row in section.rowData.allValues) {
            if (row.hidden) {
                row.currentIndexPath = nil;
            }
        }
    }
    
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
        
        if (!sortedWeightedRows) {
            sortedWeightedRows = [NSArray array];
        }
        
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
    CGPoint scrollPosition = self.tableView.contentOffset;
    
    [self.tableView beginUpdates];
    
    for (FAWeightedTableViewDataSourceAction *action in self.tableViewActions) {
        
        UITableViewRowAnimation animation = action.animation;
        
        FAWeightedTableViewDataSourceActionType actionType = action.actionType;
        FAWeightedTableViewDataSourceSection *section = action.section;
        
        // This is nil for section actions
        FAWeightedTableViewDataSourceRow *row = action.row;
        
        
        if (actionType == FAWeightedTableViewDataSourceActionInsertRow) {
            [self.tableView insertRowsAtIndexPaths:@[row.currentIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionDeleteRow) {
            [self.tableView deleteRowsAtIndexPaths:@[row.lastIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionMoveRow) {
            [self.tableView moveRowAtIndexPath:row.lastIndexPath toIndexPath:row.currentIndexPath];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionReloadRow) {
            [self.tableView reloadRowsAtIndexPaths:@[row.currentIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionInsertSection) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section.currentSectionIndex] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionDeleteSection) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section.lastSectionIndex] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionMoveSection) {
            [self.tableView moveSection:section.lastSectionIndex toSection:section.currentSectionIndex];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionReloadSection) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section.currentSectionIndex] withRowAnimation:animation];
            
        }
    }
    
    [self.tableView endUpdates];
    [self.tableViewActions removeAllObjects];
    
    // Fix the scroll position after reloading
    CGSize contentSize = self.tableView.contentSize;
    
    // Calculate the biggest possible point for the contentoffset
    CGPoint biggestPoint = CGPointMake(contentSize.width, contentSize.height);
    scrollPosition.x = MIN(biggestPoint.x, scrollPosition.x);
    scrollPosition.y = MIN(biggestPoint.y, scrollPosition.y);
    
    self.tableView.contentOffset = scrollPosition;
}

- (void)clearFiltersForSection:(id <NSCopying, NSCoding>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    for (id rowKey in section.rowData) {
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        if (row.hidden) {
            [self showRow:rowKey inSection:section.key];
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

- (void)hideRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    if (row && !row.hidden && row.currentIndexPath && !section.hidden) {
        FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                              row:row
                                                       actionType:FAWeightedTableViewDataSourceActionDeleteRow];
        [self.tableViewActions addObject:action];
    }
    
    row.hidden = YES;
}

- (void)showRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    if (row && row.hidden && !row.currentIndexPath && !section.hidden) {
        FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                              row:row
                                                       actionType:FAWeightedTableViewDataSourceActionInsertRow];
        [self.tableViewActions addObject:action];
    }
    
    row.hidden = NO;
}

- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    if (section && !section.hidden && section.currentSectionIndex != -1) {
        FAWeightedTableViewDataSourceAction *action =
        [FAWeightedTableViewDataSourceAction actionForSection:section
                                                   actionType:FAWeightedTableViewDataSourceActionDeleteSection
                                                    animation:animation];
        [self.tableViewActions addObject:action];
    }
    
    section.hidden = YES;
}

- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey
{
    [self hideSection:sectionKey animation:UITableViewRowAnimationFade];
}

- (void)showSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    if (section && section.hidden && section.currentSectionIndex == -1) {
        FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                       actionType:FAWeightedTableViewDataSourceActionInsertSection
                                                        animation:animation];
        [self.tableViewActions addObject:action];
    }
    
    section.hidden = NO;
}

- (void)showSection:(id <NSCopying, NSCoding>)sectionKey
{
    [self showSection:sectionKey animation:UITableViewRowAnimationFade];
}

- (void)clearSection:(id <NSCopying, NSCoding>)sectionKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    
    for (id rowKey in section.rowData) {
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        if (row.currentIndexPath && !row.hidden) {
            FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                              row:row
                                                       actionType:FAWeightedTableViewDataSourceActionDeleteRow];
            [self.tableViewActions addObject:action];
        }
    }
    
    [section.rowData removeAllObjects];
}

- (void)removeRowInSection:(id <NSCopying, NSCoding>)sectionKey forObject:(id)rowKey
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
    FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
    
    [section.rowData removeObjectForKey:rowKey];
    
    if (!section.hidden) {
        if (row && !row.hidden && row.currentIndexPath) {
            FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                              row:row
                                                       actionType:FAWeightedTableViewDataSourceActionDeleteRow
                                                        animation:UITableViewRowAnimationFade];
            [self.tableViewActions addObject:action];
        }
    }
}

- (void)insertRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey withWeight:(NSInteger)weight
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
    
    FAWeightedTableViewDataSourceAction *action;
    FAWeightedTableViewDataSourceRow *oldRow = rowData[rowKey];
    FAWeightedTableViewDataSourceRow *row = [FAWeightedTableViewDataSourceRow rowWithKey:rowKey weight:weight];
    
    if (!section.hidden) {
        if (oldRow) {
            // Only replace the data, don't add a row
            if (oldRow.currentIndexPath) {
                action = [FAWeightedTableViewDataSourceAction actionForSection:section
                                                                           row:oldRow
                                                                    actionType:FAWeightedTableViewDataSourceActionReloadRow
                                                                     animation:UITableViewRowAnimationNone];
            }
        } else {
            action = [FAWeightedTableViewDataSourceAction actionForSection:section
                                                                       row:row
                                                                actionType:FAWeightedTableViewDataSourceActionInsertRow];
        }
    }
    
    rowData[rowKey] = row;
    
    if (action) {
        [self.tableViewActions addObject:action];
    }
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:nil hidden:NO];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight hidden:(BOOL)hidden
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:nil hidden:hidden];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:title hidden:NO];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title hidden:(BOOL)hidden
{
    if (!self.weightedSections) {
        self.weightedSections = [NSMutableDictionary dictionary];
    }
    
    FAWeightedTableViewDataSourceAction *action;
    FAWeightedTableViewDataSourceSection *oldSection = self.weightedSections[key];
    FAWeightedTableViewDataSourceSection *section;
    
    // If there is an old section, just silently use that one and don't create a new one
    if (oldSection) {
        section = oldSection;
        section.key = key;
        section.weight = weight;
    } else {
        section = [FAWeightedTableViewDataSourceSection sectionWithKey:key weight:weight];
    }
    
    section.hidden = hidden;
    
    self.weightedSections[key] = section;
    
    if (title) {
        section.headerTitle = title;
    }
    
    // If there is an old section with this name, update the section data
    if (oldSection && oldSection.currentSectionIndex != -1) {
        if (hidden) {
            action = [FAWeightedTableViewDataSourceAction actionForSection:section
                                                                actionType:FAWeightedTableViewDataSourceActionDeleteSection];
        } else {
            action = [FAWeightedTableViewDataSourceAction actionForSection:section
                                                                actionType:FAWeightedTableViewDataSourceActionReloadSection
                                                                 animation:UITableViewRowAnimationNone];
        }
    } else if (!hidden) {
        action = [FAWeightedTableViewDataSourceAction actionForSection:section
                                                            actionType:FAWeightedTableViewDataSourceActionInsertSection];
    }
    
    if (action) {
        [self.tableViewActions addObject:action];
    }
}

- (void)removeSectionForKey:(id <NSCopying, NSCoding>)key
{
    FAWeightedTableViewDataSourceSection *section = self.weightedSections[key];
    
    if (section && !section.hidden && section.currentSectionIndex != -1) {
        FAWeightedTableViewDataSourceAction *action =
            [FAWeightedTableViewDataSourceAction actionForSection:section
                                                       actionType:FAWeightedTableViewDataSourceActionDeleteSection];
        [self.tableViewActions addObject:action];
    }
    
    [self.weightedSections removeObjectForKey:key];
}

@end
