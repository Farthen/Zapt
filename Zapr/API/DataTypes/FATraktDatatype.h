//
//  FATraktDatatype.h
//  Zapr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAPropertyInfo.h"

typedef enum {
    FATraktStatusUnkown = 0,
    FATraktStatusSuccess = 1,
    FATraktStatusFailed = 2,
} FATraktStatus;

@interface FATraktDatatype : NSObject <NSCoding, NSCopying> {
    NSDictionary *_originDict;
}

// Don't call this yourself, override it if you want to associate a custom action
- (void)finishedMappingObjects;

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)mapObjectsInDict:(NSDictionary *)dict;
- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key;
- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key;

- (BOOL)shouldMergeObjectForKey:(NSString *)key;
- (void)mergeWithObject:(FATraktDatatype *)object;

@end
