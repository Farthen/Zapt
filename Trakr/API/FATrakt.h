//
//  FATrakt.h
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FATrakt : NSObject {
    NSString *traktBaseURL;
    NSString *apiKey;
    NSString *apiUser;
    NSString *apiPasswordHash;
}

@property (retain) NSString *apiUser;
@property (retain) NSString *apiPasswordHash;

+ (FATrakt *)sharedInstance;
+ (NSString *)passwordHashForPassword:(NSString *)password;
- (id)initWithUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;
- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;

extern NSString *const kFADefaultsKeyTraktUsername;
extern NSString *const kFADefaultsKeyTraktPasswordHash;

#pragma mark API
- (void)verifyCredentials:(void (^)(BOOL valid))block;
- (void)searchMovies:(NSString *)query callback:(void (^)(NSArray* result))block;
- (void)searchShows:(NSString *)query callback:(void (^)(NSArray* result))block;
- (void)searchEpisodes:(NSString *)query callback:(void (^)(NSArray* result))block;
@end
