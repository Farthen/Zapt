//
//  FATraktDatatype.m
//  Zapr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FAPropertyUtil.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_WARN

@interface FATraktDatatype ()
@property NSDate *creationDate;
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
    
    while (cls != [FATraktDatatype class]) {
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
        self.creationDate = [NSDate date];
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
        
        self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
    }
    return self;
}

- (NSSet *)notEncodableKeys;
{
    return [NSSet set];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSDictionary *propertyInfos = [self.class propertyInfo];
    for (NSString *key in propertyInfos) {
        FAPropertyInfo *propertyInfo = [propertyInfos objectForKey:key];
        if (!propertyInfo.isReadonly && ![[self notEncodableKeys] containsObject:key]) {
            id value = [self valueForKey:key];
            
            [aCoder encodeObject:value forKey:key];
        }
    }
    
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
}

- (id)initWithJSONDict:(NSDictionary *)dict
{
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        self = [self init];
        if (self) {
            [self mapObjectsInDict:dict];
        }
        return self;
    } else {
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    id newObject = [[self.class allocWithZone:zone] init];
    NSDictionary *propertyInfos = [self.class propertyInfo];
    for (id key in propertyInfos) {
        FAPropertyInfo *propertyInfo = [propertyInfos objectForKey:key];
        if (!propertyInfo.isReadonly) {
            
            NSString *propertyKey = propertyInfo.name;
            id propertyData = [self valueForKey:propertyKey];
            
            if ([propertyData conformsToProtocol:@protocol(NSCopying)] || propertyInfo.isRetain == NO) {
                id copiedData = [propertyData copy];
                [newObject setValue:copiedData forKey:key];
            } else if (propertyData != nil) {
                DDLogWarn(@"Failed copying property with key %@: Underlying object does not support NSCopying", propertyKey);
            }
        }
    }
    DDLogModel(@"Copied object %@ to new object %@", self, newObject);
    return newObject;
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
        /*NSTimeInterval pacificUnixTime = [number doubleValue];
        
        // Set to PST (pacific time zone, gmt-8)
        NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
        
        NSInteger destinationGMTOffset = [sourceTimeZone secondsFromGMT];
        NSTimeInterval unixTime = pacificUnixTime - destinationGMTOffset;*/
        NSTimeInterval unixTime = [number doubleValue];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
        
        [self setValue:date forKey:key];
        
    } else if (propertyType.objcClass == [NSString class] && [object isKindOfClass:[NSNumber class]]) {
        // If it is a number but the property needs a string, just convert
        NSNumber *number = (NSNumber *)object;
        NSString *string = [number stringValue];
        [self setValue:string forKey:key];
        
    } else if ([propertyType.objcClass isSubclassOfClass:[FATraktDatatype class]]) {
        // This is another FATraktDatatype
        id datatype = [[propertyType.objcClass alloc] initWithJSONDict:object];
        [self setValue:datatype forKey:key];
        
    } else if (propertyType.isObjcClass) {
        // It's an objc class but not one of the above so it isn't the same class as the property
        
        if (([object isKindOfClass:[NSArray      class]] && propertyType.objcClass == [NSMutableArray      class]) ||
            ([object isKindOfClass:[NSDictionary class]] && propertyType.objcClass == [NSMutableDictionary class])) {
            // Convert array/dict to mutable copy
            
            [self setValue:[object mutableCopy] forKey:key];
        } else if (object) {
            // Wrong class mapping. Yield an error if in debug mode. Otherwise don't map anything and just fail silently
            
            #if DEBUG
            [NSException raise:@"WrongPropertyMapping" format:@"<%@.%@> Tried to map object of type %@ to property of type %@", [self className], propertyType.name, [object className], [propertyType.objcClass className]];
            #endif
        }
    } else {
        // This gets called for things like NSNumber setting to NSInteger property or NSNumber to BOOL
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
    
    if (object == [NSNull null]) {
        object = nil;
    }
    
    [self mapObject:object ofType:propertyInfo toPropertyWithKey:key];
}

- (BOOL)shouldMergeObjectForKey:(NSString *)key
{
    return YES;
}

- (void)mergeWithObject:(FATraktDatatype *)object
{
    // Merges the values from "object" into the reciever. Only merges objc-classes.
    // Merge strategy: Two-way merge: The newest object is the best
    if (self == object) {
        return;
    }
    
    if (![object isKindOfClass:[self class]]) {
        DDLogError(@"Can't merge object of type %@ into object of type %@", NSStringFromClass([object class]), NSStringFromClass([self class]));
        return;
    }
    
    FATraktDatatype *oldObject;
    FATraktDatatype *newObject;
    
    if ([self.creationDate compare:object.creationDate] == NSOrderedAscending) {
        // Reciever is earlier
        newObject = self;
        oldObject = object;
    } else {
        oldObject = self;
        newObject = object;
    }
    
    
    NSDictionary *propertyInfos = self.class.propertyInfo;
    for (NSString *key in propertyInfos) {
        FAPropertyInfo *info = propertyInfos[key];
        BOOL mergeNew = NO;
        BOOL mergeOld = NO;
        
        if ([newObject valueForKey:key]) {
            mergeNew = YES;
        } else if ([oldObject valueForKey:key]) {
            mergeOld = YES;
        }
        
        if ((mergeNew || mergeOld) && info.isReadonly == NO) {
            if (mergeOld && [newObject shouldMergeObjectForKey:key]) {
                [newObject setValue:[object valueForKey:key] forKey:key];
            } else if (mergeNew && [newObject shouldMergeObjectForKey:key]) {
                [oldObject setValue:[object valueForKey:key] forKey:key];
            }
        }
    }
}

@end
