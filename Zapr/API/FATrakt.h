//
//  FATrakt.h
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FATraktConnection.h"
#import "FATraktConnectionResponse.h"
#import "FATraktRequest.h"

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
#import "FATraktCheckin.h"
#import "FATraktCheckinTimestamps.h"

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
- (FATraktRequest *)verifyCredentials:(void (^)(BOOL valid))callback;
- (FATraktRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark images
- (FATraktRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark movies
- (FATraktRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark shows
- (FATraktRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)seasonInfoForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark episodes
- (FATraktRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark watchlists
- (FATraktRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark libraries
- (FATraktRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark custom lists
- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeContent:(FATraktContent *)content fromCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)allCustomListsCallback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark content actions
- (FATraktRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRating)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)setContent:(FATraktContent *)content seenStatus:(BOOL)seen callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)checkIn:(FATraktContent *)content callback:(void (^)(FATraktCheckin *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
@end
