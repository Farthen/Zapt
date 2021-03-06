//
//  FATraktDatatype.h
//  Zapt
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAPropertyInfo.h"

typedef NS_ENUM(NSUInteger, FATraktStatus) {
    FATraktStatusUnkown = 0,
    FATraktStatusSuccess = 1,
    FATraktStatusFailed = 2,
};

@interface FATraktDatatype : NSObject <NSCoding> {
    NSDictionary *_originDict;
}

+ (NSDictionary *)propertyInfo;

@property (readonly) NSDate *creationDate;
@property (readonly) BOOL currentlyCopying;

// Don't call this yourself, override it if you want to associate a custom action
- (void)finishedMappingObjects;

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)mapObjectsInDict:(NSDictionary *)dict;
- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key;
- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key;

- (void)copyVitalDataToNewObject:(id)newDatatype;
- (BOOL)shouldCopyPropertyWithKey:(NSString *)key;

- (NSSet *)notEncodableKeys;

- (BOOL)shouldMergeObjectForKey:(NSString *)key;
- (id)newValueForMergingKey:(NSString *)key fromOldObject:(id)oldObject propertyInfo:(FAPropertyInfo *)propertyInfo;
- (void)mergeWithObject:(FATraktDatatype *)object;
- (void)updateTimestamp;

@end
