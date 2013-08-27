//
//  Misc.h
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#ifndef Zapr_Misc_h
#define Zapr_Misc_h

#import <Foundation/NSDate.h>

#define NSTimeIntervalOneSecond 1
#define NSTimeIntervalSeconds(x) NSTimeIntervalOneSecond * x

#define NSTimeIntervalOneMinute NSTimeIntervalSeconds(60)
#define NSTimeIntervalMinutes(x) NSTimeIntervalOneMinute * x

#define NSTimeIntervalOneHour NSTimeIntervalMinutes(60)
#define NSTimeIntervalHours(x) NSTimeIntervalOneHour * x

#define NSTimeIntervalOneDay NSTimeIntervalHours(24)
#define NSTimeIntervalDays(x) NSTimeIntervalOneDay * x

#define NSTimeIntervalOneWeek NSTimeIntervalDays(7)
#define NSTimeIntervalWeeks(x) NSTimeIntervalOneWeek * x




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

#endif
