//
//  FASearchResultTableViewCell.m
//  Zapr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAContentTableViewCell.h"
#import "FATrakt.h"

@implementation FAContentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutSubviews];
    }
    return self;
}

- (void)displayContent:(FATraktContent *)content
{
    if ([content isKindOfClass:[FATraktMovie class]]) {
        FATraktMovie *movie = (FATraktMovie *)content;
        self.textLabel.text = movie.title;
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
        
        self.leftAuxiliaryTextLabel.text = detailString;
        if (movie.tagline && ![movie.tagline isEqual:[NSNull null]]) {
            self.detailTextLabel.text = movie.tagline;
        } else {
            self.detailTextLabel.text = nil;
        }
    } else if ([content isKindOfClass:[FATraktShow class]]) {
        // TODO: Crashbug here?
        FATraktShow *show = (FATraktShow *)content;
        self.textLabel.text = show.title;
        
        NSDateComponents *components;
        if (show.first_aired) {
            components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:show.first_aired];
        }
        NSString *genres = [show.genres componentsJoinedByString:NSLocalizedString(@", ", nil)];
        NSString *detailString;
        if (![genres isEqualToString:@""] && show.first_aired) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%i – %@", nil), components.year, genres];
        } else if (show.first_aired) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%i", nil), components.year];
        } else if (![genres isEqualToString:@""]) {
            detailString = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), genres];
        } else {
            detailString = nil;
        }
        self.leftAuxiliaryTextLabel.text = detailString;
        
        if (show.overview && ![show.overview isEqual:[NSNull class]]) {
            self.detailTextLabel.text = show.overview;
        } else {
            self.detailTextLabel.text = nil;
        }
    } else if ([content isKindOfClass:[FATraktEpisode class]]) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        self.textLabel.text = episode.title;
        self.leftAuxiliaryTextLabel.text = episode.show.title;
        if (episode.season && episode.episode && episode.overview) {
            self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i – %@", nil), episode.season.intValue, episode.episode.intValue, episode.overview];
        } else if (episode.season && episode.episode) {
            self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), episode.season.intValue, episode.episode.intValue];
        } else if (episode.overview) {
            self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), episode.overview];
        } else {
            self.detailTextLabel.text = nil;
        }
    } else {
        DDLogError(@"Tried to display a datatype in FASearchResultTableViewCell that is not possible to be displayed!");
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthMargin = 9;
    
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor blackColor];
    
    UIFont *auxiliaryFont = [UIFont systemFontOfSize:14];
    UIColor *auxiliaryTextColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];

    self.detailTextLabel.font = auxiliaryFont;
    self.detailTextLabel.textColor = auxiliaryTextColor;
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if (!_leftAuxiliaryTextLabel) {
        _leftAuxiliaryTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.leftAuxiliaryTextLabel];
    }
    
    self.leftAuxiliaryTextLabel.font = auxiliaryFont;
    self.leftAuxiliaryTextLabel.textColor = auxiliaryTextColor;
    self.leftAuxiliaryTextLabel.highlightedTextColor = [UIColor whiteColor];
    self.leftAuxiliaryTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // Create constraints for the title label:
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:5]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
    
    // auxiliary label
    self.leftAuxiliaryTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.leftAuxiliaryTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.leftAuxiliaryTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
    
    // Detail label
    self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.detailTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailTextLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    if ([self.detailTextLabel isDescendantOfView:self.contentView]) {
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.leftAuxiliaryTextLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:widthMargin]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:widthMargin]];
    } // watwatwat abandon ship (it's sad but it actually works)
    // More thorough explanation: The detail text label seems to be removed when the text is nil. Why this is happening is pretty unclear. This fixes the segfault though ^^
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView setNeedsLayout];
}

+ (CGFloat)cellHeight
{
    return 70;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
