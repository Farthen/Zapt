//
//  NSObject+ClassName.m
//  Trakr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSObject+ClassName.h"

@implementation NSObject (ClassName)

+ (NSString *)className
{
    return NSStringFromClass([self class]);
}

- (NSString *)className
{
    return NSStringFromClass([self class]);
}

@end
