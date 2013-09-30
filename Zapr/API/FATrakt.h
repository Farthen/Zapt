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
#import "FATraktCheckinResponse.h"

@class LRRestyRequest;
@class LRRestyResponse;

extern NSString *const FATraktActivityNotificationSearch;
extern NSString *const FATraktActivityNotificationCheckAuth;
extern NSString *const FATraktActivityNotificationLists;
extern NSString *const FATraktActivityNotificationCheckin;

@interface FATrakt : NSObject

+ (FATrakt *)sharedInstance;
+ (NSString *)nameForContentType:(FATraktContentType)type;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural;

#pragma mark - API
#pragma mark account
- (LRRestyRequest *)verifyCredentials:(void (^)(BOOL valid))callback;
- (LRRestyRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark images
- (LRRestyRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark movies
- (LRRestyRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark shows
- (LRRestyRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark episodes
- (LRRestyRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark watchlists
- (LRRestyRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark libraries
- (LRRestyRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark custom lists
- (LRRestyRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)removeContent:(FATraktContent *)content fromCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)allCustomListsCallback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark content actions
- (LRRestyRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRating)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)setContent:(FATraktContent *)content seenStatus:(BOOL)seen callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (LRRestyRequest *)checkIn:(FATraktContent *)content callback:(void (^)(FATraktCheckinResponse *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
@end
