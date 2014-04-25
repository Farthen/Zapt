//
//  FAZapt.h
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAZapt : NSObject

//+ (NSString *)licenseString;

+ (NSString *)applicationName;

+ (NSString *)versionNumberString;
+ (NSString *)buildString;
+ (NSString *)versionNumberDescription;

+ (NSDate *)compilationDate;
+ (NSString *)appStoreURL;

@end
