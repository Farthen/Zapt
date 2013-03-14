//
//  FATraktPeopleList.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktPeopleList.h"

#import "FATraktPeople.h"

@implementation FATraktPeopleList

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *peopleArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *peopleDict in (NSArray *)object) {
            FATraktPeople *people = [[FATraktPeople alloc] initWithJSONDict:peopleDict];
            [peopleArray addObject:people];
        }
        [self setValue:[NSArray arrayWithArray:peopleArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
