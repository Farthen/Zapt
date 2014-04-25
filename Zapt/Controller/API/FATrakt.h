//
//  FATrakt.h
//  Zapt
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FATraktConnection.h"
#import "FATraktConnectionResponse.h"
#import "FATraktRequest.h"

#import "FATraktDatatype.h"
#import "FATraktCachedDatatype.h"
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
#import "FATraktRating.h"
#import "FATraktCalendar.h"
#import "FATraktCalendarItem.h"

extern NSString *const FATraktActivityNotificationSearch;
extern NSString *const FATraktActivityNotificationCheckAuth;
extern NSString *const FATraktActivityNotificationLists;
extern NSString *const FATraktActivityNotificationCheckin;

@interface FATrakt : NSObject

+ (FATrakt *)sharedInstance;
+ (NSString *)nameForContentType:(FATraktContentType)type;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural;

#pragma mark - API
#pragma mark Images
// This loads the image in the cache and it will stay there for some time. You can run this to ensure the image is in the
// fast memory cache
- (FATraktRequest *)loadImageFromURL:(NSString *)url callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Account
- (FATraktRequest *)verifyCredentials:(void (^)(BOOL valid))callback;
- (FATraktRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark User
- (FATraktRequest *)currentlyWatchingContentCallback:(void (^)(FATraktContent *content))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)recommendationsForContentType:(FATraktContentType)contentType genre:(NSString *)genre startYear:(NSInteger)startYear endYear:(NSInteger)endYear hideCollected:(BOOL)hideCollected hideWatchlisted:(BOOL)hideWatchlisted callback:(void (^)(NSArray *recommendations))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)calendarFromDate:(NSDate *)fromDate dayCount:(NSUInteger)dayCount callback:(void (^)(FATraktCalendar *calendar))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark - Movies
- (FATraktRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *movie))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark - Shows
- (FATraktRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *show))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *show))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForShows:(NSArray *)shows detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(NSArray *shows))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Progress
- (FATraktRequest *)watchedProgressForShow:(FATraktShow *)show sortedBy:(FATraktSortingOption)sortingOption detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(NSArray *progressItems))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)watchedProgressSortedBy:(FATraktSortingOption)sortingOption callback:(void (^)(NSArray *progessItems))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)watchedProgressForAllShowsCallback:(void (^)(NSArray *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Seasons
- (FATraktRequest *)seasonInfoForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *show))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForSeason:(FATraktSeason *)season callback:(void (^)(FATraktSeason *season))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Episodes
- (FATraktRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *episode))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark - content actions
- (FATraktRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRatingScore)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)setContent:(id)content seenStatus:(BOOL)seen callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)checkIn:(FATraktContent *)content callback:(void (^)(FATraktCheckin *checkin))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)cancelCheckInForContentType:(FATraktContentType)contentType callback:(void (^)(FATraktStatus status))callback;

#pragma mark - Watchlists
- (FATraktRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *watchlist))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Libraries
- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *library))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *library))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

#pragma mark Custom lists
- (FATraktRequest *)allCustomListsCallback:(void (^)(NSArray *customLists))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *list))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeContent:(FATraktContent *)content fromCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (FATraktRequest *)addNewCustomListWithName:(NSString *)name description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)editCustomListWithSlug:(NSString *)slug newName:(NSString *)newName description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)editCustomList:(FATraktList *)list newName:(NSString *)newName description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (FATraktRequest *)removeCustomListWithSlug:(NSString *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error;
@end
