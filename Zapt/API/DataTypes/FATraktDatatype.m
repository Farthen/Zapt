//
//  FATraktDatatype.m
//  Zapt
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FAPropertyUtil.h"

@interface FATraktDatatype ()
@property NSDate *creationDate;
@property (nonatomic) BOOL currentlyCopying;
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
    
    return [((NSDictionary *)propertyInfo)copy];
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

- (void)copyVitalDataToNewObject:(id)newDatatype
{
    return;
}

- (BOOL)shouldCopyPropertyWithKey:(NSString *)key
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    id newObject = [[self.class allocWithZone:zone] init];
    [newObject setCurrentlyCopying:YES];
    NSDictionary *propertyInfos = [self.class propertyInfo];
    
    [self copyVitalDataToNewObject:newObject];
    
    for (id key in propertyInfos) {
        FAPropertyInfo *propertyInfo = [propertyInfos objectForKey:key];
        NSString *propertyKey = propertyInfo.name;
        
        if (!propertyInfo.isReadonly && [self shouldCopyPropertyWithKey:propertyKey]) {
            id propertyData = [self valueForKey:propertyKey];
            
            if ([propertyData conformsToProtocol:@protocol(NSCopying)] && propertyInfo.isRetain == YES) {
                id copiedData;
                
                copiedData = propertyData;
                
                [newObject setValue:copiedData forKey:key];
            } else if (propertyInfo.isWeak == YES || propertyInfo.isObjcClass == NO) {
                [newObject setValue:propertyData forKey:key];
            } else if (propertyData != nil) {
                DDLogWarn(@"Failed copying property with key %@: Underlying object does not support NSCopying", propertyKey);
            }
        }
    }
    
    [newObject setCurrentlyCopying:NO];
    
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

- (id)newValueForMergingKey:(NSString *)key fromOldObject:(id)oldObject propertyInfo:(FAPropertyInfo *)propertyInfo
{
    FAPropertyInfo *info = self.class.propertyInfo[key];
    
    BOOL mergeNew = NO;
    BOOL mergeOld = NO;
    
    // Don't merge non objc properties
    // This will otherwise break for rating for example
    if (info.isObjcClass) {
        if ([self valueForKey:key]) {
            mergeNew = YES;
        } else if ([oldObject valueForKey:key]) {
            mergeOld = YES;
        }
    } else {
        // When merging non-classes, just take the value of the newest object
        mergeNew = YES;
    }
    
    if ((mergeNew || mergeOld) && info.isReadonly == NO) {
        if (mergeOld && [self shouldMergeObjectForKey:key]) {
            return [oldObject valueForKey:key];
        }
        
        if (mergeNew && [oldObject shouldMergeObjectForKey:key]) {
            return [self valueForKey:key];
        }
    }
    
    return nil;
}

- (void)mergeWithObject:(FATraktDatatype *)object
{
    // Merges the values from "object" into the reciever. Only merges objc-classes.
    // Merge strategy: Two-way merge: The newest object is the best
    if (self == object) {
        return;
    }
    
    if (self.currentlyCopying) {
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
        newObject = object;
        oldObject = self;
    } else {
        oldObject = object;
        newObject = self;
    }
    
    NSDictionary *propertyInfos = self.class.propertyInfo;
    
    for (NSString *key in propertyInfos) {
        FAPropertyInfo *info = self.class.propertyInfo[key];
        
        if (!info.isReadonly) {
            id newValue = [newObject newValueForMergingKey:key fromOldObject:oldObject propertyInfo:info];
            
            if ([newObject shouldMergeObjectForKey:key]) {
                [newObject setValue:newValue forKey:key];
            }
            
            if ([oldObject shouldMergeObjectForKey:key]) {
                [oldObject setValue:newValue forKey:key];
            }
        }
    }
}

- (void)updateTimestamp
{
    self.creationDate = [NSDate date];
}

@end
