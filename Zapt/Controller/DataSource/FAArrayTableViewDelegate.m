//
//  FAArrayTableViewDelegate.m
//  Zapt
//
//  Created by Finn Wilke on 07/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDelegate.h"
#import "FAArrayTableViewDataSource.h"
#import "FATableViewCellHeight.h"

@interface FAArrayTableViewDelegate ()
@property NSMutableDictionary *viewsForSectionHeaders;
@property NSMutableDictionary *viewsForSectionFooters;
@property NSMutableDictionary *heightsForSectionHeaders;
@property NSMutableDictionary *heightsForSectionFooters;

@end

@implementation FAArrayTableViewDelegate {
    UITableView *_tableView;
}

- (instancetype)initWithDataSource:(FAArrayTableViewDataSource *)dataSource
{
    self = [super init];
    
    if (self) {
        self.dataSource = dataSource;
        self.tableView = dataSource.tableView;
        self.tableView.delegate = self;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    if (self) {
        self.dataSource = [coder decodeObjectForKey:@"dataSource"];
        self.highlightableRowObjects = [coder decodeObjectForKey:@"highlightableRowObjects"];
        self.cellHeight = [coder decodeObjectForKey:@"cellHeight"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.dataSource forKey:@"dataSource"];
    [coder encodeObject:self.highlightableRowObjects forKey:@"highlightableRowObjects"];
    [coder encodeObject:self.cellHeight forKey:@"cellHeight"];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    _tableView.delegate = self;
    
    self.dataSource.tableView = tableView;
}

- (UITableView *)tableView
{
    return _tableView;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    // If we don't display custom header or footer views we need to trick the
    // tableView to think we don't implement those delegate methods
    if (!self.displaysCustomHeaderViews &&
        (aSelector == @selector(tableView:heightForHeaderInSection:) ||
         aSelector == @selector(tableView:viewForHeaderInSection:) ||
         aSelector == @selector(tableView:willDisplayHeaderView:forSection:))) {
        return NO;
    }
    
    if (!self.displaysCustomFooterViews &&
        (aSelector == @selector(tableView:heightForFooterInSection:) ||
         aSelector == @selector(tableView:viewForFooterInSection:) ||
         aSelector == @selector(tableView:willDisplayFooterView:forSection:))) {
        return NO;
    }
    
    return [super respondsToSelector:aSelector];
}

#pragma mark - UITableViewDelegate -
#pragma mark Configuring Rows for the Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowWithKey:)]) {
        return [self.delegate tableView:tableView heightForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    if ([self.dataSource.cellClass conformsToProtocol:@protocol(FATableViewCellHeight)]) {
        Class <FATableViewCellHeight, NSObject> cellClass = self.dataSource.cellClass;
        
        if ([(id)cellClass respondsToSelector : @selector(cellHeight)]) {
            return [cellClass cellHeight];
        }
    }
    
    if (self.cellHeight) {
        return self.cellHeight.floatValue;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowWithKey:)]) {
        return [self.delegate tableView:tableView estimatedHeightForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowWithKey:)]) {
        return [self.delegate tableView:tableView indentationLevelForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forKey:)]) {
        [self.delegate tableView:tableView willDisplayCell:cell forKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark Managing Accessory Views
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithKey:)]) {
        [self.delegate tableView:tableView accessoryButtonTappedForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.forwardDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

#pragma mark Managing Selections
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowWithKey:)]) {
        id object = [self.delegate tableView:tableView willSelectRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
        
        return [self.dataSource anyIndexPathForObject:object];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowWithKey:)]) {
        [self.delegate tableView:tableView didSelectRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDeselectRowWithKey:)]) {
        id object = [self.delegate tableView:tableView willDeselectRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
        
        return [self.dataSource anyIndexPathForObject:object];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowWithKey:)]) {
        [self.delegate tableView:tableView didDeselectRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark Modifying the Header and Footer of Sections
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.viewsForSectionHeaders[[NSNumber numberWithInteger:section]];
}

- (void)setView:(UIView *)view forHeaderInSection:(NSInteger)section
{
    if (!self.viewsForSectionHeaders) {
        self.viewsForSectionHeaders = [NSMutableDictionary dictionary];
    }
    
    [self.viewsForSectionHeaders setObject:view forKey:[NSNumber numberWithInteger:section]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.viewsForSectionFooters[[NSNumber numberWithInteger:section]];
}

- (void)setView:(UIView *)view forFooterInSection:(NSInteger)section
{
    if (!self.viewsForSectionFooters) {
        self.viewsForSectionFooters = [NSMutableDictionary dictionary];
    }
    
    [self.viewsForSectionFooters setObject:view forKey:[NSNumber numberWithInteger:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSNumber *heightNumber = self.heightsForSectionHeaders[[NSNumber numberWithInteger:section]];
    
    if (heightNumber) {
        return [heightNumber floatValue];
    }
    
    return 0;
}

- (void)setHeight:(CGFloat)height forHeaderInSection:(NSInteger)section
{
    if (!self.heightsForSectionHeaders) {
        self.heightsForSectionHeaders = [NSMutableDictionary dictionary];
    }
    
    [self.heightsForSectionHeaders setObject:[NSNumber numberWithFloat:height] forKey:[NSNumber numberWithInteger:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSNumber *heightNumber = self.heightsForSectionFooters[[NSNumber numberWithInteger:section]];
    
    if (heightNumber) {
        return [heightNumber floatValue];
    }
    
    return 0;
}

- (void)setHeight:(CGFloat)height forFooterInSection:(NSInteger)section
{
    if (!self.heightsForSectionFooters) {
        self.heightsForSectionFooters = [NSMutableDictionary dictionary];
    }
    
    [self.heightsForSectionFooters setObject:[NSNumber numberWithFloat:height] forKey:[NSNumber numberWithInteger:section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        id sectionKey = self.dataSource.tableViewData[section];
        [self.delegate tableView:tableView willDisplayHeaderView:view forSectionWithKey:sectionKey];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSectionWithKey:)]) {
        [self.forwardDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        id sectionKey = self.dataSource.tableViewData[section];
        [self.delegate tableView:tableView willDisplayFooterView:view forSectionWithKey:sectionKey];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.forwardDelegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowWithKey:)]) {
        [self.delegate tableView:tableView willBeginEditingRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndEditingRowWithKey:)]) {
        [self.delegate tableView:tableView didEndEditingRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:editingStyleForRowWithKey:)]) {
        return [self.delegate tableView:tableView editingStyleForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowWithKey:)]) {
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowWithKey:)]) {
        return [self.delegate tableView:tableView shouldIndentWhileEditingRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    
    return YES;
}

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowWithKey:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        id sectionKey = self.dataSource.tableViewData[section];
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSectionWithKey:sectionKey];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        id sectionKey = self.dataSource.tableViewData[section];
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSectionWithKey:sectionKey];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowWithKey:)]) {
        return [self.delegate tableView:tableView shouldShowMenuForRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowWithKey:withSender:)]) {
        return [self.delegate tableView:tableView canPerformAction:action forRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath] withSender:sender];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
        return [self.forwardDelegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:performAction:forRowWithKey:withSender:)]) {
        [self.delegate tableView:tableView performAction:action forRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath] withSender:sender];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        [self.forwardDelegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

#pragma mark Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowWithKey:)]) {
        return [self.delegate tableView:tableView shouldHighlightRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        return [self.forwardDelegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didHighlightRowWithKey:)]) {
        [self.delegate tableView:tableView didHighlightRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowWithKey:)]) {
        [self.delegate tableView:tableView didUnhighlightRowWithKey:[self.dataSource rowKeyAtIndexPath:indexPath]];
    }
    
    if ([self.forwardDelegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
        [self.forwardDelegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

@end
