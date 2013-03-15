//
//  FAPropertyType.m
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAPropertyInfo.h"
#import <objc/runtime.h>

@implementation FAPropertyInfo {
    char *_typeEncoding;
}

- (id)initWithProperty:(objc_property_t)property
{
    self = [super init];
    if (self) {
        [self fillPropertyInfo:property];
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *type = [[NSMutableString alloc] init];
    if (_isReadonly) {
        [type appendString:@"readonly, "];
    }
    if (_isCopy) {
        [type appendString:@"copy, "];
    } else {
        [type appendString:@"assign, "];
    }
    if (_isRetain) {
        [type appendString:@"retain, "];
    }
    if (_isAtomic) {
        [type appendString:@"atomic, "];
    }
    if (_isDynamic) {
        [type appendString:@"dynamic, "];
    }
    if (_isWeak) {
        [type appendString:@"weak, "];
    }
    if (![type isEqualToString:@""]) {
        [type deleteCharactersInRange:NSMakeRange(type.length - 2, 2)];
    }
    return [NSString stringWithFormat:@"<FAPropertyInfo of property: @property (%@) %s %@>", type, self.typeEncoding, self.name];
}

- (void)fillPropertyInfo:(objc_property_t)property
{
    // Set default values
    _isReadonly = NO;
    _isCopy = NO;
    _isRetain = NO;
    _isAtomic = YES;
    _isDynamic = NO;
    _isWeak = NO;
    _isGarbageCollectable = NO;
    _customSetter = nil;
    _customGetter = nil;
    _className = nil;
    _objcClass = nil;
    _isObjcClass = NO;
    
    _name = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
    const char *attributeString = property_getAttributes(property);
    
    char *attribute;
    char buffer[1 + strlen(attributeString)];
    strcpy(buffer, attributeString);
    char *state = buffer;
    while ((attribute = strsep(&state, ",")) != NULL) {
        const char firstChar = attribute[0];
        switch (firstChar) {
            case 'T':
                [self setTypeEncoding:attribute + 1];
                if (attribute[1] == '@') {
                    // The class name string looks like this: @"NSObject"
                    NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
                    _className = name;
                    _objcClass = NSClassFromString(_className);
                    _isObjcClass = YES;
                }
                break;
            case 'R':
                _isReadonly = YES;
                break;
            case 'C':
                _isCopy = YES;
                break;
            case '&':
                _isRetain = YES;
                break;
            case 'N':
                _isAtomic = NO;
                break;
            case 'D':
                _isDynamic = YES;
                break;
            case 'W':
                _isWeak = YES;
                break;
            case 'P':
                _isGarbageCollectable = YES;
                break;
            case 'G':
                _customGetter = [NSString stringWithCString:attribute +1 encoding:NSASCIIStringEncoding];
                break;
            case 'S':
                _customSetter = [NSString stringWithCString:attribute +1 encoding:NSASCIIStringEncoding];
                break;
            default:
                break;
        }
    }
}

- (BOOL)typeIsEqualToEncode:(const char*)encode
{
    return strcmp(_typeEncoding, encode) == 0;
}

- (const char*)typeEncoding
{
    return _typeEncoding;
}

- (void)setTypeEncoding:(const char *)typeEncoding
{
    @synchronized (self) {
        if (_typeEncoding) {
            free(_typeEncoding);
            _typeEncoding = nil;
        }
        if (typeEncoding && typeEncoding[0]) {
            _typeEncoding = strdup(typeEncoding);
        }
    }
}

- (void)dealloc
{
    free(_typeEncoding);
    _typeEncoding = nil;
}

@end
