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
        //self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.badges = [FABadges instanceForView:self.contentView];
        self.imageViewConstraints = [NSMutableArray array];
        _auxiliaryTextLabel = [[UILabel alloc] init];
        
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

- (NSString *)detailLabelStringForContent:(FATraktContent *)content
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

- (NSString *)auxiliaryLabelStringForContent:(FATraktContent *)content
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
    self.detailTextLabel.text = [self detailLabelStringForContent:content];
    self.auxiliaryTextLabel.text = [self auxiliaryLabelStringForContent:content];
    
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
    
    CGFloat imageWidth = 0;
    
    if (self.shouldDisplayImage) {
        imageWidth = 42;
    }
    
    CGFloat cellHeight = [self.class cellHeight];
    CGFloat cellWidth = self.contentView.bounds.size.width;
    CGFloat widthMargin = [self.class widthMargin];
    CGFloat topMargin = [self.class topMargin];
    CGFloat labelSpacing = [self.class labelSpacing];
    
    CGFloat labelLeftPosition = imageWidth + widthMargin;
    CGFloat labelWidth = cellWidth - labelLeftPosition - widthMargin;
    CGFloat titleHeight = [self.class titleHeight];
    CGFloat detailHeight = [self.class detailHeight];
    
    if (self.twoLineMode) {
        topMargin = topMargin + detailHeight / 2;
    }
    
    self.imageView.frame = CGRectMake(0, 0, 42, cellHeight);
    self.imageView.contentScaleFactor = UIViewContentModeScaleAspectFill;
    
    self.textLabel.frameLeftPosition = labelLeftPosition;
    self.detailTextLabel.frameLeftPosition = labelLeftPosition;
    self.auxiliaryTextLabel.frameLeftPosition = labelLeftPosition;
    
    self.textLabel.frameWidth = labelWidth;
    self.detailTextLabel.frameWidth = labelWidth;
    self.detailTextLabel.frameWidth = labelWidth;
    self.auxiliaryTextLabel.frameWidth = labelWidth;
    
    self.textLabel.frameHeight = titleHeight;
    self.detailTextLabel.frameHeight = detailHeight;
    self.auxiliaryTextLabel.frameHeight = detailHeight;
    
    self.textLabel.frameTopPosition = topMargin;
    self.detailTextLabel.frameTopPosition = self.textLabel.frameBottomPosition + labelSpacing;
    self.auxiliaryTextLabel.frameTopPosition = self.detailTextLabel.frameBottomPosition + labelSpacing;
    
    if (self.twoLineMode) {
        [self.auxiliaryTextLabel removeFromSuperview];
    } else {
        [self.contentView addSubview:self.auxiliaryTextLabel];
    }
    
    self.separatorInset = UIEdgeInsetsZero;
    
    self.textLabel.font = self.class.titleFont;
    
    self.detailTextLabel.font = self.class.detailFont;
    self.detailTextLabel.textColor = [UIColor grayColor];
    
    self.auxiliaryTextLabel.font = self.class.detailFont;
    self.auxiliaryTextLabel.textColor = [UIColor grayColor];
}

- (void)setImage:(UIImage *)image
{
    [self setNeedsLayout];
    
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

+ (CGFloat)titleHeight
{
    return [@"Title" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell titleFont] }].height;
}

+ (CGFloat)detailHeight
{
    return [@"Detail" sizeWithAttributes : @{ NSFontAttributeName :[FAContentTableViewCell detailFont] }].height;
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
    CGFloat titleHeight = [self titleHeight] ;
    CGFloat detailHeight = [self detailHeight];
    
    // Now calculate this crap
    CGFloat height = 0;
    
    height += self.topMargin;
    height += titleHeight;
    height += self.labelSpacing;
    height += detailHeight;
    height += 0;
    height += detailHeight;
    height += self.bottomMargin;
    
    return ceil(height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
