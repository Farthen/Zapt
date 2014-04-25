//
//  NSString+ContainsSubstring.m
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "NSString+ContainsSubstring.h"

@implementation NSString (ContainsSubstring)

- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end
