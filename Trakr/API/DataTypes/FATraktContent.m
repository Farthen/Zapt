//
//  FATraktContentType.m
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FATraktImageList.h"

@implementation FATraktContent

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"in_watchlist"]) {
        NSLog(@"blaj");
    }
    if ([key isEqualToString:@"images"] && [propertyType isEqualToString:@"FATraktImageList"] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktImageList *imageList = [[FATraktImageList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:imageList forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end