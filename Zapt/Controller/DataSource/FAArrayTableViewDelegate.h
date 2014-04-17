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
- (CGFloat)tableView:(UITableView *)tableView heightForRowWithKey:(id)object;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowWithKey:(id)object;
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forKey:(id)object;

#pragma mark Managing Accessory Views
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithKey:(id)object;

#pragma mark Managing Selections
- (id)tableView:(UITableView *)tableView willSelectRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didSelectRowWithKey:(id)object;
- (id)tableView:(UITableView *)tableView willDeselectRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didDeselectRowWithKey:(id)object;

#pragma mark Modifying the Header and Footer of Sections
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSectionWithKey:(id)sectionKey;
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSectionWithKey:(id)sectionKey;

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didEndEditingRowWithKey:(id)object;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowWithKey:(id)object;
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowWithKey:(id)object;
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowWithKey:(id)object;

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSectionWithKey:(id)sectionKey;
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSectionWithKey:(id)sectionKey;

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowWithKey:(id)object;
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowWithKey:(id)object withSender:(id)sender;
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowWithKey:(id)object withSender:(id)sender;

#pragma mark Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didHighlightRowWithKey:(id)object;
- (void)tableView:(UITableView *)tableView didUnhighlightRowWithKey:(id)object;

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
