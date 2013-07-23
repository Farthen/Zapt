//
//  FATraktListItem.m
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktListItem.h"
#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktSeason.h"

@implementation FATraktListItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktListItem %p of type \"%@\">", self, self.type];
}

- (FATraktContent *)content
{
    if ([self.type isEqualToString:@"movie"]) {
        return self.movie;
    } else if ([self.type isEqualToString:@"show"]) {
        return self.show;
    } else if ([self.type isEqualToString:@"episode"]) {
        return self.episode;
    }
    return nil;
}

- (void)setContent:(FATraktContent *)content
{
    if ([content isKindOfClass:[FATraktMovie class]]) {
        self.movie = (FATraktMovie *)content;
        self.type = @"movie";
    } else if ([content isKindOfClass:[FATraktShow class]]) {
        self.show = (FATraktShow *)content;
        self.type = @"show";
    } else if ([content isKindOfClass:[FATraktEpisode class]]) {
        self.episode = (FATraktEpisode *)content;
        self.type = @"episode";
    }
}

- (void)setItem:(id)object
{
    NSString *key = self.type;
    [self mapObject:object ofType:nil toPropertyWithKey:key];
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"movie"]) {
        [self setValue:[[FATraktMovie alloc] initWithJSONDict:object] forKey:key];
    } else if ([key isEqualToString:@"season"]) {
        [self setValue:[[FATraktSeason alloc] initWithJSONDict:object] forKey:key];
    } else if ([key isEqualToString:@"show"]) {
        [self setValue:[[FATraktShow alloc] initWithJSONDict:object] forKey:key];
    } else if ([key isEqualToString:@"episode"]) {
        [self setValue:[[FATraktEpisode alloc] initWithJSONDict:object] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
