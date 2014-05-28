//
//  FAEpisodeAirDateTableViewCell.h
//  Zapt
//
//  Created by Finn Wilke on 20/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATrakt.h"

@interface FAEpisodeAirDateTableViewCell : UITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (instancetype)init;

- (void)displayEpisode:(FATraktEpisode *)episode;

@end
