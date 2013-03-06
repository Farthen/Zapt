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
    return [NSString stringWithFormat:@"<FATraktListItem of type \"%@\">", self.type];
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

- (void)setItem:(id)object
{
    NSString *key = self.type;
    [self mapObject:object ofType:nil toPropertyWithKey:key];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
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
