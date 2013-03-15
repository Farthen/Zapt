//
//  FALogFormatter.m
//  Trakr
//
//  Created by Finn Wilke on 15.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FALogFormatter.h"

@implementation FALogFormatter {
    NSDateFormatter *_dateFormatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR         : logLevel = @"ERROR"  ; break;
        case LOG_FLAG_WARN          : logLevel = @"WARN"   ; break;
        case LOG_FLAG_INFO          : logLevel = @"INFO"   ; break;
        case LOG_FLAG_SMALL         : logLevel = @"SMALL"  ; break;
        case LOG_FLAG_TINY          : logLevel = @"TINY"   ; break;
        case LOG_FLAG_MODEL         : logLevel = @"MODEL"  ; break;
        case LOG_FLAG_VIEW          : logLevel = @"VIEW"   ; break;
        case LOG_FLAG_CONTROLLER    : logLevel = @"CONT"   ; break;
        case LOG_FLAG_VIEWCONTROLLER: logLevel = @"VCONT"  ; break;
        default                     : logLevel = @"UNKNOWN"; break;
    }
    
    NSDate *date = logMessage->timestamp;
    NSString *dateString = [_dateFormatter stringFromDate:date];
#ifdef DEBUG
    //Also display the file the logging occurred in to ease later debugging
    NSString *file = [[[NSString stringWithUTF8String:logMessage->file] lastPathComponent] stringByDeletingPathExtension];
    NSString *threadId = [NSString stringWithFormat:@"T:0x%X", logMessage->machThreadID];
    
    //Format the message
    return [NSString stringWithFormat:@"%@ %@ [%@]: \"%@\" || [%@@%s@%i]", dateString, threadId, logLevel, logMessage->logMsg, file, logMessage->function, logMessage->lineNumber];
#else
    return [NSString stringWithFormat:@"%@ [%@]: %@", dateString, logLevel, logMessage->logMsg];
#endif
}

@end
