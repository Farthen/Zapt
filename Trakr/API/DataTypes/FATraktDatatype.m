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
    NSMutableDictionary *_propertyInfo;
}

- (id)init
{
    self = [super init];
    if (self) {
        Class cls = [self class];
        _propertyInfo = [[NSMutableDictionary alloc] initWithDictionary:[FAPropertyUtil classPropsFor:cls]];
        do {
            cls = [cls superclass];
            [_propertyInfo addEntriesFromDictionary:[FAPropertyUtil classPropsFor:cls]];
        } while (cls != [FATraktDatatype class]);
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
    [APLog tiny:@"Finished mapping objects for datatype %@", NSStringFromClass([self class])];
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
            // If string, set string
            object = [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([object isEqualToString:@""]) {
                // If string empty, set to nil
                object = nil;
            }
        }
        [self setValue:object forKey:key];
    } else if ([propertyType isEqualToString:@"NSDate"] && [object isKindOfClass:[NSNumber class]]) {
        // If NSDate, set date
        NSNumber *number = (NSNumber *)object;
        NSTimeInterval timeInterval = [number doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        [self setValue:date forKey:key];
    } else if ([propertyType isEqualToString:@"c"]) {
        // If BOOL, set BOOL
        [self setValue:object forKey:key];
    }
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    NSString *propertyType = [_propertyInfo objectForKey:key];
    if (!propertyType) {
        [APLog fine:@"[%@] Can't match object \"%@\" of class \"%@\" to non-existing property with key \"%@\"", NSStringFromClass([self class]), object, NSStringFromClass([object class]), key];
        return;
    }
    
    [self mapObject:object ofType:propertyType toPropertyWithKey:key];
}

@end
