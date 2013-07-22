//
//  FALogLevels.h
//  Trakr
//
//  Created by Finn Wilke on 15.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#ifndef Trakr_FALogLevels_h
#define Trakr_FALogLevels_h

#undef LOG_FLAG_ERROR
#undef LOG_FLAG_WARN
#undef LOG_FLAG_INFO
#undef LOG_FLAG_VERBOSE
#undef LOG_FLAG_SMALL
#undef LOG_FLAG_TINY
#undef LOG_FLAG_MODEL
#undef LOG_FLAG_VIEW
#undef LOG_FLAG_CONTROLLER
#undef LOG_FLAG_VIEWCONTROLLER


#undef LOG_LEVEL_OFF
#undef LOG_LEVEL_ALL_SPECIFIC
#undef LOG_LEVEL_ERROR
#undef LOG_LEVEL_WARN
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_VERBOSE
#undef LOG_LEVEL_SMALL
#undef LOG_LEVEL_TINY
#undef LOG_LEVEL_MODEL
#undef LOG_LEVEL_VIEW
#undef LOG_LEVEL_CONTROLLER
#undef LOG_LEVEL_VIEWCONTOLLER

#undef GLOBAL_LOG_LEVEL
#undef LOCAL_LOG_LEVEL

#undef LOG_LEVEL

#undef LOG_ERROR
#undef LOG_WARN
#undef LOG_INFO
#undef LOG_VERBOSE
#undef LOG_SMALL

#undef LOG_ASYNC_ENABLED

#undef LOG_ASYNC_ERROR
#undef LOG_ASYNC_OTHERS


#undef DDLogError
#undef DDLogWarn
#undef DDLogInfo
#undef DDLogVerbose
#undef DDLogSmall
#undef DDLogTiny
#undef DDLogModel
#undef DDLogView
#undef DDLogController
#undef DDLogViewController

#undef DDLogCError
#undef DDLogCWarn
#undef DDLogCInfo
#undef DDLogCVerbose
#undef DDLogCSmall
#undef DDLogCTiny
#undef DDLogCModel
#undef DDLogCView
#undef DDLogCController
#undef DDLogCViewController


#define LOG_FLAG_ERROR    (1 << 0)  // 0...0001
#define LOG_FLAG_WARN     (1 << 1)  // 0...0010
#define LOG_FLAG_INFO     (1 << 2)  // 0...0100
#define LOG_FLAG_VERBOSE  (1 << 3)  // 0...1000
#define LOG_FLAG_SMALL    (1 << 4)
#define LOG_FLAG_TINY     (1 << 5)
#define LOG_FLAG_MODEL    (1 << 6)
#define LOG_FLAG_VIEW     (1 << 7)
#define LOG_FLAG_CONTROLLER (1 << 8)
#define LOG_FLAG_VIEWCONTROLLER (1 << 9)


#define LOG_LEVEL_OFF     0
#define LOG_LEVEL_ALL_SPECIFIC (LOG_FLAG_MODEL | LOG_FLAG_VIEW | LOG_FLAG_CONTROLLER | LOG_FLAG_VIEWCONTROLLER)
#define LOG_LEVEL_ERROR         (LOG_FLAG_ERROR)
#define LOG_LEVEL_WARN          (LOG_LEVEL_ERROR   | LOG_FLAG_WARN)
#define LOG_LEVEL_INFO          (LOG_LEVEL_WARN    | LOG_FLAG_INFO)
#define LOG_LEVEL_VERBOSE       (LOG_LEVEL_INFO    | LOG_FLAG_VERBOSE)
#define LOG_LEVEL_SMALL         (LOG_LEVEL_VERBOSE | LOG_FLAG_SMALL | LOG_LEVEL_ALL_SPECIFIC)
#define LOG_LEVEL_TINY          (LOG_LEVEL_SMALL   | LOG_FLAG_TINY)
#define LOG_LEVEL_MODEL         (LOG_LEVEL_WARN    | LOG_FLAG_MODEL)
#define LOG_LEVEL_VIEW          (LOG_LEVEL_WARN    | LOG_FLAG_VIEW)
#define LOG_LEVEL_CONTROLLER    (LOG_LEVEL_WARN    | LOG_FLAG_CONTROLLER)
#define LOG_LEVEL_VIEWCONTOLLER (LOG_LEVEL_WARN    | LOG_FLAG_VIEWCONTROLLER)
#define LOG_LEVEL_ALL           (LOG_LEVEL_TINY)

#define GLOBAL_LOG_LEVEL LOG_LEVEL_VIEW
#ifdef DEBUG
#define RELEASE_LOG_LEVEL LOG_LEVEL_ALL
#else
#define RELEASE_LOG_LEVEL LOG_LEVEL_INFO
#endif

#define LOG_LEVEL GLOBAL_LOG_LEVEL

#define LOG_ERROR   (LOG_LEVEL & LOG_FLAG_ERROR)
#define LOG_WARN    (LOG_LEVEL & LOG_FLAG_WARN)
#define LOG_INFO    (LOG_LEVEL & LOG_FLAG_INFO)
#define LOG_VERBOSE (LOG_LEVEL & LOG_FLAG_VERBOSE)
#define LOG_SMALL   (LOG_LEVEL & LOG_FLAG_SMALL)

#define LOG_ASYNC_ENABLED YES

#define LOG_ASYNC_ERROR   (NO)
#define LOG_ASYNC_OTHERS  (YES && LOG_ASYNC_ENABLED)


#define DDLogError(frmt, ...)          LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,  ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_ERROR,          0, frmt, ##__VA_ARGS__)
#define DDLogWarn(frmt, ...)           LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_WARN,           0, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)           LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_INFO,           0, frmt, ##__VA_ARGS__)
#define DDLogVerbose(frmt, ...)        LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VERBOSE,        0, frmt, ##__VA_ARGS__)
#define DDLogSmall(frmt, ...)          LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_SMALL,          0, frmt, ##__VA_ARGS__)
#define DDLogTiny(frmt, ...)           LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_TINY,           0, frmt, ##__VA_ARGS__)
#define DDLogModel(frmt, ...)          LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_MODEL,          0, frmt, ##__VA_ARGS__)
#define DDLogView(frmt, ...)           LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VIEW,           0, frmt, ##__VA_ARGS__)
#define DDLogController(frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_CONTROLLER,     0, frmt, ##__VA_ARGS__)
#define DDLogViewController(frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VIEWCONTROLLER, 0, frmt, ##__VA_ARGS__)

#define DDLogCError(frmt, ...)          LOG_C_MAYBE(LOG_ASYNC_ERROR,  ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_ERROR,          0, frmt, ##__VA_ARGS__)
#define DDLogCWarn(frmt, ...)           LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_WARN,           0, frmt, ##__VA_ARGS__)
#define DDLogCInfo(frmt, ...)           LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_INFO,           0, frmt, ##__VA_ARGS__)
#define DDLogCVerbose(frmt, ...)        LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VERBOSE,        0, frmt, ##__VA_ARGS__)
#define DDLogCSmall(frmt, ...)          LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_SMALL,          0, frmt, ##__VA_ARGS__)
#define DDLogCTiny(frmt, ...)           LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_TINY,           0, frmt, ##__VA_ARGS__)
#define DDLogCModel(frmt, ...)          LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_MODEL,          0, frmt, ##__VA_ARGS__)
#define DDLogCView(frmt, ...)           LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VIEW,           0, frmt, ##__VA_ARGS__)
#define DDLogCController(frmt, ...)     LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_CONTROLLER,     0, frmt, ##__VA_ARGS__)
#define DDLogCViewController(frmt, ...) LOG_C_MAYBE(LOG_ASYNC_OTHERS, ((LOG_LEVEL | GLOBAL_LOG_LEVEL) & RELEASE_LOG_LEVEL), LOG_FLAG_VIEWCONTROLLER, 0, frmt, ##__VA_ARGS__)

#endif
