//
//  FAWeightedTableViewDataSource.h
//  Zapr
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDataSource.h"

@interface FAWeightedTableViewDataSource : FAArrayTableViewDataSource

- (void)recalculateWeight;

- (void)clearFiltersForSection:(id <NSCopying>)sectionKey;
- (void)clearFilters;
- (void)filterRowsUsingBlock:(BOOL (^)(id key, BOOL *stop))filterBlock;

- (void)showRow:(id)rowKey inSection:(id <NSCopying>)sectionKey;
- (void)hideRow:(id)rowKey inSection:(id <NSCopying>)sectionKey;

- (void)removeRowInSection:(id<NSCopying>)sectionKey forObject:(id)rowKey;
- (void)insertRow:(id)rowKey inSection:(id<NSCopying>)sectionKey withWeight:(NSInteger)weight;

- (void)hideSection:(id <NSCopying>)sectionKey;
- (void)hideSection:(id<NSCopying>)sectionKey animation:(UITableViewRowAnimation)animation;
- (void)showSection:(id <NSCopying>)sectionKey;
- (void)showSection:(id <NSCopying>)sectionKey animation:(UITableViewRowAnimation)animation;

- (void)clearSection:(id <NSCopying>)sectionKey;
- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight;
- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title;
- (void)removeSectionForKey:(id<NSCopying>)key;

- (void)reloadData;
- (void)interpolateDataChange;

typedef id (^FAWeightedTableViewCellCreationBlock)(id sectionKey, id rowKey);
@property (nonatomic, copy) FAWeightedTableViewCellCreationBlock weightedCellCreationBlock;

typedef void (^FAWeightedTableViewCellConfigurationBlock)(id cell, id sectionKey, id rowKey);
@property (nonatomic, copy) FAWeightedTableViewCellConfigurationBlock weightedConfigurationBlock;

@end
