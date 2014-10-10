//
//  FADictionaryHashLocator.h
//  Zapt
//
//  Created by Finn Wilke on 23/01/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FADictionaryHashLocator : NSObject

// Inits the object with a given hash
+ (instancetype)hashLocatorWithHash:(NSUInteger)hash;
+ (instancetype)hashLocatorWithHashString:(NSString *)hashString;

// Returns the hash that was set when initializing it
- (NSUInteger)hash;

// Returns isEqual:YES when the hash is the same
- (BOOL)isEqual:(id)object;

@end
