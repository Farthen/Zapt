//
//  FATraktShowProgress.m
//  Trakr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktShowProgress.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

@implementation FATraktShowProgress

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktProgress %p for show \"%@\">", self, self.show];
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"progress"]) {
        // This is the progress dict. Parse it and put it directly in here
        NSDictionary *progressDict = (NSDictionary *)object;
        for (NSString *key in progressDict) {
            if ([key isEqualToString:@"percentage"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"percentage"];
            } else if ([key isEqualToString:@"aired"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"aired"];
            } else if ([key isEqualToString:@"completed"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"completed"];
            } else if ([key isEqualToString:@"left"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"left"];
            }
        }
    } else if ([key isEqualToString:@"show"]) {
        self.show = [[FATraktShow alloc] initWithJSONDict:object];
        self.show.progress = self;
        if (self.next_episode) {
            self.next_episode.show = self.show;
        }
        [self.show commitToCache];
    } else if ([key isEqualToString:@"next_episode"]) {
        self.next_episode = [[FATraktEpisode alloc] initWithJSONDict:object];
        if (self.show) {
            self.next_episode.show = self.show;
        }
        [self.next_episode commitToCache];
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

@end