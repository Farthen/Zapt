//
//  FAWeightedTableViewDataSource.h
//  Zapt
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDataSource.h"

@interface FAWeightedTableViewDataSource : FAArrayTableViewDataSource <NSCoding>

- (void)recalculateWeight;

- (void)clearFiltersForSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)clearFilters;
- (void)filterRowsUsingBlock:(BOOL (^)(id key, BOOL *stop))filterBlock;

- (void)showRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)hideRow:(id)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey;

- (void)removeRow:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)insertRow:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey withWeight:(NSInteger)weight;
- (void)insertRow:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey withWeight:(NSInteger)weight hidden:(BOOL)hidden;

- (id <NSCopying, NSCoding>)largestRowKeyInSection:(id <NSCopying, NSCoding>)sectionKey;
- (id <NSCopying, NSCoding>)smallestRowKeyInSection:(id <NSCopying, NSCoding>)sectionKey;

- (NSUInteger)numberOfRowsInSection:(id <NSCopying, NSCoding>)sectionKey;
- (NSUInteger)numberOfVisibleRowsInSection:(id <NSCopying, NSCoding>)sectionKey;

- (BOOL)hasRowWithKey:(id <NSCopying, NSCoding>)rowKey inSection:(id <NSCopying, NSCoding>)sectionKey;
- (NSSet *)rowKeysForSection:(id <NSCopying, NSCoding>)sectionKey;

- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)hideSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation;
- (void)showSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)showSection:(id <NSCopying, NSCoding>)sectionKey animation:(UITableViewRowAnimation)animation;
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfVisibleSections;

- (void)clearSection:(id <NSCopying, NSCoding>)sectionKey;
- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight;
- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight hidden:(BOOL)hidden;
- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title;
- (void)createSectionForKey:(id <NSCopying, NSCoding>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title hidden:(BOOL)hidden;
- (void)removeSectionForKey:(id <NSCopying, NSCoding>)key;

- (void)reloadData;
- (void)interpolateDataChange;

typedef id (^FAWeightedTableViewCellCreationBlock)(id sectionKey, id rowKey);
@property (nonatomic, copy) FAWeightedTableViewCellCreationBlock weightedCellCreationBlock;

typedef void (^FAWeightedTableViewCellConfigurationBlock)(id cell, id sectionKey, id rowKey);
@property (nonatomic, copy) FAWeightedTableViewCellConfigurationBlock weightedConfigurationBlock;

@end
