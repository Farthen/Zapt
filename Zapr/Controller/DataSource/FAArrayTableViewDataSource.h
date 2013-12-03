//
//  FAArrayTableViewDataSource.h
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAArrayTableViewDataSourceDelegate <NSObject>

@end

@interface FAArrayTableViewDataSource : NSObject <UITableViewDataSource>

// Designated initializer
- (instancetype)initWithTableView:(UITableView *)tableView;

// NSArray of NSArrays with custom data
// The data will be passed to the configurationBlock
@property NSArray *tableViewData;

// Titles. If you want a header or footerTitle to not show, specify NSNull
@property NSArray *sectionIndexTitles;
@property NSArray *headerTitles;
@property NSArray *footerTitles;

// Set with all objects that should respond with YES to
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
@property NSSet *editableIndexPaths;
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
@property NSSet *movableIndexPaths;

// The table view (must be set)
@property (readonly) UITableView *tableView;

typedef void (^FAArrayTableViewCellConfigurationBlock)(UITableViewCell *cell, id object);
@property (nonatomic, copy) FAArrayTableViewCellConfigurationBlock configurationBlock;

// Defaults to UITableViewCell
@property (assign) Class cellClass;

@end
