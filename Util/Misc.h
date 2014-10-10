//
//  Misc.h
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#ifndef Zapt_Misc_h
#define Zapt_Misc_h

#import <Foundation/NSDate.h>

#define FATimeIntervalOneSecond 1
#define FATimeIntervalSeconds(x) FATimeIntervalOneSecond * x

#define FATimeIntervalOneMinute FATimeIntervalSeconds(60)
#define FATimeIntervalMinutes(x) FATimeIntervalOneMinute * x

#define FATimeIntervalOneHour FATimeIntervalMinutes(60)
#define FATimeIntervalHours(x) FATimeIntervalOneHour * x

#define FATimeIntervalOneDay FATimeIntervalHours(24)
#define FATimeIntervalDays(x) FATimeIntervalOneDay * x

#define FATimeIntervalOneWeek FATimeIntervalDays(7)
#define FATimeIntervalWeeks(x) FATimeIntervalOneWeek * x




#define FACacheCostOneByte 1
#define FACacheCostBytes(x) FACacheCostOneByte * x

#define FACacheCostOneKibibyte FACacheCostBytes(1024)
#define FACacheCostKibibytes(x) FACacheCostOneKibibyte * x

#define FACacheCostOneMebibyte FACacheCostKibibytes(1024)
#define FACacheCostMebibytes(x) FACacheCostOneMebibyte * x

#define FACacheCostOneGibibyte FACacheCostMebibytes(1024)
#define FACacheCostGibibytes(x) FACacheCostOneGibibyte * x



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#if DEBUG
#define FA_MUST_OVERRIDE_IN_SUBCLASS [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
#else
#define FA_MUST_OVERRIDE_IN_SUBCLASS NSLog(@"[ERROR] %@ should have been overridden in a subclass but it wasn't! Not bailing out but this will probably fail silently", NSStringFromSelector(_cmd));
#endif

#if DEBUG
#define FA_INVALID_METHOD [NSException raise:NSInternalInconsistencyException format:@"You can't call %@ because it is not supported!", NSStringFromSelector(_cmd)];
#else
#define FA_INVALID_METHOD NSLog(@"[ERROR] You can't call %@ because it is not supported! Not bailing out but this will probably fail silently", NSStringFromSelector(_cmd));
#endif

#endif
