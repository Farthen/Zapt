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

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)init
{
    self = [super init];
    if (self) {
        Class cls = [self class];
        //_propertyInfo = [[NSMutableDictionary alloc] initWithDictionary:[FAPropertyUtil classPropsFor:cls]];
        
        _propertyInfo = [[NSMutableDictionary alloc] init];
        do {
            [_propertyInfo addEntriesFromDictionary:[FAPropertyUtil propertyInfoForClass:cls]];
            cls = [cls superclass];
        } while (cls != [FATraktDatatype class]);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        for (NSString *key in _propertyInfo) {
            if ([aDecoder containsValueForKey:key]) {
                id value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in _propertyInfo) {
        FAPropertyInfo *propertyInfo = [_propertyInfo objectForKey:key];
        if (!propertyInfo.isReadonly) {
            id value = [self valueForKey:key];
            [aCoder encodeObject:value forKey:key];
        }
    }
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
    DDLogModel(@"Finished mapping objects for datatype %@", NSStringFromClass([self class]));
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

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:propertyType.objcClass]) {
        if ([object isKindOfClass:[NSString class]]) {
            // If string, set string
            object = [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([object isEqualToString:@""]) {
                // If string empty, set to nil
                object = nil;
            }
        }
        [self setValue:object forKey:key];
    } else if (propertyType.objcClass == [NSDate class] && [object isKindOfClass:[NSNumber class]]) {
        // If NSDate, set date
        NSNumber *number = (NSNumber *)object;
        NSTimeInterval timeInterval = [number doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        [self setValue:date forKey:key];
    } else if ([propertyType typeIsEqualToEncode:@encode(BOOL)]) {
        // If BOOL, set BOOL
        [self setValue:object forKey:key];
    }
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    FAPropertyInfo *propertyInfo = [_propertyInfo objectForKey:key];
    
    if (!propertyInfo) {
        DDLogModel(@"[%@] Can't match object \"%@\" of class \"%@\" to non-existing property with key \"%@\"", NSStringFromClass([self class]), object, NSStringFromClass([object class]), key);
        return;
    }
    
    [self mapObject:object ofType:propertyInfo toPropertyWithKey:key];
}

@end
