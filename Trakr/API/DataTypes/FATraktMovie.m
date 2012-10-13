//
//  FATraktMovie.m
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktMovie.h"

#import "FATraktPeopleList.h"

@implementation FATraktMovie {
    NSNumber *_year;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktMovie with title: %@>", self.title];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(id)key
{
    if ([key isEqualToString:@"people"] && [propertyType isEqualToString:@"NSDictionary"] && [object isKindOfClass:[NSDictionary class]]) {
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
