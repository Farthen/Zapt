//
//  FATrakt.h
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FATraktConnection.h"

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
#import "FATraktLastActivity.h"

@class LRRestyRequest;
@class LRRestyResponse;

extern NSString *const FATraktActivityNotificationSearch;
extern NSString *const FATraktActivityNotificationCheckAuth;
extern NSString *const FATraktActivityNotificationLists;

@interface FATrakt : NSObject

+ (FATrakt *)sharedInstance;
+ (NSString *)nameForContentType:(FATraktContentType)type;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural;

#pragma mark API
- (LRRestyRequest *)verifyCredentials:(void (^)(BOOL valid))block;
- (LRRestyRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)allCustomListsCallback:(void (^)(NSArray *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))block onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRating)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
@end
