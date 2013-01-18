//
//  FATraktEpisode.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktEpisode.h"
#import "FATraktShow.h"

@implementation FATraktEpisode

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.requestedDetailedInformation = NO;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktEpisode S%02iE%02i: \"%@\" Show: \"%@\">", self.season.intValue, self.episode.intValue, self.title, self.show.title];
}

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.show = show;
    }
    return self;
}

@end
