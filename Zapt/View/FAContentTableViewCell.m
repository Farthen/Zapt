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

@interface FAContentTableViewCell ()
@property BOOL addedConstraints;
@property FAHorizontalProgressView *progressView;
@property CGFloat showProgress;
@end

@implementation FAContentTableViewCell {
    BOOL _showsProgressForShows;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self layoutSubviews];
    }
    
    return self;
}

- (NSString *)titleForContent:(FATraktContent *)content
{
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
        // TODO: Crashbug here?
        FATraktShow *show = (FATraktShow *)content;
        
        NSDateComponents *components;
        
        if (show.first_aired) {
            components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:show.first_aired];
        }
        
        NSString *genres = [show.genres componentsJoinedByString:NSLocalizedString(@", ", nil)];
        NSString *detailString;
        
        if (self.showsProgressForShows && show.progress) {
            detailString = [FAInterfaceStringProvider progressForProgress:show.progress long:YES];
        } else if (genres || show.first_aired) {
            if (![genres isEqualToString:@""] && show.first_aired) {
                detailString = [NSString stringWithFormat:NSLocalizedString(@"%i – %@", nil), components.year, genres];
            } else if (show.first_aired) {
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
    self.textLabel.text = [self titleForContent:content];
    self.leftAuxiliaryTextLabel.text = [self auxiliaryLabelStringForContent:content];
    self.detailTextLabel.text = [self detailLabelStringForContent:content];
    
    if (self.showsProgressForShows && [content isKindOfClass:[FATraktShow class]]) {
        FATraktShow *show = (FATraktShow *)content;
        self.showProgress = (CGFloat)show.progress.percentage.unsignedIntegerValue / 100;
        self.progressView.progress = self.showProgress;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthMargin = self.class.widthMargin;
    
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
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    if (self.twoLineMode) {
        self.detailTextLabel.hidden = YES;
    } else {
        self.detailTextLabel.hidden = NO;
    }
    
    if (!self.addedConstraints) {
        // Create constraints for the title label:
        
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
            // watwatwat abandon ship (it's sad but it actually works)
            // More thorough explanation: The text labels seem to be removed when the text is nil. Why this is happening is pretty unclear. This fixes the segfault though ^^
            self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:self.class.topMargin + topSpacing]];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
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
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
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
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
            }
        }
        
        if (self.showsProgressForShows) {
            self.separatorInset = UIEdgeInsetsZero;
            
            CGRect frame = CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 2);
            
            if (!self.progressView) {
                self.progressView = [[FAHorizontalProgressView alloc] initWithFrame:frame];
                [self addSubview:self.progressView];
            }
            
            self.progressView.tintColor = [[FAGlobalSettings sharedInstance] tintColor];
            
            self.progressView.backgroundColor = [UIColor lightGrayColor];
            
            self.progressView.progress = self.showProgress;
            
            [self.progressView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:2]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            
            [self.progressView setNeedsUpdateConstraints];
            [self.progressView setNeedsLayout];
        } else {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView setNeedsLayout];
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
