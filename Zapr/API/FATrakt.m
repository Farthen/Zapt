//
//  FATrakt.m
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import <JSONKit.h>
#import <LRResty.h>
#import <Security/Security.h>

#import "NSString+URLEncode.h"
#import "NSString+StringByAppendingSuffixToFilename.h"
#import "NSObject+PerformBlock.h"
#import "NSArray+Sorting.h"

#import "FAAppDelegate.h"

#import "FATraktCache.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FAStatusBarSpinnerController.h"
#import "FAActivityDispatch.h"

#import "FATraktConnection.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_WARN

NSString *const FATraktActivityNotificationSearch = @"FATraktActivityNotificationSearch";
NSString *const FATraktActivityNotificationCheckAuth = @"FATraktActivityNotificationCheckAuth";
NSString *const FATraktActivityNotificationLists = @"FATraktActivityNotificationLists";
NSString *const FATraktActivityNotificationDefault = @"FATraktActivityNotificationDefault";

@interface FATrakt ()
@property FATraktConnection *connection;

@property FATraktLastActivity *lastActivity;
@property NSMutableSet *changedLastActivityKeys;
@property BOOL fetchingLastActivity;
@end

@implementation FATrakt {
    LRRestyClient *_restyClient;
    LRRestyClient *_authRestyClient;
    FATraktCache *_cache;
    FAActivityDispatch *_activity;
    NSString *_traktBaseURL;
}

+ (FATrakt *)sharedInstance
{
    static dispatch_once_t once;
    static FATrakt *trakt;
    dispatch_once(&once, ^ { trakt = [[FATrakt alloc] init]; });
    return trakt;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.connection = [FATraktConnection sharedInstance];
        self.changedLastActivityKeys = [NSMutableSet set];
        self.fetchingLastActivity = NO;
        _cache = [FATraktCache sharedInstance];
        _activity = [FAActivityDispatch sharedInstance];
        [_activity registerForAllActivity:[FAStatusBarSpinnerController sharedInstance]];
    }
    return self;
}

+ (NSString *)nameForContentType:(FATraktContentType)type
{
    return [FATrakt nameForContentType:type withPlural:NO];
}

+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural
{
    NSString *name;
    if (type == FATraktContentTypeMovies) {
        name = @"movie";
    } else if (type == FATraktContentTypeShows) {
        name = @"show";
    } else if (type == FATraktContentTypeEpisodes) {
        name = @"episode";
    }
    if (plural) {
        name = [name stringByAppendingString:@"s"];
    }
    return name;
}

+ (NSString *)nameForLibraryType:(FATraktLibraryType)type
{
    NSString *name;
    if (type == FATraktLibraryTypeAll) {
        name = @"all";
    } else if (type == FATraktLibraryTypeCollection) {
        name = @"collection";
    } else if (type == FATraktLibraryTypeWatched) {
        name = @"watched";
    }
    return name;
}

+ (NSString *)watchlistNameForContentType:(FATraktContentType)type
{
    if (type == FATraktContentTypeMovies) {
        return @"movie";
    } else if (type == FATraktContentTypeShows) {
        return @"show";
    } else if (type == FATraktContentTypeEpisodes) {
        return @"show/episode";
    }
    return nil;
}

// call this with movie.rating for example
- (BOOL)activityHasOccuredForPath:(NSString *)path
{
    if (!self.lastActivity) {
        return YES;
    }
    NSSet *changedKeys = self.changedLastActivityKeys;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", path];
    NSSet *filteredSet = [changedKeys filteredSetUsingPredicate:predicate];
    // If the set has any object activity has occured
    return !!(filteredSet.anyObject);
}

- (BOOL)needsUpdateLastActivity
{
    if (self.lastActivity) {
        // 60 seconds seems like a good timeout, we don't want to stress the servers too hard...
        return self.lastActivity.fetchDate.timeIntervalSinceNow < -10;
    } else {
        return YES;
    }
}

- (void)checkAndUpdateLastActivityCallback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *response))error
{
    if ([self needsUpdateLastActivity] && !self.fetchingLastActivity) {
        self.fetchingLastActivity = YES;
        [self loadLastActivityCallback:^{
            self.fetchingLastActivity = NO;
            callback();
        } onError:^(FATraktConnectionResponse *response){
            self.fetchingLastActivity = NO;
            error(response);
        }];
    } else {
        callback();
    }
}

#pragma mark - API

- (NSMutableDictionary *)postDataContentTypeDictForContent:(FATraktContent *)content multiple:(BOOL)multiple
{
    NSDictionary *dict;
    if (content.contentType == FATraktContentTypeMovies) {
        FATraktMovie *movie = (FATraktMovie *)content;
        if (multiple) {
            dict = @{@"movies": @[@{@"imdb_id": movie.imdb_id, @"title": content.title, @"year": movie.year}]};
        } else {
            dict = @{@"imdb_id": movie.imdb_id, @"title": content.title, @"year": movie.year};
        }
    } else if (content.contentType == FATraktContentTypeShows) {
        FATraktShow *show = (FATraktShow *)content;
        if (multiple) {
            dict = @{@"shows": @[@{@"tvdb_id": show.tvdb_id, @"title": content.title, @"year": show.year}]};
        } else {
            dict = @{@"tvdb_id": show.tvdb_id, @"title": content.title, @"year": show.year};
        }
    } else if (content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        dict = @{@"imdb_id": episode.show.imdb_id, @"tvdb_id": episode.show.tvdb_id, @"title": content.title, @"year": episode.show.year, @"episodes": @[@{@"season": episode.season, @"episode": episode.episode}]};
    }
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    return mutableDict;
}

- (LRRestyRequest *)verifyCredentials:(void (^)(BOOL valid))callback
{
    DDLogController(@"Account test!");
    
    return [self.connection postAPI:@"account/test" payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(LRRestyResponse *response){
        NSDictionary *data = [[response asString] objectFromJSONString];
        NSString *statusResponse = [data objectForKey:@"status"];
        if ([statusResponse isEqualToString:@"success"]) {
            callback(YES);
        } else {
            callback(NO);
        }
    } onError:^(FATraktConnectionResponse *connectionResponse) {
        callback(NO);
    }];
}

- (LRRestyRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    FATraktAccountSettings *cachedSettings = [[[FATraktAccountSettings alloc] init] cachedVersion];
    if (cachedSettings) {
        callback(cachedSettings);
    }
    
    return [self.connection postAPI:@"account/settings" payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        FATraktAccountSettings *accountSettings = [[FATraktAccountSettings alloc] initWithJSONDict:data];
        [cachedSettings removeFromCache];
        [accountSettings commitToCache];
        callback(accountSettings);
    } onError:error];
}

- (LRRestyRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{    
    NSString *suffix;
    if ([url hasPrefix:@"http://trakt.us/images/poster"]) {
        DDLogController(@"Loading image of type poster");
        if (width <= 138) {
            suffix = @"-138";
        } else if (width <= 300) {
            suffix = @"-300";
        } else {
            suffix = @"";
        }
    } else if ([url hasPrefix:@"http://trakt.us/images/fanart"] && ![url isEqualToString:@"http://trakt.us/images/fanart-summary.jpg"]) {
        DDLogController(@"Loading image of type fanart");
        if (width <= 218) {
            suffix = @"-218";
        } else if (width <= 940) {
            suffix = @"-940";
        } else {
            suffix = @"";
        }
    } else {
        suffix = @"";
    }
    if (![url isEqualToString:@"http://trakt.us/images/poster-small.jpg"]) {
    } else {
        suffix = @"";
    }
    NSString *imageURL = [url stringByAppendingFilenameSuffix:suffix];
    DDLogController(@"Loading image with url \"%@\"", imageURL);
    
    if ([_cache.images objectForKey:imageURL]) {
        callback([_cache.images objectForKey:imageURL]);
        return nil;
    }
    
    return [self.connection getURL:imageURL withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        UIImage *image = [UIImage imageWithData:[response responseData]];
        [_cache.images setObject:image forKey:imageURL cost:response.responseData.length];
        callback(image);
    } onError:error];
}

- (LRRestyRequest *)loadLastActivityCallback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self.connection getAPI:@"user/lastactivity.json" withParameters:@[self.connection.apiUser] withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        FATraktLastActivity *lastActivity = [[FATraktLastActivity alloc] initWithJSONDict:data];
        lastActivity.fetchDate = [NSDate date];
        NSSet *changedActivities = [lastActivity changedPathsToActivity:self.lastActivity];
        [self.changedLastActivityKeys unionSet:changedActivities];
        self.lastActivity = lastActivity;
        callback();
    } onError:^(FATraktConnectionResponse *response){
        self.lastActivity = nil;
        self.changedLastActivityKeys = nil;
        error(response);
    }];
}

- (LRRestyRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for movies!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeMovies];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/movies.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(LRRestyResponse *response) {
        NSArray *data = [[response asString] objectFromJSONString];
        NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *movieDict in data) {
            FATraktMovie *movie = [[FATraktMovie alloc] initWithJSONDict:movieDict];
            [movies addObject:movie];
        }
        searchResult.results = movies;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (LRRestyRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about movie: \"%@\"", movie.description);
    if (!movie.imdb_id) {
        DDLogError(@"Trying to fetch information about movie without imdb_id");
    }
    
    FATraktMovie *cachedMovie = [_cache.movies objectForKey:movie.cacheKey];
    if (cachedMovie && cachedMovie.detailLevel >= FATraktDetailLevelDefault) {
        callback([_cache.movies objectForKey:movie.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
    }
    
    return [self.connection getAPI:@"movie/summary.json" withParameters:@[movie.imdb_id] withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        [movie mapObjectsInDict:data];
        
        movie.detailLevel = FATraktDetailLevelDefault;
        [movie commitToCache];
        callback(movie);
    } onError:error];
}

- (LRRestyRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for shows!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeShows];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/shows.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(LRRestyResponse *response) {
        NSArray *data = [[response asString] objectFromJSONString];
        NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *showDict in data) {
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
            [shows addObject:show];
        }
        searchResult.results = shows;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (LRRestyRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self detailsForShow:show detailLevel:FATraktDetailLevelDefault callback:callback onError:error];
}

- (LRRestyRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about show with title: \"%@\"", show.title);
    if (!show.tvdb_id) {
        DDLogError(@"Trying to fetch information about show without tbdb_id");
    }
    
    NSString *cacheKey = [show cacheKey];
    FATraktShow *cachedShow = [_cache.shows objectForKey:cacheKey];
    if (cachedShow && cachedShow.detailLevel >= FATraktDetailLevelDefault) {
        if (detailLevel == FATraktDetailLevelExtended) {
            if (cachedShow.detailLevel == FATraktDetailLevelExtended) {
                // Don't request extended information twice, this is definitely overkill
                // TODO: actually do this when episode data has changed (new episodes!)
                //detailLevel = FATraktDetailLevelDefault;
                callback(cachedShow);
                return nil;
            }
        } else {
            callback(cachedShow);
        }
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
        show = cachedShow;
    }
    
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:@[show.tvdb_id]];
    if (detailLevel == FATraktDetailLevelExtended) {
        [parameters addObject:@"extended"];
    }
    
    return [self.connection getAPI:@"show/summary.json" withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        [show mapObjectsInDict:data];
        
        if (detailLevel == FATraktDetailLevelExtended) {
            show.detailLevel = FATraktDetailLevelExtended;
        } else {
            show.detailLevel = MAX(show.detailLevel, FATraktDetailLevelDefault);
        }
        
        [show commitToCache];
        callback(show);
    } onError:error];
}

- (LRRestyRequest *)loadProgressDataWithTitle:(NSString *)title callback:(void (^)(NSArray *data))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // title can be tvdb-id or slug
    DDLogController(@"Getting progress data");
    
    return [self.connection getAPI:@"user/progress/watched.json" withParameters:@[self.connection.apiUser, title] withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        NSArray *data = [[response asString] objectFromJSONString];
        NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *show in data) {
            FATraktShowProgress *progress = [[FATraktShowProgress alloc] initWithJSONDict:show];
            [shows addObject:progress];
        }
        callback(shows);
    } onError:error];
}

- (LRRestyRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Getting progress for show: %@", show.title);
    return [self loadProgressDataWithTitle:show.tvdb_id callback:^(NSArray *data){
        FATraktShowProgress *progress = nil;
        if (data.count >= 1) {
            progress = data[0];
            progress.show = show;
            show.progress = progress;
        }
        callback(progress);
    } onError:error];
}

- (LRRestyRequest *)progressForAllShowsCallback:(void (^)(NSArray *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Getting progress for all shows");
    return [self loadProgressDataWithTitle:@"" callback:callback onError:error];
}

- (LRRestyRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for episodes!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeEpisodes];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/episodes.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(LRRestyResponse *response) {
        NSArray *data = [[response asString] objectFromJSONString];
        NSMutableArray *episodes = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *episodeOverviewDict in data) {
            NSDictionary *episodeDict = [episodeOverviewDict objectForKey:@"episode"];
            NSDictionary *showDict = [episodeOverviewDict objectForKey:@"show"];
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:show];
            [episodes addObject:episode];
        }
        searchResult.results = episodes;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (LRRestyRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about episode with title: \"%@\"", episode.title);
    if (!episode.show.tvdb_id) {
        DDLogController(@"Trying to fetch information about show without tvdb_id");
    }
    
    FATraktEpisode *cachedEpisode = [_cache.episodes objectForKey:episode.cacheKey];
    if (cachedEpisode && cachedEpisode.detailLevel >= FATraktDetailLevelDefault) {
        callback([_cache.episodes objectForKey:episode.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
    }
    
    return [self.connection getAPI:@"show/episode/summary.json" withParameters:@[episode.show.tvdb_id, episode.season.stringValue, episode.episode.stringValue] withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        [episode mapObjectsInSummaryDict:data];
        
        episode.detailLevel = FATraktDetailLevelDefault;
        [episode commitToCache];
        callback(episode);
    } onError:error];
}

- (LRRestyRequest *)loadDataForList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *key = nil;
    NSString *contentTypeName = [FATrakt nameForContentType:list.contentType];
    if (list.isWatchlist) {
        key = [NSString stringWithFormat:@"%@.watchlist", contentTypeName];
    } else if (list.isLibrary) {
        key = [NSString stringWithFormat:@"%@.collection", contentTypeName];
    }
    
    LRRestyRequest *(^actualRequest)(void) = ^LRRestyRequest *{
        FATraktContentType type = list.contentType;
        NSString *typeName = [FATrakt nameForContentType:type];
        
        if (key) {
            [self.changedLastActivityKeys removeObject:key];
        }
        
        return [self.connection getURL:list.url withActivityName:FATraktActivityNotificationLists onSuccess:^(LRRestyResponse *response) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *dictitem in data) {
                if (type == FATraktContentTypeEpisodes) {
                    FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:dictitem];
                    for (NSDictionary *episodeDict in show.episodes) {
                        FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:show];
                        episode.in_watchlist = YES;
                        [_cache.episodes setObject:episode forKey:episode.cacheKey];
                        
                        FATraktListItem *item = [[FATraktListItem alloc] init];
                        item.type = typeName;
                        item.episode = episode;
                        [items addObject:item];
                    }
                } else {
                    FATraktListItem *item = [[FATraktListItem alloc] init];
                    item.type = typeName;
                    [item setItem:dictitem];
                    [items addObject:item];
                }
            }
            list.items = items;
            
            list.shouldBeCached = YES;
            [list commitToCache];
            
            callback(list);
        } onError:^(FATraktConnectionResponse *response){
            // We need to add the key again because the request failed
            if (key) {
                [self.changedLastActivityKeys addObject:key];
            }
        }];
    };
    
    FATraktList *cachedList = [_cache.lists objectForKey:list.cacheKey];
    if (cachedList) {
        callback(cachedList);
        // FIXME: check if it fixes crashbug?
        //list = cachedList;
        
        // Check if there has been any more activity regarding this list type
        if (key) {
            [self checkAndUpdateLastActivityCallback:^{
                if ([self activityHasOccuredForPath:key]) {
                    actualRequest();
                } else {
                    // Do nothing. Doing nothing is great.
                }
            } onError:^(FATraktConnectionResponse *response) {
                // WELP get me outta here!
                error(response);
            }];
            return nil;
        }
    }
    
    return actualRequest();
}

- (LRRestyRequest *)allCustomListsCallback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // Load the cached versions first
    NSArray *cachedCustomLists = FATraktList.cachedCustomLists;
    if (cachedCustomLists.count > 0) {
        callback(cachedCustomLists);
    }
    
    return [self.connection getAPI:@"user/lists.json" withParameters:@[self.connection.apiUser] withActivityName:FATraktActivityNotificationLists onSuccess:^(LRRestyResponse *response) {
        NSArray *data = [[response asString] objectFromJSONString];
        NSMutableArray *lists = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *listData in data) {
            FATraktList *list = [[FATraktList alloc] initWithJSONDict:listData];
            list.isCustom = YES;
            list.detailLevel = FATraktDetailLevelMinimal;
            [lists addObject:list];
            [list commitToCache];
        }
        lists = [lists sortedArrayUsingKey:@"name" ascending:YES];
        callback(lists);
    } onError:error];
}

- (LRRestyRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // Load the cached list first
    FATraktList *cachedList = [FATraktList.backingCache objectForKey:list.cacheKey];
    if (cachedList) {
        callback(cachedList);
    }
    
    return [self.connection getAPI:@"user/list.json" withParameters:@[self.connection.apiUser, list.slug] withActivityName:FATraktActivityNotificationLists onSuccess:^(LRRestyResponse *response) {
        NSDictionary *data = [[response asString] objectFromJSONString];
        FATraktList *list = [[FATraktList alloc] initWithJSONDict:data];
        list.isCustom = YES;
        list.detailLevel = FATraktDetailLevelDefault;
        [list commitToCache];
        callback(list);
    } onError:error];
}

- (LRRestyRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // type can either be shows, episodes or movies
    NSString *watchlistName = [FATrakt nameForContentType:contentType withPlural:YES];
    NSString *url = [self.connection urlForAPI:[NSString stringWithFormat:@"user/watchlist/%@.json", watchlistName] withParameters:@[self.connection.apiUser]];
    
    FATraktList *list = [[FATraktList alloc] init];
    list.isWatchlist = YES;
    list.name = @"watchlist";
    list.url = url;
    list.contentType = contentType;
    
    return [self loadDataForList:list callback:callback onError:error];
}

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }

    // type can either be shows, episodes or movies
    NSString *libraryName = [FATrakt nameForContentType:contentType withPlural:YES];
    NSString *libraryTypeName = [FATrakt nameForLibraryType:libraryType];
    NSString *url;
    if (detailLevel == FATraktDetailLevelExtended) {
        url = [self.connection urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:@[self.connection.apiUser]];
    } else if (detailLevel == FATraktDetailLevelMinimal) {
        url = [self.connection urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:@[self.connection.apiUser]];
    } else {
        url = [self.connection urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:@[self.connection.apiUser]];
    }
    
    FATraktList *list = [[FATraktList alloc] init];
    list.isLibrary = YES;
    list.name = [NSString stringWithFormat:@"library"];
    list.url = url;
    list.contentType = contentType;
    list.libraryType = libraryType;
    
    return [self loadDataForList:list callback:callback onError:error];
}

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // TODO: Check if I really need the extended information
    return [self libraryForContentType:contentType libraryType:libraryType detailLevel:FATraktDetailLevelExtended callback:callback onError:error];
}

- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:YES callback:callback onError:error];
}

- (LRRestyRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:NO callback:callback onError:error];
}

- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *watchlistName = [FATrakt watchlistNameForContentType:content.contentType];
    NSString *api;
    if (add) {
        api = [NSString stringWithFormat:@"%@/watchlist", watchlistName];
    } else {
        api = [NSString stringWithFormat:@"%@/unwatchlist", watchlistName];
    }
    
    NSDictionary *payload = [self postDataContentTypeDictForContent:content multiple:YES];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        content.in_watchlist = add;
        callback();
    } onError:error];
}

- (LRRestyRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToLibrary:content add:YES callback:callback onError:error];
}

- (LRRestyRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToLibrary:content add:NO callback:callback onError:error];
}

- (LRRestyRequest *)addToLibrary:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *libraryName = [FATrakt watchlistNameForContentType:content.contentType];
    NSString *api;
    if (add) {
        api = [NSString stringWithFormat:@"%@/library", libraryName];
    } else {
        api = [NSString stringWithFormat:@"%@/unlibrary", libraryName];
    }
    
    NSDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        content.in_collection = add;
        callback();
    } onError:error];
}

- (LRRestyRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRating)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *contentType = [FATrakt nameForContentType:content.contentType withPlural:NO];
    NSString *api = [NSString stringWithFormat:@"rate/%@", contentType];
    
    NSString *ratingString = nil;
    
    if (simple) {
        if (rating == FATraktRatingLove) {
            ratingString = @"love";
        } else if (rating == FATraktRatingHate) {
            ratingString = @"hate";
        } else {
            ratingString = @"unrate";
        }
    } else {
        ratingString = [NSString stringWithFormat:@"%i", rating];
    }
    
    NSMutableDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO];
    
    [payload addEntriesFromDictionary:@{@"rating": ratingString}];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(LRRestyResponse *response) {
        if (simple) {
            content.rating = rating;
        } else {
            content.rating_advanced = rating;
        }
        [content commitToCache];
        callback();
    } onError:error];
}


@end
