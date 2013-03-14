//
//  FAPropertyUtil.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAPropertyUtil.h"
#import "FAPropertyInfo.h"
#import <DDLog.h>
#import <objc/runtime.h>

@implementation FAPropertyUtil

+ (NSDictionary *)propertyInfoForClass:(Class)class
{
    if (class == nil) {
        return nil;
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        FAPropertyInfo *propertyInfo = [[FAPropertyInfo alloc] initWithProperty:property];
        [results setObject:propertyInfo forKey:propertyInfo.name];
    }
    free(properties);
    return results;
}

@end
