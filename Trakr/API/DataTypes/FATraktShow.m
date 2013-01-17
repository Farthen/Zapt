//
//  FATraktShow.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktShow.h"
#import "FATraktSeason.h"

@implementation FATraktShow

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktShow with title: %@>", self.title];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"seasons"] && [propertyType isEqualToString:@"NSArray"] && [object isKindOfClass:[NSArray class]]) {
        NSMutableArray *seasonArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *seasonDict in (NSArray *)object) {
            FATraktSeason *season = [[FATraktSeason alloc] initWithJSONDict:seasonDict andShow:self];
            [seasonArray addObject:season];
        }
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"season" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [seasonArray sortUsingDescriptors:sortDescriptors];
        [self setValue:[NSArray arrayWithArray:seasonArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}


@end
