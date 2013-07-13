//
//  FATrakt.h
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FATraktDatatype.h"
#import "FATraktContent.h"
#import "FATraktWatchableBaseItem.h"
#import "FATraktMovie.h"
#import "FATraktImageList.h"
#import "FATraktShow.h"
#import "FATraktSeason.h"
#import "FATraktEpisode.h"
#import "FATraktPeopleList.h"
#import "FATraktPeople.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FATraktSearchResult.h"

@class LRRestyResponse;

extern NSString *const FATraktRatingNone;
extern NSString *const FATraktRatingLove;
extern NSString *const FATraktRatingHate;

extern NSString *const FATraktActivityNotificationSearch;
extern NSString *const FATraktActivityNotificationCheckAuth;

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
+ (NSString *)nameForContentType:(FATraktContentType)type;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural;
+ (NSString *)interfaceNameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized;

extern NSString *const kFAKeychainKeyCredentials;

#pragma mark API
- (void)verifyCredentials:(void (^)(BOOL valid))block;

- (void)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block onError:(void (^)(LRRestyResponse *response))error;

- (void)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (void)movieDetailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block;

- (void)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (void)showDetailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))block;
- (void)showDetailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))block;

- (void)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (void)episodeDetailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))block;

- (void)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))block;
- (void)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;
- (void)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;

- (void)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))block;
- (void)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))block;

- (void)rate:(FATraktContent *)content love:(NSString *)love callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;
@end
