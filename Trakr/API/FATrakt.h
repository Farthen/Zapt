//
//  FATrakt.h
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FATraktMovie;

@interface FATrakt : NSObject {
    NSString *_traktBaseURL;
    NSString *_apiKey;
    NSString *_apiUser;
    NSString *_apiPasswordHash;
}

@property (readonly) BOOL usernameAndPasswordSaved;
@property (retain) NSString *apiUser;
@property (retain) NSString *apiPasswordHash;

- (NSString *)storedUsername;
- (NSString *)storedPassword;

+ (FATrakt *)sharedInstance;
+ (NSString *)passwordHashForPassword:(NSString *)password;
- (id)initWithUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;
- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;

extern NSString *const kFAKeychainKeyCredentials;

#pragma mark API
- (void)verifyCredentials:(void (^)(BOOL valid))block;
- (void)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block;
- (void)searchMovies:(NSString *)query callback:(void (^)(NSArray* result))block;
- (void)movieDetailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block;
- (void)searchShows:(NSString *)query callback:(void (^)(NSArray* result))block;
- (void)searchEpisodes:(NSString *)query callback:(void (^)(NSArray* result))block;
@end
