//
//  FATraktMovie.m
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktMovie.h"

#import "FATraktPeopleList.h"
#import "FATraktImageList.h"

@implementation FATraktMovie {
    NSNumber *_year;
}

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
    return [NSString stringWithFormat:@"<FATraktMovie with title: %@>", self.title];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(id)key
{
    if ([key isEqualToString:@"images"]) {
        NSLog(@"w00t?");
    }
    if ([key isEqualToString:@"people"] && [propertyType isEqualToString:@"FATraktPeopleList"] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktPeopleList *peopleList = [[FATraktPeopleList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:peopleList forKey:key];
    } else if ([key isEqualToString:@"images"] && [propertyType isEqualToString:@"FATraktImageList"] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktImageList *imageList = [[FATraktImageList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:imageList forKey:key];
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
