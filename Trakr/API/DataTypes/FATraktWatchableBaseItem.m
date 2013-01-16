//
//  FATraktWatchableBaseItem.m
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktWatchableBaseItem.h"
#import "FATraktPeopleList.h"

@implementation FATraktWatchableBaseItem {
    NSNumber *_year;
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(id)key
{
    if ([key isEqualToString:@"people"] && [propertyType isEqualToString:@"FATraktPeopleList"] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktPeopleList *peopleList = [[FATraktPeopleList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:peopleList forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (void)setYear:(NSNumber *)year
{
    if ([year integerValue] == 0) {
        _year = nil;
    } else {
        _year = year;
    }
}

- (NSNumber *)year
{
    return _year;
}

@end
