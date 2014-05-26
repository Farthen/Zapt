//
//  FAWeightedTableViewDataSource.m
//  Zapt
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAWeightedTableViewDataSource.h"

static dispatch_queue_t _weightedSectionsQueue = nil;
static dispatch_semaphore_t _tableViewDataSemaphore = nil;

@interface FAWeightedTableViewDataSource ()
@property NSMutableDictionary *weightedSections;
@property NSArray *weightedSectionData;
@property NSMutableDictionary *sectionsForIndexes;

@property NSMutableArray *tableViewActions;

@end

@interface FAWeightedTableViewDataSourceSection : NSObject <NSCoding, NSCopying>

@property NSMutableDictionary *rowData;

@property BOOL hidden;
@property BOOL shouldDelete;
@property BOOL dirty;

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
        self.shouldDelete = [coder decodeBoolForKey:@"shouldDelete"];
        self.dirty = [coder decodeBoolForKey:@"dirty"];
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
    [coder encodeBool:self.shouldDelete forKey:@"shouldDelete"];
    [coder encodeBool:self.dirty forKey:@"dirty"];
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeInteger:self.weight forKey:@"weight"];
    [coder encodeObject:self.headerTitle forKey:@"headerTitle"];
    [coder encodeInteger:self.lastSectionIndex forKey:@"lastSectionIndex"];
    [coder encodeInteger:self.currentSectionIndex forKey:@"currentSectionIndex"];
    
    [coder encodeObject:self.rowsForIndexes forKey:@"rowsForIndexes"];
}

- (id)copyWithZone:(NSZone *)zone
{
    FAWeightedTableViewDataSourceSection *newSection = [FAWeightedTableViewDataSourceSection sectionWithKey:self.key weight:self.weight];
    newSection.rowData = [self.rowData mapObjectsUsingBlock:^id(id key, id obj) {
        return [obj copy];
    }];
    
    newSection.hidden = self.hidden;
    newSection.headerTitle = self.headerTitle;
    newSection->_lastSectionIndex = self->_lastSectionIndex;
    newSection->_currentSectionIndex = self->_currentSectionIndex;
    
    return newSection;
}

- (instancetype)initWithKey:(id <NSCopying, NSCoding>)key weight:(NSInteger)weight
{
    self = [super init];
    
    if (self) {
        self.key = key;
        self.weight = weight;
        self.hidden = NO;
        self.rowsForIndexes = [NSMutableDictionary dictionary];
        _currentSectionIndex = -1;
        _lastSectionIndex = -1;
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

@interface FAWeightedTableViewDataSourceRow : NSObject <NSCoding, NSCopying>

@property id <NSCoding, NSCopying> key;
@property NSInteger weight;
@property BOOL hidden;
@property BOOL shouldDelete;
@property BOOL dirty;
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
        self.shouldDelete = [coder decodeBoolForKey:@"shouldDelete"];
        self.dirty = [coder decodeBoolForKey:@"dirty"];
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
    [coder encodeBool:self.shouldDelete forKey:@"shouldDelete"];
    [coder encodeBool:self.dirty forKey:@"dirty"];
    [coder encodeObject:self.lastIndexPath forKey:@"lastIndexPath"];
    [coder encodeObject:self.currentIndexPath forKey:@"currentIndexPath"];
}

- (id)copyWithZone:(NSZone *)zone
{
    FAWeightedTableViewDataSourceRow *newRow = [FAWeightedTableViewDataSourceRow rowWithKey:self.key weight:self.weight];
    newRow.hidden = self.hidden;
    newRow->_lastIndexPath = self->_lastIndexPath;
    newRow->_currentIndexPath = self->_currentIndexPath;
    
    return newRow;
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
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.weightedSections forKey:@"weightedSections"];
    [coder encodeObject:self.weightedSectionData forKey:@"weightedSectionData"];
    [coder encodeObject:self.sectionsForIndexes forKey:@"sectionsForIndexes"];
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _weightedSectionsQueue = dispatch_queue_create("weightedSectionsQueue", DISPATCH_QUEUE_SERIAL);
        _tableViewDataSemaphore = dispatch_semaphore_create(1);
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = self.tableViewData[indexPath.section];
    id rowKey = [sectionArray objectAtIndex:indexPath.row];
    
    NSNumber *sectionNumber = [NSNumber numberWithUnsignedInteger:(NSUInteger)indexPath.section];
    FAWeightedTableViewDataSourceSection *section = self.sectionsForIndexes[sectionNumber];
    id sectionKey = section.key;
    
    NSString *reuseIdentifier = nil;
    if (self.reuseIdentifierBlock) {
        reuseIdentifier = self.reuseIdentifierBlock(sectionKey, rowKey);
    }
    
    id cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        if (!self.weightedCellCreationBlock && !self.cellCreationBlock) {
            cell = [[self.cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        } else if (self.weightedCellCreationBlock) {
            cell = self.weightedCellCreationBlock(sectionKey, rowKey);
        } else if (self.cellCreationBlock) {
            cell = self.cellCreationBlock(rowKey);
        }
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
    // Dispatch this on an async queue to wait for the semaphore. This is needed
    // because otherwise the dispatch sync to the main thread would horribly fail
    dispatch_async(_weightedSectionsQueue, ^{
        dispatch_semaphore_wait(_tableViewDataSemaphore, DISPATCH_TIME_FOREVER);
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
        
        NSMutableDictionary *newWeightedSections = [NSMutableDictionary dictionary];
        NSMutableDictionary *filteredSections = [NSMutableDictionary dictionary];
        
        [self.weightedSections enumerateKeysAndObjectsUsingBlock:^(id key, FAWeightedTableViewDataSourceSection *section, BOOL *stop) {
            
            if ((section.shouldDelete || section.hidden) && section.currentSectionIndex != -1) {
                [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section actionType:FAWeightedTableViewDataSourceActionDeleteSection animation:UITableViewRowAnimationFade]];
                
                section.currentSectionIndex = -1;
            }
            
            if (!section.shouldDelete) {
                [newWeightedSections setObject:section forKey:key];
                
                if (!section.hidden) {
                    [filteredSections setObject:section forKey:key];
                }
            }
        }];
        
        self.weightedSections = newWeightedSections;
        
        NSArray *sortedWeightedSections = [filteredSections.allValues sortedArrayUsingComparator:weightComparator];
        
        self.sectionsForIndexes = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < sortedWeightedSections.count; i++) {
            FAWeightedTableViewDataSourceSection *section = sortedWeightedSections[i];
            
            self.sectionsForIndexes[[NSNumber numberWithUnsignedInteger:i]] = section;
        }
        
        NSMutableArray *headerTitles = [NSMutableArray array];
        
        NSArray *newTableViewData = [sortedWeightedSections mapUsingBlock:^id(FAWeightedTableViewDataSourceSection *section, NSUInteger sectionIdx) {
            
            NSMutableDictionary *newRowData = [NSMutableDictionary dictionary];
            NSMutableDictionary *filteredRows = [NSMutableDictionary dictionary];
            
            [section.rowData enumerateKeysAndObjectsUsingBlock:^(id key, FAWeightedTableViewDataSourceRow *row, BOOL *stop) {
                
                if ((row.shouldDelete || row.hidden) && row.currentIndexPath) {
                    [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section row:row actionType:FAWeightedTableViewDataSourceActionDeleteRow animation:UITableViewRowAnimationFade]];
                    row.currentIndexPath = nil;
                }
                
                if (!row.shouldDelete) {
                    [newRowData setObject:row forKey:key];
                    
                    if (!row.hidden) {
                        [filteredRows setObject:row forKey:key];
                    }
                }
            }];
            
            section.rowData = newRowData;
            
            NSArray *sortedWeightedRows = [filteredRows.allValues sortedArrayUsingComparator:weightComparator];
            
            if (!sortedWeightedRows) {
                sortedWeightedRows = [NSArray array];
            }

            section.currentSectionIndex = sectionIdx;
            
            if (section.lastSectionIndex == -1) {
                [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section actionType:FAWeightedTableViewDataSourceActionInsertSection animation:UITableViewRowAnimationFade]];
            } else if (section.lastSectionIndex != (NSInteger)sectionIdx) {
                [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section actionType:FAWeightedTableViewDataSourceActionMoveSection animation:UITableViewRowAnimationFade]];
            } else if (section.dirty) {
                [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section actionType:FAWeightedTableViewDataSourceActionReloadSection animation:UITableViewRowAnimationFade]];
                section.dirty = NO;
            }
            
            id title = section.headerTitle;
            
            if (!title) {
                title = [NSNull null];
            }
            
            [headerTitles addObject:title];
            
            return [sortedWeightedRows mapUsingBlock:^id(FAWeightedTableViewDataSourceRow *row, NSUInteger rowIdx) {
                section.rowsForIndexes[[NSNumber numberWithUnsignedInteger:rowIdx]] = row;
                
                row.currentIndexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
                
                if (!row.lastIndexPath) {
                    [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section row:row actionType:FAWeightedTableViewDataSourceActionInsertRow animation:UITableViewRowAnimationFade]];
                } else if (![row.lastIndexPath isEqual:row.currentIndexPath]) {
                    [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section row:row actionType:FAWeightedTableViewDataSourceActionMoveRow animation:UITableViewRowAnimationFade]];
                } else if (row.dirty) {
                    [self.tableViewActions addObject:[FAWeightedTableViewDataSourceAction actionForSection:section row:row actionType:FAWeightedTableViewDataSourceActionReloadRow animation:UITableViewRowAnimationFade]];
                    row.dirty = NO;
                }
                
                return row.key;
            }];
        }];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Do this in the main thread to prevent issues with the table view not being done loading data
            self.tableViewData = newTableViewData;
            self.headerTitles = headerTitles;
            
            [self interpolateDataChange];
            dispatch_semaphore_signal(_tableViewDataSemaphore);
        });
    });
}

- (void)reloadData
{
    dispatch_async(_weightedSectionsQueue, ^{
        [self.tableViewActions removeAllObjects];
        [self.tableView reloadData];
    });
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
            // If the row was removed or hidden: clear its current index path
            [self.tableView deleteRowsAtIndexPaths:@[row.lastIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionMoveRow) {
            [self.tableView moveRowAtIndexPath:row.lastIndexPath toIndexPath:row.currentIndexPath];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionReloadRow) {
            [self.tableView reloadRowsAtIndexPaths:@[row.currentIndexPath] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionInsertSection) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section.currentSectionIndex] withRowAnimation:animation];
            
        } else if (actionType == FAWeightedTableViewDataSourceActionDeleteSection) {
            // If the row was removed or hidden: clear its current section index
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
    if (!sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        if (!section.shouldDelete) {
            for (id rowKey in section.rowData) {
                FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
                
                if (row.hidden) {
                    [self showRow:rowKey inSection:section.key];
                }
            }
        }
    });
}

- (void)clearFilters
{
    dispatch_async(_weightedSectionsQueue, ^{
        for (id sectionKey in self.weightedSections) {
            [self clearFiltersForSection:sectionKey];
        }
    });
}

- (void)filterRowsUsingBlock:(BOOL (^)(id key, BOOL *stop))filterBlock
{
    if (!filterBlock) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        BOOL stop = NO;
        
        for (id sectionKey in self.weightedSections) {
            FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
            
            if (!section.shouldDelete) {
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
    });
}

- (NSUInteger)numberOfSections
{
    __block NSUInteger count;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        count = [self.weightedSections filterUsingBlock:^BOOL(id key, FAWeightedTableViewDataSourceSection *section, BOOL *stop) {
            return !section.shouldDelete;
        }].count;
    });
    
    return count;
}

- (NSUInteger)numberOfVisibleSections
{
    __block NSUInteger count;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        count = [self.weightedSections.allValues countUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            FAWeightedTableViewDataSourceSection *section = obj;
            
            return !section.hidden && !section.shouldDelete;
        }];
    });
    
    return count;
}

- (void)hideRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey
{
    if (!rowKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        row.hidden = YES;
    });
}

- (void)showRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey
{
    if (!rowKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        row.hidden = NO;
    });
}

- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation
{
    if (!sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        section.hidden = YES;
    });
}

- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey
{
    [self hideSection:sectionKey animation:UITableViewRowAnimationFade];
}

- (void)showSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation
{
    if (!sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        section.hidden = NO;
    });
}

- (void)showSection:(id <NSCopying, NSCoding>)sectionKey
{
    [self showSection:sectionKey animation:UITableViewRowAnimationFade];
}

- (void)clearSection:(id <NSCopying, NSCoding>)sectionKey
{
    if (!sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        for (id rowKey in section.rowData) {
            FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
            row.shouldDelete = YES;
        }
    });
}

- (id <NSCopying, NSCoding>)largestRowKeyInSection:(id <NSCopying, NSCoding>)sectionKey
{
    __block id <NSCopying, NSCoding> largestKey = nil;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        if (!section.shouldDelete) {
            FAWeightedTableViewDataSourceRow *row = [section.rowData.allValues reduceUsingBlock:^id(id memo, id object, NSUInteger idx, BOOL *stop) {
                FAWeightedTableViewDataSourceRow *memoRow = memo;
                FAWeightedTableViewDataSourceRow *row = object;
                
                if (!row.shouldDelete && row.weight >= memoRow.weight) {
                    return row;
                }
                
                return memo;
            }];
            
            largestKey = row.key;
        }
        
    });
    
    return largestKey;
}

- (id <NSCopying, NSCoding>)smallestRowKeyInSection:(id <NSCopying, NSCoding>)sectionKey
{
    __block id <NSCopying, NSCoding> smallestKey = nil;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        if (!section.shouldDelete) {
            FAWeightedTableViewDataSourceRow *row = [section.rowData.allValues reduceUsingBlock:^id(id memo, id object, NSUInteger idx, BOOL *stop) {
                FAWeightedTableViewDataSourceRow *memoRow = memo;
                FAWeightedTableViewDataSourceRow *row = object;
                
                if (!row.shouldDelete && row.weight <= memoRow.weight) {
                    return row;
                }
                
                return memo;
            }];
            
            smallestKey = row.key;
        }
    });
    
    
    return smallestKey;
}

- (BOOL)hasRowWithKey:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey;
{
    __block BOOL hasRow;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        if (row.shouldDelete) {
            hasRow = NO;
        } else {
            hasRow = !!row;
        }
        
    });
    
    return hasRow;
}

- (NSSet *)rowKeysForSection:(id <NSCopying, NSCoding>)sectionKey;
{
    __block NSSet *rowKeys;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        rowKeys = [section.rowData filterUsingBlock:^BOOL(id key, id obj, BOOL *stop) {
            return !section.shouldDelete;
        }].allKeysSet;
    });
    
    return rowKeys;
}

- (NSSet *)sectionKeys
{
    __block NSSet *sectionKeys;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        sectionKeys = [self.weightedSections filterUsingBlock:^BOOL(id key, FAWeightedTableViewDataSourceSection *section, BOOL *stop) {
            return !section.shouldDelete;
        }].allKeysSet;
    });
    
    return sectionKeys;
}

- (NSUInteger)numberOfRowsInSection:(id<NSCopying,NSCoding>)sectionKey
{
    __block NSUInteger count;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        
        count = [section.rowData.allValues countUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            FAWeightedTableViewDataSourceRow *row = obj;
            return !row.shouldDelete;
        }];
    });
    
    return count;
}

- (NSUInteger)numberOfVisibleRowsInSection:(id<NSCopying,NSCoding>)sectionKey
{
    __block NSUInteger count;
    
    dispatch_sync(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        count = [section.rowData.allValues countUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            FAWeightedTableViewDataSourceRow *row = obj;
            return !row.hidden && !row.shouldDelete;
        }];
    });
    
    return count;
}

- (void)removeRow:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey
{
    if (!rowKey || !sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
        FAWeightedTableViewDataSourceRow *row = section.rowData[rowKey];
        
        row.shouldDelete = YES;
    });
}

- (void)insertRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey withWeight:(NSInteger)weight
{
    [self insertRow:rowKey inSection:sectionKey withWeight:weight hidden:NO];
}

- (void)insertRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey withWeight:(NSInteger)weight hidden:(BOOL)hidden
{
    if (!rowKey || !sectionKey) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
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
        
        FAWeightedTableViewDataSourceRow *oldRow = rowData[rowKey];
        FAWeightedTableViewDataSourceRow *row = [FAWeightedTableViewDataSourceRow rowWithKey:rowKey weight:weight];
        
        if (oldRow) {
            row = oldRow;
        }
        
        row.hidden = hidden;
        row.dirty = YES;
        row.shouldDelete = NO;
        
        rowData[rowKey] = row;
    });
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:nil hidden:NO];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight hidden:(BOOL)hidden
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:nil hidden:hidden];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight headerTitle:(NSString *)title
{
    [self createSectionForKey:key withWeight:weight andHeaderTitle:title hidden:NO];
}

- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title hidden:(BOOL)hidden
{
    if (!key) {
        return;
    }
    
    dispatch_async(_weightedSectionsQueue, ^{
        if (!self.weightedSections) {
            self.weightedSections = [NSMutableDictionary dictionary];
        }
        
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
        section.dirty = YES;
        section.shouldDelete = NO;
        
        self.weightedSections[key] = section;
        
        if (title) {
            section.headerTitle = title;
        }
    });
}

- (void)removeSectionForKey:(id <NSCopying, NSCoding>)key
{
    dispatch_async(_weightedSectionsQueue, ^{
        FAWeightedTableViewDataSourceSection *section = self.weightedSections[key];
        section.shouldDelete = YES;
    });
}

- (void)removeAllSections
{
    dispatch_async(_weightedSectionsQueue, ^{
        for (id sectionKey in self.weightedSections) {
            FAWeightedTableViewDataSourceSection *section = self.weightedSections[sectionKey];
            section.shouldDelete = YES;
        }
    });
}

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row
{
    dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(_tableViewDataSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [super reloadSection:section row:row];
            dispatch_semaphore_signal(_tableViewDataSemaphore);
        });
    });
}

- (void)reloadRowsWithKeys:(NSSet *)objects animation:(UITableViewRowAnimation)animation
{
    dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(_tableViewDataSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [super reloadRowsWithKeys:objects animation:animation];
            dispatch_semaphore_signal(_tableViewDataSemaphore);
        });
    });
}

@end
