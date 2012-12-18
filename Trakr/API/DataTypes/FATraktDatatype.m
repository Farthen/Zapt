//
//  FATraktDatatype.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FAPropertyUtil.h"

@interface FATraktDatatype ()
- (void)finishedMappingObjects;

@end

@implementation FATraktDatatype {
    NSDictionary *_propertyInfo;
}

- (id)init
{
    self = [super init];
    if (self) {
        _propertyInfo = [FAPropertyUtil classPropsFor:[self class]];
    }
    return self;
}

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        [self mapObjectsInDict:dict];
    }
    return self;
}

- (void)finishedMappingObjects
{
    NSLog(@"Finished mapping objects for datatype %@", NSStringFromClass([self class]));
}

- (void)mapObjectsInDict:(NSDictionary *)dict
{
    // Try to map all the JSON keys to the properties
    _originDict = dict;
    for (NSString *key in dict) {
        [self mapObject:[dict objectForKey:key] toPropertyWithKey:key];
    }
    [self finishedMappingObjects];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:NSClassFromString(propertyType)]) {
        if ([object isKindOfClass:[NSString class]]) {
            object = [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([object isEqualToString:@""]) {
                object = nil;
            }
        }
        [self setValue:object forKey:key];
    } else if ([propertyType isEqualToString:@"NSDate"] && [object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        NSTimeInterval timeInterval = [number doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        [self setValue:date forKey:key];
    }
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    NSString *propertyType = [_propertyInfo objectForKey:key];
    if (!propertyType) {
        NSLog(@"[WARN:%@] Can't match object\n%@\nto non-existing property with key \"%@\"", NSStringFromClass([self class]), object, key);
        return;
    }
    
    [self mapObject:object ofType:propertyType toPropertyWithKey:key];
}

@end
