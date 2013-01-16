//
// Copyright (C) 2011 Andrew Pepperrell - http://preppeller.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "APLog.h"

@interface APLog(Private)
+(void) doLog:(NSString *)log;
@end

// Alfred Log
@implementation APLog

// do the actual logging
+(void) doLog:(NSString *)log level:(NSString *)level {
	NSLog(@"[%@] %@", level, log);
}

// finest log
+(void) tiny:(NSString *)format,... {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"logging"] >= 3) {
		va_list args;
		va_start(args, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
		[APLog doLog:str level:@"TINY"];
		va_end(args);
	}
}

// fine log
+(void) fine:(NSString *)format,... {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"logging"] >= 2) {
		va_list args;
		va_start(args, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
		[APLog doLog:str level:@"FINE"];
		va_end(args);
	}
}

// info log
+(void) info:(NSString *)format,... {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"logging"] >= 1) {
		va_list args;
		va_start(args, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
		[APLog doLog:str level:@"INFO"];
		va_end(args);
	}
}

// warning log
+(void) warning:(NSString *)format,... {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"logging"] >= 1) {
		va_list args;
		va_start(args, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
		[APLog doLog:str level:@"WARNING"];
		va_end(args);
	}
}

// error log
+(void) error:(NSString *)format,... {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"logging"] >= 0) {
		va_list args;
		va_start(args, format);
		NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
		[APLog doLog:str level:@"ERROR"];
		va_end(args);
	}
}

@end
