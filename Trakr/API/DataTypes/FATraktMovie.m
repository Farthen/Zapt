//
//  FATraktMovie.m
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktMovie.h"

@implementation FATraktMovie

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.requestedDetailedInformation = NO;
    }
    return self;
}

- (FAContentType)contentType
{
    return FAContentTypeMovies;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktMovie with title: \"%@\">", self.title];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(id)key
{
    [super mapObject:object ofType:propertyType toPropertyWithKey:key];
}

@end
