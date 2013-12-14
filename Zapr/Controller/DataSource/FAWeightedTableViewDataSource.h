//
//  FAWeightedTableViewDataSource.h
//  Zapr
//
//  Created by Finn Wilke on 14/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDataSource.h"

@interface FAWeightedTableViewDataSource : FAArrayTableViewDataSource


- (void)insertRow:(id)rowObject inSection:(id<NSCopying>)sectionKey forKey:(id<NSCopying>)key withWeight:(NSInteger)weight;
- (void)removeRowInSection:(id<NSCopying>)sectionKey forKey:(id<NSCopying>)key;

- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight;
- (void)createSectionForKey:(id <NSCopying>)key withWeight:(NSInteger)weight andHeaderTitle:(NSString *)title;
- (void)removeSectionForKey:(id <NSCopying>)key;

- (void)recalculateWeight;

@end
