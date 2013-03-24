//
//  FATraktDatatype.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FAPropertyUtil.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_CONTROLLER

@interface FATraktDatatype ()
- (void)finishedMappingObjects;

@end

static NSMutableDictionary *__traktPropertyInfos = nil;

@implementation FATraktDatatype

+ (void)initialize
{
    if (!__traktPropertyInfos) {
        __traktPropertyInfos = [[NSMutableDictionary alloc] init];
    }
    DDLogController(@"Adding class %@ to dict", self);
    [__traktPropertyInfos setObject:[self.class fetchPropertyInfo] forKey:NSStringFromClass(self)];
}

+ (NSDictionary *)fetchPropertyInfo
{
    Class cls = [self class];
    NSMutableDictionary *propertyInfo = [[NSMutableDictionary alloc] init];
    while (cls != [FATraktDatatype class])
    {
        [propertyInfo addEntriesFromDictionary:[FAPropertyUtil propertyInfoForClass:cls]];
        cls = [cls superclass];
    }
    return [((NSDictionary *)propertyInfo) copy];
}

+ (NSDictionary *)propertyInfo
{
    NSDictionary *propertyInfos = [__traktPropertyInfos objectForKey:NSStringFromClass(self)];
    return propertyInfos;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        NSDictionary *propertyInfos = [self.class propertyInfo];
        for (NSString *key in propertyInfos) {
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
    NSDictionary *propertyInfos = [self.class propertyInfo];
    for (NSString *key in propertyInfos) {
        FAPropertyInfo *propertyInfo = [propertyInfos objectForKey:key];
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
    NSDictionary *propertyInfos = [self.class propertyInfo];
    FAPropertyInfo *propertyInfo = [propertyInfos objectForKey:key];
    
    if (!propertyInfo) {
        DDLogModel(@"[%@] Can't match object \"%@\" of class \"%@\" to non-existing property with key \"%@\"", NSStringFromClass([self class]), object, NSStringFromClass([object class]), key);
        return;
    }
    
    [self mapObject:object ofType:propertyInfo toPropertyWithKey:key];
}

@end
