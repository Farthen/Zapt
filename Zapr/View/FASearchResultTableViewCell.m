//
//  FASearchResultTableViewCell.m
//  Zapr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchResultTableViewCell.h"
#import "FATrakt.h"

@implementation FASearchResultTableViewCell

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
            detailString = NSLocalizedString(@"", nil);
        }
        
        self.leftAuxiliaryTextLabel.text = detailString;
        NSString *tagline = movie.tagline;
        self.detailTextLabel.text = tagline;
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
            detailString = NSLocalizedString(@"", nil);
        }
        self.leftAuxiliaryTextLabel.text = detailString;
        self.detailTextLabel.text = show.overview;
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
            self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"", nil)];
        }
    } else {
        DDLogError(@"Tried to display a datatype in FASearchResultTableViewCell that is not possible to be displayed!");
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthMargin = 9;
    
    self.textLabel.frame = CGRectMake(widthMargin, 5, self.contentView.frame.size.width - 2*widthMargin, 21);
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailTextLabel.frame = CGRectMake(widthMargin, 48, self.contentView.frame.size.width - 2*widthMargin, 15);
    self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
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
    
    self.leftAuxiliaryTextLabel.frame = CGRectMake(widthMargin, 30, self.contentView.frame.size.width - 2*widthMargin, 15);
    self.leftAuxiliaryTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.leftAuxiliaryTextLabel.font = auxiliaryFont;
    self.leftAuxiliaryTextLabel.textColor = auxiliaryTextColor;
    self.leftAuxiliaryTextLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.leftAuxiliaryTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
