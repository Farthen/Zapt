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
@property NSMutableDictionary *sectionsToKeys;

@end

@implementation FAWeightedTableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if (!cell) {
        cell = [[self.cellClass alloc] init];
    }
    
    if (self.weightedConfigurationBlock) {
        NSArray *section = self.tableViewData[indexPath.section];
        id object = [section objectAtIndex:indexPath.row];
        
        id sectionKey = self.sectionsToKeys[[NSNumber numberWithUnsignedInteger:(NSUInteger)indexPath.section]];
        
        self.weightedConfigurationBlock(cell, sectionKey, object);
    } else if (self.configurationBlock) {
        NSArray *section = self.tableViewData[indexPath.section];
        id object = [section objectAtIndex:indexPath.row];
        
        self.configurationBlock(cell, object);
    }
    
    return cell;
}

- (void)recalculateWeight
{
    NSComparisonResult (^weightComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
        NSNumber *weight1 = obj1[@"weight"];
        NSNumber *weight2 = obj2[@"weight"];
        return [weight1 compare:weight2];
    };
    
    NSArray *sortedWeightedSections = [self.weightedSections.allValues sortedArrayUsingComparator:weightComparator];
    
    NSMutableArray *headerTitles = [NSMutableArray array];
    
    self.sectionsToKeys = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < sortedWeightedSections.count; i++) {
        NSDictionary *sectionDict = sortedWeightedSections[i];
        
        [self.sectionsToKeys setObject:sectionDict[@"key"] forKey:[NSNumber numberWithUnsignedInteger:i]];
    }

    self.tableViewData = [sortedWeightedSections mapUsingBlock:^id(id obj, NSUInteger idx) {
        NSMutableDictionary *sectionData = obj[@"sectionData"];
        
        NSArray *sortedWeightedRows = [sectionData.allValues sortedArrayUsingComparator:weightComparator];
        
        id title = obj[@"headerTitle"];
        
        if (!title) {
            title = [NSNull null];
        }
        
        [headerTitles addObject:title];
        
        return [sortedWeightedRows mapUsingBlock:^id(id obj, NSUInteger idx) {
            return obj[@"rowObject"];
        }];
    }];
    
    self.headerTitles = headerTitles;
    
    [self.tableView reloadData];
}

- (void)removeRowInSection:(id<NSCopying>)sectionKey forObject:(id)rowObject
{
    NSMutableDictionary *section = self.weightedSections[sectionKey];
    [section removeObjectForKey:rowObject];
}

- (void)insertRow:(id)rowObject inSection:(id<NSCopying>)sectionKey withWeight:(NSInteger)weight
{
    NSMutableDictionary *section = self.weightedSections[sectionKey];
    
    if (!section) {
        [NSException raise:NSInternalInconsistencyException format:@"FAWeightedTableViewDataSource: Tried to insert a row into a section that doesn't exist. Failing!"];
        return;
    }
    
    NSMutableDictionary *sectionData = section[@"sectionData"];
    
    if (!sectionData) {
        sectionData = [NSMutableDictionary dictionary];
        section[@"sectionData"] = sectionData;
    }
    
    sectionData[rowObject] = [@{@"rowObject": rowObject, @"weight": [NSNumber numberWithInteger:weight]} mutableCopy];
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
    
    [self.weightedSections setObject:[@{@"weight": [NSNumber numberWithInteger:weight], @"key": key} mutableCopy] forKey:key];
    
    if (title) {
        self.weightedSections[key][@"headerTitle"] = title;
    }
}

- (void)removeSectionForKey:(id<NSCopying>)key
{
    [self.weightedSections removeObjectForKey:key];
}

@end
