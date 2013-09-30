//
//  FAZapr.h
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAZapr : NSObject

//+ (NSString *)licenseString;

+ (NSString *)versionNumberString;
+ (NSString *)buildString;
+ (NSString *)versionNumberDescription;

+ (NSDate *)compilationDate;

@end
