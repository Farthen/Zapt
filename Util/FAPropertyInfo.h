//
//  FAPropertyType.h
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface FAPropertyInfo : NSObject

@property (readonly) BOOL isReadonly;
@property (readonly) BOOL isCopy;
@property (readonly) BOOL isRetain;
@property (readonly) BOOL isAtomic;
@property (readonly) NSString *customGetter;
@property (readonly) NSString *customSetter;
@property (readonly) BOOL isDynamic;
@property (readonly) BOOL isWeak;
@property (readonly) BOOL isGarbageCollectable;
@property (readonly) const char *typeEncoding;
@property (readonly) NSString *name;
@property (readonly) Class objcClass;
@property (readonly) BOOL isObjcClass;
@property (readonly) NSString *className;

- (id)initWithProperty:(objc_property_t)property;
- (BOOL)typeIsEqualToEncode:(const char *)encode;

@end
