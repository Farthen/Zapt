//
//  FATraktList.m
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktList.h"
#import "FATraktListItem.h"

@implementation FATraktList

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktList \"%@\">", self.name];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *itemDict in (NSArray *)object) {
            FATraktListItem *item = [[FATraktListItem alloc] initWithJSONDict:object];
            [itemArray addObject:item];
        }
        [self setValue:[NSArray arrayWithArray:itemArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
