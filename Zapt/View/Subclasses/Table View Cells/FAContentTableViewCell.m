//
//  FASearchResultTableViewCell.m
//  Zapt
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAContentTableViewCell.h"
#import "FATrakt.h"
#import "FAGlobalSettings.h"

#import "FAInterfaceStringProvider.h"
#import "FAHorizontalProgressView.h"

#import "FABadges.h"

@interface FAContentTableViewCell ()
@property BOOL addedConstraints;
@property FAHorizontalProgressView *progressView;
@property CGFloat showProgress;

@property (nonatomic) FATraktContent *displayedContent;

@property BOOL needsRemoveImageViewConstraints;
@property (nonatomic) NSMutableArray *imageViewConstraints;

@property (nonatomic) FABadges *badges;
@end

@implementation FAContentTableViewCell {
    BOOL _showsProgressForShows;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.badges = [FABadges instanceForView:self.contentView];
        self.imageViewConstraints = [NSMutableArray array];
        
        [self layoutSubviews];
    }
    
    return self;
}

- (NSString *)titleForContent:(FATraktContent *)content
{
    if (self.calendarMode && [content isKindOfClass:[FATraktEpisode class]]) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        return episode.show.title;
    }
    
    return content.title;
}

- (NSString *)auxiliaryLabelStringForContent:(FATraktContent *)content
{
    if ([content isKindOfClass:[FATraktMovie class]]) {
        FATraktMovie *movie = (FATraktMovie *)content;
        NSString *genres = [movie.genres componentsJoinedByString:@", "];
        NSString *detailString;
        
        if (movie.year && ![genres isEqualToString:@""]) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%@ - %@", nil), movie.year, genres];
        } else if (movie.year) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), movie.year];
        } else if (![genres isEqualToString:@""]) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), genres];
        } else {
            detailString = nil;
        }
        
        return detailString;
    } else if ([content isKindOfClass:[FATraktShow class]]) {
        FATraktShow *show = (FATraktShow *)content;
        
        NSDateComponents *components;
        
        if (show.first_aired_utc) {
            components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:show.first_aired_utc];
        }
        
        NSString *genres = [show.genres componentsJoinedByString:NSLocalizedString(@", ", nil)];
        NSString *detailString;
        
        if (self.showsProgressForShows && show.progress) {
            detailString = [FAInterfaceStringProvider progressForProgress:show.progress long:YES];
        } else if (genres || show.first_aired_utc) {
            if (![genres isEqualToString:@""] && show.first_aired_utc) {
                detailString = [NSString stringWithFormat:NSLocalizedString(@"%i – %@", nil), components.year, genres];
            } else if (show.first_aired_utc) {
                detailString = [NSString stringWithFormat:NSLocalizedString(@"%i", nil), components.year];
            } else if (![genres isEqualToString:@""]) {
                detailString = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), genres];
            }
        } else {
            detailString = nil;
        }
        
        return detailString;
    } else if ([content isKindOfClass:[FATraktEpisode class]]) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        
        if (self.calendarMode) {
            NSString *nameForEpisode = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
            return [NSString stringWithFormat:@"%@ – %@", nameForEpisode, episode.title];;
        }
        
        return episode.show.title;
    }
    
    return nil;
}

- (NSString *)detailLabelStringForContent:(FATraktContent *)content
{
    if ([content isKindOfClass:[FATraktMovie class]]) {
        FATraktMovie *movie = (FATraktMovie *)content;
        
        if (movie.tagline && ![movie.tagline isEqual:[NSNull null]]) {
            return movie.tagline;
        } else {
            return nil;
        }
    } else if ([content isKindOfClass:[FATraktShow class]]) {
        FATraktShow *show = (FATraktShow *)content;
        
        if (show.overview && ![show.overview isEqual:[NSNull class]]) {
            return show.network;
        } else {
            return nil;
        }
    } else if ([content isKindOfClass:[FATraktEpisode class]]) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        
        if (episode.seasonNumber && episode.episodeNumber && episode.overview) {
            return [NSString stringWithFormat:NSLocalizedString(@"%@ – %@", nil), [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES], episode.overview];
        } else if (episode.seasonNumber && episode.episodeNumber) {
            return [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
        } else if (episode.overview) {
            return [NSString stringWithFormat:NSLocalizedString(@"%@", nil), episode.overview];
        } else {
            return nil;
        }
    }
    
    return nil;
}

- (void)displayContent:(FATraktContent *)content
{
    [self displayContent:content withImage:nil];
}

- (void)displayContent:(FATraktContent *)content withImage:(UIImage *)image
{
    self.textLabel.text = [self titleForContent:content];
    self.leftAuxiliaryTextLabel.text = [self auxiliaryLabelStringForContent:content];
    self.detailTextLabel.text = [self detailLabelStringForContent:content];
    
    if (self.showsProgressForShows && [content isKindOfClass:[FATraktShow class]]) {
        FATraktShow *show = (FATraktShow *)content;
        self.showProgress = (CGFloat)show.progress.percentage.unsignedIntegerValue / 100;
        self.progressView.progress = self.showProgress;
    } else {
        self.showProgress = 0;
        self.progressView.progress = 0;
    }
    
    self.image = image;
    
    self.displayedContent = content;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthMargin = self.class.widthMargin;
    CGFloat imageWidthMargin = widthMargin + 42;
    
    if (self.shouldDisplayImage) {
        self.separatorInset = UIEdgeInsetsZero;
        
        if (!self.image) {
            widthMargin = imageWidthMargin;

        }
    }
    
    //self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.font = [FAContentTableViewCell titleFont];
    self.textLabel.numberOfLines = 1;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.adjustsFontSizeToFitWidth = NO;
    
    //UIFont *auxiliaryFont = [UIFont systemFontOfSize:14];
    UIFont *auxiliaryFont = [FAContentTableViewCell detailFont];
    UIColor *auxiliaryTextColor = [UIColor grayColor];
    
    self.detailTextLabel.font = auxiliaryFont;
    self.detailTextLabel.textColor = auxiliaryTextColor;
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.detailTextLabel.adjustsFontSizeToFitWidth = NO;
    self.detailTextLabel.numberOfLines = 1;
    
    if (!_leftAuxiliaryTextLabel) {
        _leftAuxiliaryTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.leftAuxiliaryTextLabel];
    }
    
    self.leftAuxiliaryTextLabel.font = auxiliaryFont;
    self.leftAuxiliaryTextLabel.textColor = auxiliaryTextColor;
    self.leftAuxiliaryTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.leftAuxiliaryTextLabel.adjustsFontSizeToFitWidth = NO;
    self.leftAuxiliaryTextLabel.numberOfLines = 1;
        
    if (self.twoLineMode) {
        self.detailTextLabel.hidden = YES;
    } else {
        self.detailTextLabel.hidden = NO;
    }
    
    if (self.needsRemoveImageViewConstraints || !self.addedConstraints) {
        [self.contentView removeConstraints:self.imageViewConstraints];
        [self.imageViewConstraints removeAllObjects];
        self.addedConstraints = NO;
        self.needsRemoveImageViewConstraints = NO;
    }
    
    if (!self.addedConstraints) {
        // Create constraints for the title label:
        
        [self.contentView removeConstraints:self.contentView.constraints];
        
        CGFloat topSpacing = 0;
        CGFloat bottomSpacing = 0;
        
        if (self.twoLineMode) {
            CGFloat height = [FAContentTableViewCell cellHeight];
            
            CGSize titleSize = [@"Title" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell titleFont] }];
            CGSize detailSize = [@"Detail" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell detailFont] }];
            
            CGFloat labelArea = 0;
            labelArea += self.class.topMargin;
            labelArea += titleSize.height;
            labelArea += self.class.labelSpacing;
            labelArea += detailSize.height;
            labelArea += self.class.bottomMargin;
            
            CGFloat offset = height - labelArea;
            topSpacing = offset / 2;
            bottomSpacing = offset / 2;
        }
        
        if ([self.textLabel isDescendantOfView:self.contentView]) {
            // The text labels seem to be removed when the text is nil.
            self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:self.class.topMargin + topSpacing]];
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        
        // auxiliary label
        self.leftAuxiliaryTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.leftAuxiliaryTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.leftAuxiliaryTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        
        if ([self.textLabel isDescendantOfView:self.contentView]) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:self.class.labelSpacing]];
        } else {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:self.class.topMargin]];
        }
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        if (self.twoLineMode) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:self.class.bottomMargin + bottomSpacing]];
            
        } else {
            // Detail label
            self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.detailTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.detailTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            
            if ([self.detailTextLabel isDescendantOfView:self.contentView]) {
                // watwatwat abandon ship (it's sad but it actually works)
                // More thorough explanation: The text labels seem to be removed when the text is nil. Why this is happening is pretty unclear. This fixes the segfault though ^^
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
            }
        }
        
        if (self.showsProgressForShows && self.showProgress >= 1.0) {
            [self.badges badge:FABadgeWatched];
        } else {
            [self.badges unbadge:FABadgeWatched];
        }
    }
    
    if (self.imageViewConstraints.count == 0) {
        if (self.image) {
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:42]];
            
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.imageView.clipsToBounds = YES;
        }
        
        if ([self.textLabel isDescendantOfView:self.contentView]) {
            if (self.image) {
                [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
            } else {
                [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
            }
        }
        
        if ([self.detailTextLabel isDescendantOfView:self.contentView]) {
            if (self.image) {
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
            } else {
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
            }
        }
        
        if (self.image) {
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
        } else {
            [self.imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
        }
        
        [self.contentView addConstraints:self.imageViewConstraints];
        [self.contentView setNeedsLayout];
    }
}

- (void)setImage:(UIImage *)image
{
    if (!!self.image != !!image) {
        self.needsRemoveImageViewConstraints = YES;
        [self setNeedsLayout];
    }
    
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (BOOL)showsProgressForShows
{
    return _showsProgressForShows;
}

- (void)setShowsProgressForShows:(BOOL)showsProgressForShows
{
    _showsProgressForShows = showsProgressForShows;
    [self setNeedsLayout];
}

- (void)setNeedsLayout
{
    [super setNeedsLayout];
}

+ (CGFloat)widthMargin
{
    return 16;
}

+ (CGFloat)topMargin
{
    return 5;
}

+ (CGFloat)labelSpacing
{
    return 2;
}

+ (CGFloat)bottomMargin
{
    return 6;
}

+ (UIFont *)titleFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //return [UIFont systemFontOfSize:18];
}

+ (UIFont *)detailFont
{
    UIFontDescriptor *footnoteDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    NSMutableDictionary *fontAttributes = [footnoteDescriptor.fontAttributes mutableCopy];
    
    NSNumber *fontSizeNumber = fontAttributes[@"NSFontSizeAttribute"];
    NSNumber *newFontSizeNumber = [NSNumber numberWithFloat:fontSizeNumber.floatValue - 1];
    fontAttributes[@"NSFontSizeAttribute"] = newFontSizeNumber;
    
    UIFontDescriptor *detailFontDescriptor = [[UIFontDescriptor alloc] initWithFontAttributes:fontAttributes];
    
    return [UIFont fontWithDescriptor:detailFontDescriptor size:0.0];
    
    //return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    //return [UIFont systemFontOfSize:12];
}

+ (CGFloat)cellHeight
{
    // This is so much fun, yoloswag
    // Cell height is the same for each cell but it can change depending on the fonts used
    CGSize titleSize = [@"Title" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell titleFont] }];
    CGSize detailSize = [@"Detail" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell detailFont] }];
    
    // Now calculate this crap
    CGFloat height = 0;
    
    height += self.topMargin;
    height += titleSize.height;
    height += self.labelSpacing;
    height += detailSize.height;
    height += 0;
    height += detailSize.height;
    height += self.bottomMargin;
    
    return ceil(height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
