//
//  FATrakt.m
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import <Security/Security.h>

#import "FAAppDelegate.h"
#import "FAZapr.h"

#import "FATraktCache.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FAStatusBarSpinnerController.h"
#import "FAActivityDispatch.h"

#import "Misc.h"

#import "FATraktConnection.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_WARN

NSString *const FATraktActivityNotificationSearch = @"FATraktActivityNotificationSearch";
NSString *const FATraktActivityNotificationCheckAuth = @"FATraktActivityNotificationCheckAuth";
NSString *const FATraktActivityNotificationLists = @"FATraktActivityNotificationLists";
NSString *const FATraktActivityNotificationCheckin = @"FATraktActivityNotificationCheckin";
NSString *const FATraktActivityNotificationDefault = @"FATraktActivityNotificationDefault";

@interface FATrakt ()
@property FATraktConnection *connection;

@property FATraktLastActivity *lastActivity;
@property NSMutableSet *changedLastActivityKeys;
@property BOOL fetchingLastActivity;
@end

@implementation FATrakt {
    FATraktCache *_cache;
    FAActivityDispatch *_activity;
    NSString *_traktBaseURL;
}

+ (FATrakt *)sharedInstance
{
    static dispatch_once_t once;
    static FATrakt *trakt;
    dispatch_once(&once, ^{ trakt = [[FATrakt alloc] init]; });
    
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allCachesClearedNotification:) name:FATraktCacheClearedNotification object:[FATraktCache sharedInstance]];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (Class)classForContentType:(FATraktContentType)type
{
    if (type == FATraktContentTypeEpisodes) {
        return [FATraktEpisode class];
    } else if (type == FATraktContentTypeMovies) {
        return [FATraktMovie class];
    } else if (type == FATraktContentTypeShows) {
        return [FATraktShow class];
    } else if (type == FATraktContentTypeSeasons) {
        return [FATraktSeason class];
    }
    
    return NULL;
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

- (void)allCachesClearedNotification:(NSNotification *)notification
{
    // Invalidate last activity
    self.lastActivity = nil;
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
        } onError:^(FATraktConnectionResponse *response) {
            self.fetchingLastActivity = NO;
            error(response);
        }];
    } else {
        callback();
    }
}

#pragma mark - API

- (NSMutableDictionary *)postDataContentTypeDictForContent:(FATraktContent *)content multiple:(BOOL)multiple containsType:(BOOL)containsType
{
    NSDictionary *dict;
    
    if (content.contentType == FATraktContentTypeMovies) {
        FATraktMovie *movie = (FATraktMovie *)content;
        NSMutableDictionary *postDictInfo = [movie.postDictInfo mutableCopy];
        
        if (containsType) {
            [postDictInfo addEntriesFromDictionary:@{ @"type": @"movie" }];
            dict = postDictInfo;
        } else {
            if (multiple) {
                dict = @{ @"movies": @[postDictInfo] };
            } else {
                dict = postDictInfo;
            }
        }
    } else if (content.contentType == FATraktContentTypeShows) {
        FATraktShow *show = (FATraktShow *)content;
        NSMutableDictionary *postDictInfo = [show.postDictInfo mutableCopy];
        
        if (containsType) {
            [postDictInfo addEntriesFromDictionary:@{ @"type": @"show" }];
            dict = postDictInfo;
        } else {
            if (multiple) {
                dict = @{ @"shows": @[postDictInfo] };
            } else {
                dict = postDictInfo;
            }
        }
    } else if (content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        NSMutableDictionary *postDictInfo = [episode.postDictInfo mutableCopy];
        NSMutableDictionary *showPostDictInfo = [episode.show.postDictInfo mutableCopy];
        
        if (containsType) {
            [postDictInfo addEntriesFromDictionary:@{ @"type": @"episode" }];
            [postDictInfo addEntriesFromDictionary:showPostDictInfo];
            dict = postDictInfo;
        } else {
            if (multiple) {
                [showPostDictInfo addEntriesFromDictionary:@{ @"episodes": postDictInfo }];
                dict = showPostDictInfo;
            } else {
                [showPostDictInfo addEntriesFromDictionary:postDictInfo];
                dict = showPostDictInfo;
            }
        }
    }
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    return mutableDict;
}

- (FATraktRequest *)verifyCredentials:(void (^)(BOOL valid))callback
{
    DDLogController(@"Account test!");
    
    return [self.connection postAPI:@"account/test" payload:nil authenticated:NO withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        NSString *statusResponse = [data objectForKey:@"status"];
        
        if ([statusResponse isEqualToString:@"success"]) {
            self.connection.usernameAndPasswordValid = YES;
            callback(YES);
        } else {
            self.connection.usernameAndPasswordValid = NO;
            callback(NO);
        }
    } onError:^(FATraktConnectionResponse *connectionError) {
        callback(NO);
    }];
}

- (FATraktRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    FATraktAccountSettings *cachedSettings = [[[FATraktAccountSettings alloc] init] cachedVersion];
    
    if (cachedSettings) {
        callback(cachedSettings);
    }
    
    return [self.connection postAPI:@"account/settings" payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        FATraktAccountSettings *accountSettings = [[FATraktAccountSettings alloc] initWithJSONDict:data];
        
        if (accountSettings) {
            [cachedSettings removeFromCache];
            [accountSettings commitToCache];
            callback(accountSettings);
        } else {
            if (error) {
                error([FATraktConnectionResponse invalidDataResponse]);
            }
        }
    } onError:error];
}

- (FATraktRequest *)loadImageFromURL:(NSString *)url callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self loadImageFromURL:url withWidth:0 callback:callback onError:error];
}

- (FATraktRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *suffix = @"";
    
    if (width > 0) {
        if ([url hasPrefix:@"http://trakt.us/images/poster"]) {
            DDLogController(@"Loading image of type poster");
            
            if (width <= 138) {
                suffix = @"-138";
            } else if (width <= 300) {
                suffix = @"-300";
            }
        } else if ([url hasPrefix:@"http://trakt.us/images/fanart"] && ![url isEqualToString:@"http://trakt.us/images/fanart-summary.jpg"]) {
            DDLogController(@"Loading image of type fanart");
            
            if (width <= 218) {
                suffix = @"-218";
            } else if (width <= 940) {
                suffix = @"-940";
            }
        } else {
            suffix = @"";
        }
        
        if (![url isEqualToString:@"http://trakt.us/images/poster-small.jpg"]) {
        }
    }
    
    NSString *imageURL = [url stringByAppendingFilenameSuffix:suffix];
    DDLogController(@"Loading image with url \"%@\"", imageURL);
    
    if ([_cache.images objectForKey:imageURL]) {
        callback([_cache.images objectForKey:imageURL]);
        
        return nil;
    }
    
    return [self.connection getImageURL:imageURL withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        UIImage *image = [response imageData];
        [_cache.images setObject:image forKey:imageURL cost:image.sizeInBytes];
        callback(image);
    } onError:error];
}

- (FATraktRequest *)loadLastActivityCallback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self.connection getAPI:@"user/lastactivity.json" withParameters:@[self.connection.apiUser] withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        FATraktLastActivity *lastActivity = [[FATraktLastActivity alloc] initWithJSONDict:data];
        
        if (lastActivity) {
            lastActivity.fetchDate = [NSDate date];
            NSSet *changedActivities = [lastActivity changedPathsToActivity:self.lastActivity];
            [self.changedLastActivityKeys unionSet:changedActivities];
            self.lastActivity = lastActivity;
            callback();
        } else {
            self.lastActivity = nil;
            self.changedLastActivityKeys = nil;
            
            if (error) {
                error([FATraktConnectionResponse invalidDataResponse]);
            }
        }
    } onError:^(FATraktConnectionResponse *response) {
        self.lastActivity = nil;
        self.changedLastActivityKeys = nil;
        error(response);
    }];
}

- (FATraktRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for movies!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeMovies];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/movies.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary * movieDict in data) {
            FATraktMovie *movie = [[FATraktMovie alloc] initWithJSONDict:movieDict];
            
            if (movie) {
                [movies addObject:movie];
            }
        }
        
        searchResult.results = movies;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (FATraktRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about movie: \"%@\"", movie.description);
    
    FATraktMovie *cachedMovie = [FATraktMovie.backingCache objectForKey:movie.cacheKey];
    
    if (cachedMovie && cachedMovie.detailLevel >= FATraktDetailLevelDefault) {
        callback([FATraktMovie.backingCache objectForKey:movie.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
    }
    
    NSString *identifier = movie.urlIdentifier;
    
    if (identifier) {
        return [self.connection getAPI:@"movie/summary.json" withParameters:@[identifier] withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *data = response.jsonData;
            [movie mapObjectsInDict:data];
            
            movie.detailLevel = FATraktDetailLevelDefault;
            [movie commitToCache];
            callback(movie);
        } onError:error];
    } else {
        if (error) {
            error([FATraktConnectionResponse invalidRequestResponse]);
        }
        
        return nil;
    }
}

- (FATraktRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for shows!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeShows];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/shows.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary * showDict in data) {
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
            
            if (show) {
                [shows addObject:show];
            }
        }
        
        searchResult.results = shows;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (FATraktRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self detailsForShow:show detailLevel:FATraktDetailLevelDefault callback:callback onError:error];
}

- (FATraktRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about show with title: \"%@\"", show.title);
    
    NSString *cacheKey = [show cacheKey];
    FATraktShow *cachedShow = [FATraktShow.backingCache objectForKey:cacheKey];
    
    if (cachedShow && cachedShow.detailLevel >= FATraktDetailLevelDefault) {
        if (detailLevel == FATraktDetailLevelExtended) {
            if (cachedShow.detailLevel == FATraktDetailLevelExtended) {
                callback(cachedShow);
                
                // Don't request extended information twice within 5 minutes, this is definitely overkill
                if ([[NSDate date] timeIntervalSinceDate:cachedShow.creationDate] <= FATimeIntervalMinutes(5)) {
                    return nil;
                }
            }
        } else {
            callback(cachedShow);
        }
        
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
        show = cachedShow;
    }
    
    NSString *identifier = [show urlIdentifier];
    
    if (identifier) {
        NSMutableArray *parameters = [NSMutableArray arrayWithArray:@[identifier]];
        
        if (detailLevel == FATraktDetailLevelExtended) {
            [parameters addObject:@"extended"];
        }
        
        return [self.connection getAPI:@"show/summary.json" withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *data = response.jsonData;
            [show mapObjectsInDict:data];
            
            if (detailLevel == FATraktDetailLevelExtended) {
                show.detailLevel = FATraktDetailLevelExtended;
            } else {
                show.detailLevel = MAX(show.detailLevel, FATraktDetailLevelDefault);
            }
            
            [show commitToCache];
            callback(show);
        } onError:error];
    } else {
        if (error) {
            error([FATraktConnectionResponse invalidRequestResponse]);
        }
        
        return nil;
    }
}

- (FATraktRequest *)watchedProgressForShow:(FATraktShow *)show sortedBy:(FATraktSortingOption)sortingOption detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(NSArray *progessItems))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *api = @"user/progress/watched.json";
    
    if (!self.connection.apiUser) {
        return nil;
    }
    
    NSString *title;
    
    if (!show) {
        title = @"all";
    } else {
        title = show.urlIdentifier;
    }
    
    NSString *sort = @"title";
    
    if (sortingOption == FATraktSortingOptionRecentActivity) {
        sort = @"activity";
    } else if (sortingOption == FATraktSortingOptionMostCompleted) {
        sort = @"most-completed";
    } else if (sortingOption == FATraktSortingOptionLeastCompleted) {
        sort = @"least-completed";
    } else if (sortingOption == FATraktSortingOptionRecentlyAired) {
        sort = @"recently-aired";
    } else if (sortingOption == FATraktSortingOptionPreviouslyAired) {
        sort = @"previously-aired";
    }
    
    NSString *extended = @"";
    
    if (detailLevel == FATraktDetailLevelDefault) {
        extended = @"default";
    } else if (detailLevel == FATraktDetailLevelExtended) {
        extended = @"extended";
    }
    
    NSArray *parameters = @[self.connection.apiUser, title, sort, extended];
    
    return [self.connection getAPI:api withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        NSArray *data = response.jsonData;
        NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary *progressDict in data) {
            FATraktShowProgress *progress = [[FATraktShowProgress alloc] initWithJSONDict:progressDict];
            
            FATraktShow *show = progress.show;
            
            if (show) {
                [shows addObject:show];
            } else {
                DDLogError(@"There is no show after initializing FATraktShowProgress.");
            }
        }
        
        callback(shows);
        
    } onError:error];
}

- (FATraktRequest *)watchedProgressSortedBy:(FATraktSortingOption)sortingOption callback:(void (^)(NSArray *progressItems))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self watchedProgressForShow:nil sortedBy:sortingOption detailLevel:FATraktDetailLevelDefault callback:callback onError:error];
}

- (FATraktRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Getting progress for show: %@", show.title);
    
    return [self watchedProgressForShow:show sortedBy:FATraktSortingOptionTitle detailLevel:FATraktDetailLevelMinimal callback:^(NSArray *progressItems) {
        FATraktShow *show = nil;
        
        if (progressItems.count >= 1) {
            show = progressItems[0];
        }
        
        callback(show.progress);
    } onError:error];
}

- (FATraktRequest *)watchedProgressForAllShowsCallback:(void (^)(NSArray *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Getting progress for all shows");
    
    return [self watchedProgressForShow:nil sortedBy:FATraktSortingOptionRecentActivity detailLevel:FATraktDetailLevelDefault callback:callback onError:error];
}

- (FATraktRequest *)seasonInfoForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *api = @"show/seasons.json";
    NSString *info = [show urlIdentifier];
    
    if (info) {
        return [self.connection getAPI:api withParameters:@[info] forceAuthentication:NO withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
            NSArray *data = response.jsonData;
            
            for (NSDictionary * seasonDict in data) {
                FATraktSeason *season = [[FATraktSeason alloc] initWithJSONDict:seasonDict andShow:show];
                [show addSeason:season];
            }
            
            [show commitToCache];
            callback(show);
        } onError:error];
    }
    
    return nil;
}

- (FATraktRequest *)detailsForSeason:(FATraktSeason *)season callback:(void (^)(FATraktSeason *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *api = @"show/season.json";
    
    if (!season.show) {
        if (error) {
            error([FATraktConnectionResponse invalidRequestResponse]);
        }
        
        return nil;
    }
    
    NSArray *parameters = @[season.show.urlIdentifier, [NSString stringWithFormat:@"%i", season.seasonNumber.unsignedIntegerValue]];
    
    return [self.connection getAPI:api withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *episodes = [NSMutableArray arrayWithCapacity:data.count];
        
        for (NSDictionary * episodeDict in data) {
            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:season.show];
            [episodes addObject:episode];
            [season addEpisode:episode];
        }
        
        [season.show commitToCache];
        [season commitToCache];
        
        callback(season);
    } onError:error];
}

- (FATraktRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for episodes!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeEpisodes];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        callback(cachedResult);
    }
    
    return [self.connection getAPI:@"search/episodes.json" withParameters:@[query.URLEncodedString] withActivityName:FATraktActivityNotificationSearch onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *episodes = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary * episodeOverviewDict in data) {
            NSDictionary *episodeDict = [episodeOverviewDict objectForKey:@"episode"];
            NSDictionary *showDict = [episodeOverviewDict objectForKey:@"show"];
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:show];
            
            if (show && episode) {
                [episodes addObject:episode];
            }
        }
        
        searchResult.results = episodes;
        [searchResult commitToCache];
        callback(searchResult);
    } onError:error];
}

- (FATraktRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about episode with title: \"%@\"", episode.title);
    
    FATraktEpisode *cachedEpisode = [FATraktEpisode.backingCache objectForKey:episode.cacheKey];
    
    if (cachedEpisode && cachedEpisode.detailLevel >= FATraktDetailLevelDefault) {
        callback([FATraktEpisode.backingCache objectForKey:episode.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call callback twice. Make sure it can handle this.
    }
    
    NSString *identifier = episode.urlIdentifier;
    
    if (identifier) {
        return [self.connection getAPI:@"show/episode/summary.json" withParameters:@[identifier] withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *data = response.jsonData;
            [episode mapObjectsInSummaryDict:data];
            
            episode.detailLevel = FATraktDetailLevelExtended;
            [episode commitToCache];
            callback(episode);
        } onError:error];
    } else {
        if (error) {
            error([FATraktConnectionResponse invalidRequestResponse]);
        }
        
        return nil;
    }
}

- (FATraktRequest *)loadDataForList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *key = nil;
    NSString *contentTypeName = [FATrakt nameForContentType:list.contentType];
    
    if (list.isWatchlist) {
        key = [NSString stringWithFormat:@"%@.watchlist", contentTypeName];
    } else if (list.isLibrary) {
        key = [NSString stringWithFormat:@"%@.collection", contentTypeName];
    }
    
    FATraktRequest *(^actualRequest)(void) = ^FATraktRequest *{
        FATraktContentType type = list.contentType;
        
        if (key) {
            [self.changedLastActivityKeys removeObject:key];
        }
        
        return [self.connection getURL:list.url withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *data = response.jsonData;
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:data.count];
            
            for (NSDictionary * dictitem in data) {
                if (type == FATraktContentTypeEpisodes) {
                    FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:dictitem];
                    
                    if (show) {
                        for (NSDictionary * episodeDict in show.episodes) {
                            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:show];
                            episode.in_watchlist = YES;
                            [FATraktEpisode.backingCache setObject:episode forKey:episode.cacheKey];
                            
                            FATraktListItem *item = [[FATraktListItem alloc] init];
                            item.content = episode;
                            [items addObject:item];
                        }
                    }
                } else {
                    FATraktListItem *item = [[FATraktListItem alloc] init];
                    
                    if (item) {
                        Class cls = [FATrakt classForContentType:list.contentType];
                        item.content = [[cls alloc] initWithJSONDict:dictitem];
                        [items addObject:item];
                    }
                }
            }
            
            list.items = items;
            
            list.shouldBeCached = YES;
            [list commitToCache];
            
            callback(list);
        } onError:^(FATraktConnectionResponse *response) {
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
                if (error) {
                    error(response);
                }
            }];
            
            return nil;
        }
    }
    
    return actualRequest();
}

- (FATraktRequest *)allCustomListsCallback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // Load the cached versions first
    NSArray *cachedCustomLists = FATraktList.cachedCustomLists;
    
    if (cachedCustomLists.count > 0) {
        callback(cachedCustomLists);
    }
    
    return [self.connection getAPI:@"user/lists.json" withParameters:@[self.connection.apiUser] withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *lists = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary * listData in data) {
            FATraktList *list = [[FATraktList alloc] initWithJSONDict:listData];
            
            if (list) {
                list.isCustom = YES;
                list.detailLevel = FATraktDetailLevelMinimal;
                [lists addObject:list];
                [list commitToCache];
            }
        }
        
        lists = [lists sortedArrayUsingKey:@"name" ascending:YES];
        callback(lists);
    } onError:error];
}

- (FATraktRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // Load the cached list first
    FATraktList *cachedList = [FATraktList.backingCache objectForKey:list.cacheKey];
    
    if (cachedList) {
        callback(cachedList);
    }
    
    return [self.connection getAPI:@"user/list.json" withParameters:@[self.connection.apiUser, list.slug] withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        FATraktList *list = [[FATraktList alloc] initWithJSONDict:data];
        
        if (list) {
            list.isCustom = YES;
            list.detailLevel = FATraktDetailLevelDefault;
            [list commitToCache];
        }
        
        callback(list);
    } onError:error];
}

- (FATraktRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
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

- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
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

- (FATraktRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // TODO: Check if I really need the extended information
    return [self libraryForContentType:contentType libraryType:libraryType detailLevel:FATraktDetailLevelExtended callback:callback onError:error];
}

- (FATraktRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:YES callback:callback onError:error];
}

- (FATraktRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:NO callback:callback onError:error];
}

- (FATraktRequest *)addToWatchlist:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *watchlistName = [FATrakt watchlistNameForContentType:content.contentType];
    NSString *api;
    
    if (add) {
        api = [NSString stringWithFormat:@"%@/watchlist", watchlistName];
    } else {
        api = [NSString stringWithFormat:@"%@/unwatchlist", watchlistName];
    }
    
    NSDictionary *payload = [self postDataContentTypeDictForContent:content multiple:YES containsType:NO];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        content.in_watchlist = add;
        callback();
    } onError:error];
}

- (FATraktRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToLibrary:content add:YES callback:callback onError:error];
}

- (FATraktRequest *)removeFromLibrary:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToLibrary:content add:NO callback:callback onError:error];
}

- (FATraktRequest *)addToLibrary:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *libraryName = [FATrakt watchlistNameForContentType:content.contentType];
    NSString *api;
    
    if (add) {
        api = [NSString stringWithFormat:@"%@/library", libraryName];
    } else {
        api = [NSString stringWithFormat:@"%@/unlibrary", libraryName];
    }
    
    NSDictionary *payload;
    
    if (content.contentType == FATraktContentTypeMovies || content.contentType == FATraktContentTypeEpisodes) {
        payload = [self postDataContentTypeDictForContent:content multiple:YES containsType:NO];
    } else {
        payload = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
    }
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        content.in_collection = add;
        callback();
    } onError:error];
}

- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list add:(BOOL)add callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSArray *items = @[[self postDataContentTypeDictForContent:content multiple:NO containsType:YES]];
    NSString *api;
    
    if (add) {
        api = @"lists/items/add";
    } else {
        api = @"lists/items/delete";
    }
    
    NSString *slug = list.slug;
    NSDictionary *payload = @{ @"slug": slug, @"items": items };
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        if (add) {
            [list addContent:content];
        } else {
            [list removeContent:content];
        }
        
        [list commitToCache];
        callback();
    } onError:error];
}

- (FATraktRequest *)addContent:(FATraktContent *)content toCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addContent:content toCustomList:list add:YES callback:callback onError:error];
}

- (FATraktRequest *)removeContent:(FATraktContent *)content fromCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addContent:content toCustomList:list add:NO callback:callback onError:error];
}

- (FATraktRequest *)currentlyWatchingContentCallback:(void (^)(FATraktContent *))callback onError:(void (^)(FATraktConnectionResponse *))error
{
    NSString *api = @"user/watching.json";
    
    if (!self.connection.apiUser) {
        return nil;
    }
    
    NSArray *parameters = @[self.connection.apiUser];
    
    return [self.connection getAPI:api withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        if ([response.jsonData isKindOfClass:[NSArray class]]) {
            callback(nil);
            return;
        }
        
        NSDictionary *responseDict = response.jsonData;
        NSString *typeName = responseDict[@"type"];
        
        NSString *action = responseDict[@"action"];
        FATraktWatchingType watchingType = FATraktWatchingTypeNotWatching;
        
        if ([action isEqualToString:@"watching"]) {
            watchingType = FATraktWatchingTypeWatching;
        } else if ([action isEqualToString:@"checkin"]) {
            watchingType = FATraktWatchingTypeCheckin;
        }
        
        if (watchingType != FATraktWatchingTypeNotWatching &&
            typeName != nil &&
            responseDict != nil) {
            
            if ([typeName isEqualToString:@"movie"]) {
                FATraktMovie *movie = [[FATraktMovie alloc] initWithJSONDict:responseDict[@"movie"]];
                movie.detailLevel = FATraktDetailLevelMinimal;
                movie = [movie cachedVersion];
                [movie commitToCache];
                
                movie.watchingType = watchingType;
                
                callback(movie);
            } else if ([typeName isEqualToString:@"episode"]) {
                FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:responseDict[@"show"]];
                show.detailLevel = FATraktDetailLevelMinimal;
                show = [show cachedVersion];
                [show commitToCache];
                
                FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:responseDict[@"episode"] andShow:show];
                episode.detailLevel = FATraktDetailLevelMinimal;
                episode = [episode cachedVersion];
                episode.watchingType = watchingType;
                [episode commitToCache];
                
                callback(episode);
            } else {
                DDLogWarn(@"Unkown type name %@", typeName);
                
                if (error) {
                    error([FATraktConnectionResponse invalidDataResponse]);
                }
            }
        }
    } onError:^(FATraktConnectionResponse *connectionError) {
    }];
}

- (FATraktRequest *)recommendationsForContentType:(FATraktContentType)contentType genre:(NSString *)genre startYear:(NSInteger)startYear endYear:(NSInteger)endYear hideCollected:(BOOL)hideCollected hideWatchlisted:(BOOL)hideWatchlisted callback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *))error
{
    NSString *api;
    
    if (contentType == FATraktContentTypeShows) {
        api = @"recommendations/shows";
    } else if (contentType == FATraktContentTypeMovies) {
        api = @"recommendations/movies";
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"You can't have recommendations for anything other than shows and movies"];
        return nil;
    }
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    
    if (genre) {
        payload[@"genre"] = genre;
    }
    
    if (startYear > 0) {
        payload[@"start_year"] = [NSNumber numberWithInteger:startYear];
    }
    
    if (endYear > 0) {
        payload[@"end_year"] = [NSNumber numberWithInteger:endYear];
    }
    
    payload[@"hide_collected"] = [NSNumber numberWithBool:hideCollected];
    payload[@"hide_watchlisted"] = [NSNumber numberWithBool:hideWatchlisted];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        NSArray *recommendationData = response.jsonData;
        
        NSArray *recommendations = [recommendationData mapUsingBlock:^id(id obj, NSUInteger idx) {
            
            if (contentType == FATraktContentTypeShows) {
                return [[FATraktShow alloc] initWithJSONDict:obj];
            } else {
                return [[FATraktMovie alloc] initWithJSONDict:obj];
            }
        }];
        
        callback(recommendations);
    } onError:nil];
}

- (FATraktRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRating)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
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
    
    NSMutableDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
    
    [payload addEntriesFromDictionary:@{ @"rating": ratingString }];
    
    FATraktRating oldRating = content.rating;
    
    if (simple) {
        content.rating = rating;
    } else {
        content.rating_advanced = rating;
    }
    
    [content commitToCache];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        callback();
    } onError:^(FATraktConnectionResponse *connectionError) {
        content.rating = oldRating;
        
        if (error) {
            error(connectionError);
        }
    }];
}

- (FATraktRequest *)setContent:(FATraktContent *)content seenStatus:(BOOL)seen callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *api;
    NSDictionary *postData;
    
    if (content.contentType == FATraktContentTypeMovies) {
        if (seen) {
            api = @"movie/seen";
        } else {
            api = @"movie/unseen";
        }
        
        postData = [self postDataContentTypeDictForContent:content multiple:YES containsType:NO];
    } else if (content.contentType == FATraktContentTypeShows) {
        if (seen) {
            api = @"show/seen";
            postData = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
        } else {
            // There is no show/unseen API
            FATraktConnectionResponse *response = [[FATraktConnectionResponse alloc] init];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            error(response);
        }
    } else if (content.contentType == FATraktContentTypeEpisodes) {
        if (seen) {
            api = @"show/episode/seen";
        } else {
            api = @"show/episode/unseen";
        }
        
        postData = [self postDataContentTypeDictForContent:content multiple:YES containsType:NO];
    }
    
    return [self.connection postAPI:api payload:postData authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        if (content.contentType == FATraktContentTypeMovies) {
            FATraktMovie *movie = (FATraktMovie *)content;
            movie.watched = seen;
        } else if (content.contentType == FATraktContentTypeEpisodes) {
            FATraktEpisode *episode = (FATraktEpisode *)content;
            episode.watched = seen;
        } else if (content.contentType == FATraktContentTypeShows) {
            FATraktShow *show = (FATraktShow *)content;
            
            if (!show.progress) {
                show.progress = [[FATraktShowProgress alloc] init];
            } else {
                show.progress.left = 0;
                show.progress.completed = show.progress.aired;
                show.progress.percentage = @100;
            }
        }
        
        callback();
    } onError:error];
}

- (FATraktRequest *)checkIn:(FATraktContent *)content callback:(void (^)(FATraktCheckin *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (content && (content.contentType == FATraktContentTypeMovies ||
                    content.contentType == FATraktContentTypeEpisodes)) {
        NSMutableDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
        [payload setObject:[FAZapr versionNumberString] forKey:@"app_version"];
        [payload setObject:[FAZapr buildString] forKey:@"app_date"];
        
        NSString *api;
        
        if (content.contentType == FATraktContentTypeMovies) {
            api = @"movie/checkin";
        } else {
            api = @"show/checkin";
        }
        
        return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationCheckin onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *responseDict = response.jsonData;
            
            if (responseDict) {
                FATraktCheckin *checkinResponse = [[FATraktCheckin alloc] initWithJSONDict:responseDict];
                
                if (checkinResponse) {
                    checkinResponse.content = content;
                    callback(checkinResponse);
                } else if (error) {
                    error([FATraktConnectionResponse invalidDataResponse]);
                }
            } else {
                if (error) {
                    error([FATraktConnectionResponse invalidDataResponse]);
                }
            }
        } onError:error];
    } else {
        if (error) {
            error([FATraktConnectionResponse invalidRequestResponse]);
        }
        
        return nil;
    }
}

- (FATraktRequest *)cancelCheckInForContentType:(FATraktContentType)contentType callback:(void (^)(FATraktStatus))callback
{
    NSString *api = nil;
    
    if (contentType == FATraktContentTypeEpisodes) {
        api = @"show/cancelcheckin";
    } else if (contentType == FATraktContentTypeMovies) {
        api = @"movie/cancelcheckin";
    }
    
    if (api) {
        return [self.connection postAPI:api payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckin onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *responseDict = response.jsonData;
            NSString *status = [responseDict objectForKey:@"status"];
            FATraktStatus traktStatus = FATraktStatusFailed;
            
            if (status && [status isEqualToString:@"success"]) {
                traktStatus = FATraktStatusSuccess;
            }
            
            callback(traktStatus);
        } onError:^(FATraktConnectionResponse *connectionError) {
            callback(FATraktStatusFailed);
        }];
    } else {
        callback(FATraktStatusFailed);
        
        return nil;
    }
}

@end
