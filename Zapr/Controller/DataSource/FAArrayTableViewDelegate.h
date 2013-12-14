//
//  FAArrayTableViewDelegate.h
//  Zapr
//
//  Created by Finn Wilke on 07/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FAArrayTableViewDataSource;

@protocol FAArrayTableViewDelegate <NSObject>

@optional

#pragma mark Configuring Rows for the Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowWithObject:(id)object;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowWithObject:(id)object;
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forObject:(id)object;

#pragma mark Managing Accessory Views
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithObject:(id)object;

#pragma mark Managing Selections
- (id)tableView:(UITableView *)tableView willSelectRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didSelectRowWithObject:(id)object;
- (id)tableView:(UITableView *)tableView willDeselectRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didDeselectRowWithObject:(id)object;

#pragma mark Modifying the Header and Footer of Sections
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section;

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didEndEditingRowWithObject:(id)object;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowWithObject:(id)object;
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowWithObject:(id)object;
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowWithObject:(id)object;

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section;

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowWithObject:(id)object;
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowWithObject:(id)object withSender:(id)sender;
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowWithObject:(id)object withSender:(id)sender;

#pragma mark Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didHighlightRowWithObject:(id)object;
- (void)tableView:(UITableView *)tableView didUnhighlightRowWithObject:(id)object;

@end

@interface FAArrayTableViewDelegate : NSObject <UITableViewDelegate>

@property id <FAArrayTableViewDelegate> delegate;

- (instancetype)initWithDataSource:(FAArrayTableViewDataSource *)dataSource;

@property BOOL displaysCustomHeaderViews;
@property BOOL displaysCustomFooterViews;

- (void)setView:(UIView *)view forHeaderInSection:(NSInteger)section;
- (void)setView:(UIView *)view forFooterInSection:(NSInteger)section;
- (void)setHeight:(CGFloat)height forHeaderInSection:(NSInteger)section;
- (void)setHeight:(CGFloat)height forFooterInSection:(NSInteger)section;

@property NSMutableSet *highlightableRowObjects;

@property NSNumber *cellHeight;
@end
