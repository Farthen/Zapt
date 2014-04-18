//
//  FAArrayTableViewDelegate.h
//  Zapt
//
//  Created by Finn Wilke on 07/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FAArrayTableViewDataSource;

@protocol FAArrayTableViewDelegate <NSObject>

@optional

#pragma mark Configuring Rows for the Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowWithKey:(id)rowKey;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowWithKey:(id)rowKey;
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forKey:(id)rowKey;

#pragma mark Managing Accessory Views
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithKey:(id)rowKey;

#pragma mark Managing Selections
- (id)tableView:(UITableView *)tableView willSelectRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didSelectRowWithKey:(id)rowKey;
- (id)tableView:(UITableView *)tableView willDeselectRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didDeselectRowWithKey:(id)rowKey;

#pragma mark Modifying the Header and Footer of Sections
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSectionWithKey:(id)sectionKey;
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSectionWithKey:(id)sectionKey;

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didEndEditingRowWithKey:(id)rowKey;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowWithKey:(id)rowKey;
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowWithKey:(id)rowKey;
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowWithKey:(id)rowKey;

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSectionWithKey:(id)sectionKey;
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSectionWithKey:(id)sectionKey;

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowWithKey:(id)rowKey;
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowWithKey:(id)rowKey withSender:(id)sender;
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowWithKey:(id)rowKey withSender:(id)sender;

#pragma mark Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didHighlightRowWithKey:(id)rowKey;
- (void)tableView:(UITableView *)tableView didUnhighlightRowWithKey:(id)rowKey;

@end

@interface FAArrayTableViewDelegate : NSObject <UITableViewDelegate, NSCoding>

@property id <FAArrayTableViewDelegate> delegate;

- (instancetype)initWithDataSource:(FAArrayTableViewDataSource *)dataSource;

@property (nonatomic) FAArrayTableViewDataSource *dataSource;
@property (nonatomic) UITableView *tableView;

@property BOOL displaysCustomHeaderViews;
@property BOOL displaysCustomFooterViews;

- (void)setView:(UIView *)view forHeaderInSection:(NSInteger)section;
- (void)setView:(UIView *)view forFooterInSection:(NSInteger)section;
- (void)setHeight:(CGFloat)height forHeaderInSection:(NSInteger)section;
- (void)setHeight:(CGFloat)height forFooterInSection:(NSInteger)section;

@property NSMutableSet *highlightableRowObjects;

@property NSNumber *cellHeight;
@end
