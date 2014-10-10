//
//  FAEpisodeAirDateTableViewCell.m
//  Zapt
//
//  Created by Finn Wilke on 20/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAEpisodeAirDateTableViewCell.h"
#import "FATrakt.h"
#import "FAInterfaceStringProvider.h"

@interface FAEpisodeAirDateTableViewCell ()
@property (nonatomic) FATraktEpisode *episode;
@end

@implementation FAEpisodeAirDateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (instancetype)init
{
    return [self initWithReuseIdentifier:nil];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)displayEpisode:(FATraktEpisode *)episode
{
    self.episode = episode;
    self.textLabel.text = episode.show.title;
    
    NSString *nameForEpisode = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ – %@", nameForEpisode, episode.title];
}

@end
