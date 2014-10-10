//
//  FADictionaryHashLocator.m
//  Zapt
//
//  Created by Finn Wilke on 23/01/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FADictionaryHashLocator.h"

@implementation FADictionaryHashLocator {
    NSUInteger _hash;
}

+ (instancetype)hashLocatorWithHashString:(NSString *)hashString
{
    unsigned long long scannedLongLong;
    NSScanner *scanner = [NSScanner scannerWithString:hashString];
    [scanner scanUnsignedLongLong:&scannedLongLong];
    
    NSUInteger hash = (NSUInteger)scannedLongLong;
    
    return [self hashLocatorWithHash:hash];
}

+ (instancetype)hashLocatorWithHash:(NSUInteger)hash
{
    FADictionaryHashLocator *hashLocator = [[self alloc] init];
    hashLocator->_hash = hash;
    return hashLocator;
}

- (NSUInteger)hash
{
    return _hash;
}

- (BOOL)isEqual:(id)object
{
    return [object hash] == _hash;
}

@end
