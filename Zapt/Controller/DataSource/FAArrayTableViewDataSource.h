//
//  FAArrayTableViewDataSource.h
//  Zapt
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAArrayTableViewDataSource : NSObject <UITableViewDataSource, UIDataSourceModelAssociation, NSCoding>

// Designated initializer
- (instancetype)initWithTableView:(UITableView *)tableView;

// NSArray of NSArrays with custom data
// The data will be passed to the configurationBlock
@property NSArray *tableViewData;

// Titles. If you want a header or footerTitle to not show, specify NSNull
@property NSMutableArray *sectionIndexTitles;
@property NSMutableArray *headerTitles;
@property NSMutableArray *footerTitles;

// Set with all objects that should respond with YES to
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
@property NSSet *editableObjects;
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
@property NSSet *movableObjects;

// The table view (must be set)
@property UITableView *tableView;

typedef id (^FAArrayTableViewCellCreationBlock)(id key);
@property (nonatomic, copy) FAArrayTableViewCellCreationBlock cellCreationBlock;

typedef void (^FAArrayTableViewCellConfigurationBlock)(id cell, id key);
@property (nonatomic, copy) FAArrayTableViewCellConfigurationBlock configurationBlock;

// Defaults to UITableViewCell
@property (assign) Class cellClass;

@property BOOL reloadsDataOnDataChange;

// Convenicence methods
- (void)setSectionIndexTitle:(NSString *)title forSection:(NSUInteger)section;
- (void)setHeaderTitle:(NSString *)title forSection:(NSUInteger)section;
- (void)setFooterTitle:(NSString *)title forSection:(NSUInteger)section;

- (void)insertSectionData:(NSArray *)sectionData atIndex:(NSUInteger)sectionIndex withTitle:(NSString *)title;
- (void)insertSectionData:(NSArray *)sectionData atIndex:(NSUInteger)index;
- (void)removeSectionAtIndex:(NSUInteger)sectionIndex;

- (void)insertRowWithKey:(id)rowKey atIndexPath:(NSIndexPath *)indexPath;
- (void)removeRowWithKey:(id)rowKey;

- (void)replaceRowKey:(id)oldRowKey withRowKey:(id)newRowKey;
- (void)replaceRowKeysAtIndexPaths:(NSSet *)indexPaths withRowKey:(id)newRowKey;
- (void)replaceRowKeyAtIndexPath:(NSIndexPath *)indexPath withRowKey:(id)newRowKey;
- (void)replaceRowKeyInSection:(NSUInteger)section row:(NSUInteger)row withRowKey:(id)newRowKey;

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row;
- (void)reloadRowsWithKeys:(NSSet *)objects;
- (void)reloadRowsWithKeys:(NSSet *)objects animation:(UITableViewRowAnimation)animation;
- (void)reloadRowsWithKey:(id)object;
- (void)reloadRowsWithKey:(id)object animation:(UITableViewRowAnimation)animation;

- (id)rowKeyAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)anyIndexPathForObject:(id)object;
- (NSSet *)indexPathsForRowKey:(id)object;

@end
