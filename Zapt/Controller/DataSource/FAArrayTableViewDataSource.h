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
@property NSSet *editableIndexPaths;
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
@property NSSet *movableIndexPaths;

// The table view (must be set)
@property UITableView *tableView;

typedef id (^FAArrayTableViewCellCreationBlock)(id object);
@property (nonatomic, copy) FAArrayTableViewCellCreationBlock cellCreationBlock;

typedef void (^FAArrayTableViewCellConfigurationBlock)(id cell, id object);
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

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (void)removeObject:(id)object;

- (void)replaceObject:(id)oldObject withObject:(id)newObject;
- (void)replaceObjectsAtIndexPaths:(NSSet *)indexPaths withObject:(id)object;
- (void)replaceObjectAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object;
- (void)replaceObjectInSection:(NSUInteger)section row:(NSUInteger)row withObject:(id)object;

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row;
- (void)reloadRowsWithObjects:(NSSet *)objects;
- (void)reloadRowsWithObject:(id)object;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)anyIndexPathForObject:(id)object;
- (NSSet *)indexPathsForObject:(id)object;

@end
