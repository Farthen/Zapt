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
#import "FATraktShowProgress.h"
#import "FATraktAccountSettings.h"
#import "FATraktViewingSettings.h"

@class LRRestyRequest;
@class LRRestyResponse;

extern NSString *const FATraktActivityNotificationSearch;
extern NSString *const FATraktActivityNotificationCheckAuth;
extern NSString *const FATraktActivityNotificationLists;

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
+ (NSString *)interfaceNameForRating:(FATraktRating)rating capitalized:(BOOL)capitalized;

extern NSString *const kFAKeychainKeyCredentials;

#pragma mark API
- (LRRestyRequest *)verifyCredentials:(void (^)(BOOL valid))block;
- (LRRestyRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))block;

- (LRRestyRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block onError:(void (^)(LRRestyResponse *response))error;

- (LRRestyRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (LRRestyRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block;

- (LRRestyRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))block;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))block;
- (LRRestyRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))block;

- (LRRestyRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block;
- (LRRestyRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))block;

- (LRRestyRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))block;
- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;
- (LRRestyRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))block;
- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))block;

- (LRRestyRequest *)allCustomListsCallback:(void (^)(NSArray *))block;
- (LRRestyRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))block;

- (LRRestyRequest *)rate:(FATraktContent *)content love:(NSString *)love callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error;
@end
