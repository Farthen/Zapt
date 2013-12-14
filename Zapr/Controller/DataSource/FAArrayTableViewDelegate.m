//
//  FAArrayTableViewDelegate.m
//  Zapr
//
//  Created by Finn Wilke on 07/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAArrayTableViewDelegate.h"
#import "FAArrayTableViewDataSource.h"
#import "FATableViewCellHeight.h"

@interface FAArrayTableViewDelegate ()
@property FAArrayTableViewDataSource *dataSource;

@property NSMutableDictionary *viewsForSectionHeaders;
@property NSMutableDictionary *viewsForSectionFooters;
@property NSMutableDictionary *heightsForSectionHeaders;
@property NSMutableDictionary *heightsForSectionFooters;

@end

@implementation FAArrayTableViewDelegate

- (instancetype)initWithDataSource:(FAArrayTableViewDataSource *)dataSource
{
    self = [super init];
    
    if (self) {
        self.dataSource = dataSource;
    }
    
    return self;
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
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowWithObject:)]) {
        return [self.delegate tableView:tableView heightForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
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
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowWithObject:)]) {
        return [self.delegate tableView:tableView estimatedHeightForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowWithObject:)]) {
        return [self.delegate tableView:tableView indentationLevelForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forObject:)]) {
        return [self.delegate tableView:tableView willDisplayCell:cell forObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

#pragma mark Managing Accessory Views
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithObject:)]) {
        return [self.delegate tableView:tableView accessoryButtonTappedForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

#pragma mark Managing Selections
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowWithObject:)]) {
        id object = [self.delegate tableView:tableView willSelectRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
        
        return [self.dataSource anyIndexPathForObject:object];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowWithObject:)]) {
        [self.delegate tableView:tableView didSelectRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowWithObject:)]) {
        id object = [self.delegate tableView:tableView willDeselectRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
        
        return [self.dataSource anyIndexPathForObject:object];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowWithObject:)]) {
        [self.delegate tableView:tableView didDeselectRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
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
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

#pragma mark Editing Table Rows
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowWithObject:)]) {
        [self.delegate tableView:tableView willBeginEditingRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndEditingRowWithObject:)]) {
        [self.delegate tableView:tableView didEndEditingRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:editingStyleForRowWithObject:)]) {
        return [self.delegate tableView:tableView editingStyleForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowWithObject:)]) {
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowWithObject:)]) {
        return [self.delegate tableView:tableView shouldIndentWhileEditingRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return YES;
}

#pragma mark Tracking the Removal of Views
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowWithObject:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

#pragma mark Copying and Pasting Row Content
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowWithObject:)]) {
        return [self.delegate tableView:tableView shouldShowMenuForRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowWithObject:withSender:)]) {
        [self.delegate tableView:tableView canPerformAction:action forRowWithObject:[self.dataSource objectAtIndexPath:indexPath] withSender:sender];
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:performAction:forRowWithObject:withSender:)]) {
        [self.delegate tableView:tableView performAction:action forRowWithObject:[self.dataSource objectAtIndexPath:indexPath] withSender:sender];
    }
}

#pragma mark Managing Table View Highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowWithObject:)]) {
        return [self.delegate tableView:tableView shouldHighlightRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didHighlightRowWithObject:)]) {
        [self.delegate tableView:tableView didHighlightRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowWithObject:)]) {
        [self.delegate tableView:tableView didUnhighlightRowWithObject:[self.dataSource objectAtIndexPath:indexPath]];
    }
}

@end
