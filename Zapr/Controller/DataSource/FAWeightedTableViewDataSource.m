//
//  FAWeightedTableViewDataSource.m
//  Zapr
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAWeightedTableViewDataSource.h"

@interface FAWeightedTableViewDataSource ()

@property NSMutableDictionary *weightedSections;
@property NSArray *weightedSectionData;

@end

@implementation FAWeightedTableViewDataSource

- (void)recalculateWeight
{
    NSComparisonResult (^weightComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
        NSNumber *weight1 = obj1[@"weight"];
        NSNumber *weight2 = obj2[@"weight"];
        return [weight1 compare:weight2];
    };
    
    NSArray *sortedWeightedSections = [self.weightedSections.allValues sortedArrayUsingComparator:weightComparator];
    
    NSMutableArray *headerTitles = [NSMutableArray array];
    
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

- (void)removeRowInSection:(id<NSCopying>)sectionKey forKey:(id<NSCopying>)key
{
    NSMutableDictionary *section = self.weightedSections[sectionKey];
    [section removeObjectForKey:key];
}

- (void)insertRow:(id)rowObject inSection:(id<NSCopying>)sectionKey forKey:(id<NSCopying>)key withWeight:(NSInteger)weight
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
    
    sectionData[key] = [@{@"rowObject": rowObject, @"weight": [NSNumber numberWithInteger:weight]} mutableCopy];
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
    
    [self.weightedSections setObject:[@{@"weight": [NSNumber numberWithInteger:weight]} mutableCopy] forKey:key];
    
    if (title) {
        self.weightedSections[key][@"headerTitle"] = title;
    }
}

- (void)removeSectionForKey:(id<NSCopying>)key
{
    [self.weightedSections removeObjectForKey:key];
}

@end
