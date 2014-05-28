//
//  FATrakt.m
//  Zapt
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import <Security/Security.h>

#import "FAAppDelegate.h"
#import "FAZapt.h"

#import "FATraktCache.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FAStatusBarSpinnerController.h"
#import "FAActivityDispatch.h"
#import "FATraktConnectionResponse.h"

#import "Misc.h"

#import "FATraktConnection.h"

NSString *const FATraktActivityNotificationSearch = @"FATraktActivityNotificationSearch";
NSString *const FATraktActivityNotificationCheckAuth = @"FATraktActivityNotificationCheckAuth";
NSString *const FATraktActivityNotificationLists = @"FATraktActivityNotificationLists";
NSString *const FATraktActivityNotificationCheckin = @"FATraktActivityNotificationCheckin";
NSString *const FATraktActivityNotificationDefault = @"FATraktActivityNotificationDefault";

#define FATraktCallbackCall(x) \
    if ([NSThread isMainThread]) { \
        x; \
    } else \
    dispatch_async(dispatch_get_main_queue(), ^{ \
        x; \
    });

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
        // 0.5 seconds seems like a good timeout, we need current data
        return self.lastActivity.fetchDate.timeIntervalSinceNow < -0.5;
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
            FATraktCallbackCall(callback());
        } onError:^(FATraktConnectionResponse *response) {
            self.fetchingLastActivity = NO;
            FATraktCallbackCall(error(response));;
        }];
    } else {
        FATraktCallbackCall(callback());;
    }
}


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
                [showPostDictInfo addEntriesFromDictionary:@{ @"episodes": @[postDictInfo] }];
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

#pragma mark - API
#pragma mark Images


- (FATraktRequest *)loadImageFromURL:(NSString *)url callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self loadImageFromURL:url withWidth:0 callback:callback onError:error];
}

- (FATraktRequest *)loadImageFromURL:(NSString *)urlString withWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *imageURL = [FATraktImageList imageURLWithURL:urlString forWidth:width];
    
    DDLogController(@"Loading image with url \"%@\"", imageURL);
    
    FATraktRequest *imageRequest = [FATraktRequest requestWithActivityName:FATraktActivityNotificationDefault];
    
    // First check the cache. Make this nonblocking because blocking I/O in main thread
    // is generally considered being not the greatest thing in the world
    [_cache.images objectForKey:imageURL block:^(TMCache *cache, NSString *key, id object) {
        NSData *imageData = object;
        
        if (imageData) {
            FATraktCallbackCall(callback([UIImage imageWithData:imageData]));
        } else {
            
            // We don't have anything in the cache. We need to get it from the internet
            [self.connection getImageURL:imageURL withRequest:imageRequest onSuccess:^(FATraktConnectionResponse *response) {
                NSData *imageData = [response rawResponseData];
                UIImage *image = [UIImage imageWithData:imageData];
                [_cache.images setObject:imageData forKey:imageURL block:nil];
                FATraktCallbackCall(callback(image));
            } onError:error];
        }
    }];
    
    return imageRequest;
}

#pragma mark Account

- (FATraktRequest *)verifyCredentials:(void (^)(BOOL valid))callback
{
    DDLogController(@"Account test!");
    
    return [self.connection postAPI:@"account/test" payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        NSString *statusResponse = [data objectForKey:@"status"];
        
        if ([statusResponse isEqualToString:@"success"]) {
            self.connection.usernameAndPasswordValid = YES;
            FATraktCallbackCall(callback(YES));
        } else {
            self.connection.usernameAndPasswordValid = NO;
            FATraktCallbackCall(callback(NO));
        }
    } onError:^(FATraktConnectionResponse *connectionError) {
        if (connectionError.responseType & FATraktConnectionResponseTypeInvalidCredentials)
        {
            FATraktCallbackCall(callback(NO));
        }
    }];
}

- (FATraktRequest *)accountSettings:(void (^)(FATraktAccountSettings *settings))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    FATraktAccountSettings *cachedSettings = [[[FATraktAccountSettings alloc] init] cachedVersion];
    
    if (cachedSettings) {
        FATraktCallbackCall(callback(cachedSettings));
    }
    
    return [self.connection postAPI:@"account/settings" payload:nil authenticated:YES withActivityName:FATraktActivityNotificationCheckAuth onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        FATraktAccountSettings *accountSettings = [[FATraktAccountSettings alloc] initWithJSONDict:data];
        
        if (accountSettings) {
            [cachedSettings removeFromCache];
            [accountSettings commitToCache];
            FATraktCallbackCall(callback(accountSettings));
        } else {
            if (error) {
                FATraktCallbackCall(error([FATraktConnectionResponse invalidDataResponse]));
            }
        }
    } onError:error];
}

#pragma mark User
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
            FATraktCallbackCall(callback());
        } else {
            self.lastActivity = nil;
            self.changedLastActivityKeys = nil;
            
            if (error) {
                FATraktCallbackCall(error([FATraktConnectionResponse invalidDataResponse]));
            }
        }
    } onError:^(FATraktConnectionResponse *response) {
        self.lastActivity = nil;
        self.changedLastActivityKeys = nil;
        error(response);
    }];
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
            FATraktCallbackCall(callback(nil));
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
                
                FATraktCallbackCall(callback(movie));
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
                
                FATraktCallbackCall(callback(episode));
            } else {
                DDLogWarn(@"Unkown type name %@", typeName);
                
                if (error) {
                    FATraktCallbackCall(error([FATraktConnectionResponse invalidDataResponse]));
                }
            }
        }
    } onError:error];
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
        
        FATraktCallbackCall(callback(recommendations));
    } onError:nil];
}

- (FATraktRequest *)calendarFromDate:(NSDate *)fromDate dayCount:(NSUInteger)dayCount callback:(void (^)(FATraktCalendar *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    static NSDateFormatter *traktDateFormatter = nil;
    if (!traktDateFormatter) {
        traktDateFormatter = [[NSDateFormatter alloc] init];
        traktDateFormatter.dateFormat = @"yyyyMMdd";
    }
    
    FATraktCalendar *cachedCalendar = [FATraktCalendar cachedCalendar];
    if (cachedCalendar && [cachedCalendar.fromDate isEqualToDate:fromDate] && cachedCalendar.dayCount == dayCount) {
        FATraktCallbackCall(callback(cachedCalendar));
    }
    
    NSString *fromDateString = [traktDateFormatter stringFromDate:fromDate];
    NSString *dayCountString = [NSString stringWithFormat:@"%lu", (unsigned long)dayCount];
    
    if (fromDateString && dayCountString) {
        return [self.connection getAPI:@"user/calendar/shows.json" withParameters:@[self.connection.apiUser, fromDateString, dayCountString] forceAuthentication:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
            
            FATraktCalendar *calendar = [[FATraktCalendar alloc] initWithJSONArray:response.jsonData];
            calendar.fromDate = fromDate;
            calendar.dayCount = dayCount;
            
            FATraktCallbackCall(callback(calendar));
            
        } onError:error];
    }
    
    return nil;
}

#pragma mark - Movies

- (FATraktRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for movies!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeMovies];
    
    FATraktRequest *request = [FATraktRequest requestWithActivityName:FATraktActivityNotificationSearch];
    [_cache.searches objectForKey:searchResult.cacheKey block:^(TMCache *cache, NSString *key, id object) {
        FATraktSearchResult *cachedResult = object;
        
        if (cachedResult) {
            DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
            FATraktCallbackCall(callback(cachedResult));
        }
        
        [self.connection getAPI:@"search/movies.json" withParameters:@[query.URLEncodedString] withRequest:request onSuccess:^(FATraktConnectionResponse *response) {
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
            FATraktCallbackCall(callback(searchResult));
        } onError:error];
    }];
    
    return request;
}

- (FATraktRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about movie: \"%@\"", movie.description);
    
    FATraktMovie *cachedMovie = [FATraktMovie.backingCache objectForKey:movie.cacheKey];
    
    if (cachedMovie && cachedMovie.detailLevel >= FATraktDetailLevelDefault) {
        FATraktCallbackCall(callback([FATraktMovie.backingCache objectForKey:movie.cacheKey]));
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
            FATraktCallbackCall(callback(movie));
        } onError:error];
    } else {
        if (error) {
            FATraktCallbackCall(error([FATraktConnectionResponse invalidRequestResponse]));
        }
        
        return nil;
    }
}

#pragma mark - Shows

- (FATraktRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for shows!");
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeShows];
    FATraktRequest *request = [FATraktRequest requestWithActivityName:FATraktActivityNotificationSearch];
    
    [_cache.searches objectForKey:searchResult.cacheKey block:^(TMCache *cache, NSString *key, id object) {
        FATraktSearchResult *cachedResult = object;
        
        if (cachedResult) {
            DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
            FATraktCallbackCall(callback(cachedResult));
        }
        
        [self.connection getAPI:@"search/shows.json" withParameters:@[query.URLEncodedString] withRequest:request onSuccess:^(FATraktConnectionResponse *response) {
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
            FATraktCallbackCall(callback(searchResult));
        } onError:error];
    }];
    
    return request;
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
                FATraktCallbackCall(callback(cachedShow));
                
                // Don't request extended information twice within 5 minutes, this is definitely overkill
                if ([[NSDate date] timeIntervalSinceDate:cachedShow.creationDate] <= FATimeIntervalMinutes(5)) {
                    detailLevel = FATraktDetailLevelDefault;
                }
            }
        } else {
            FATraktCallbackCall(callback(cachedShow));
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
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:response.jsonData];
            
            if (detailLevel == FATraktDetailLevelExtended) {
                show.detailLevel = FATraktDetailLevelExtended;
                show.hasEpisodeCounts = YES;
            } else {
                show.detailLevel = MAX(show.detailLevel, FATraktDetailLevelDefault);
            }
            
            [show commitToCache];
            FATraktCallbackCall(callback(show));
        } onError:error];
    } else {
        if (error) {
            FATraktCallbackCall(error([FATraktConnectionResponse invalidRequestResponse]));
        }
        
        return nil;
    }
}

- (FATraktRequest *)detailsForShows:(NSArray *)shows detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSMutableArray *parameters = [NSMutableArray array];
    NSMutableString *showList = [NSMutableString stringWithString:@""];
    
    [shows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FATraktShow *show = obj;
        [showList appendString:show.urlIdentifier];
        
        if (idx < shows.count - 1) {
            [showList appendString:@","];
        }
    }];
    
    [parameters addObject:showList];
    
    if (detailLevel == FATraktDetailLevelExtended) {
        [parameters addObject:@"full"];
    } else if (detailLevel == FATraktDetailLevelDefault) {
        [parameters addObject:@"normal"];
    }
    
    return [self.connection getAPI:@"show/summaries.json" withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        NSArray *showArray = [response.jsonData mapUsingBlock:^id(id obj, NSUInteger idx) {
            FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:obj];
            [show commitToCache];
            return show;
        }];
        
        FATraktCallbackCall(callback(showArray));
    } onError:error];
}

#pragma mark Progress

- (FATraktRequest *)watchedProgressForShow:(FATraktShow *)show sortedBy:(FATraktSortingOption)sortingOption detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(NSArray *progressItems))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
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
        extended = @"normal";
    } else if (detailLevel == FATraktDetailLevelExtended) {
        extended = @"full";
    }
    
    NSArray *parameters = @[self.connection.apiUser, title, sort, extended];
    
    return [self.connection getAPI:api withParameters:parameters withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        NSArray *data = response.jsonData;
        NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary *progressDict in data) {
            FATraktShowProgress *progress = [[FATraktShowProgress alloc] initWithJSONDict:progressDict];
            
            FATraktShow *show = progress.show;
            show.progress = progress;
            
            if (show) {
                [shows addObject:show];
            } else {
                DDLogError(@"There is no show after initializing FATraktShowProgress.");
            }
        }
        
        FATraktCallbackCall(callback(shows));
        
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
        
        FATraktCallbackCall(callback(show.progress));
    } onError:error];
}

- (FATraktRequest *)watchedProgressForAllShowsCallback:(void (^)(NSArray *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Getting progress for all shows");
    
    return [self watchedProgressForShow:nil sortedBy:FATraktSortingOptionRecentActivity detailLevel:FATraktDetailLevelDefault callback:callback onError:error];
}

#pragma mark Seasons

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
            
            show.hasEpisodeCounts = YES;
            
            [show commitToCache];
            FATraktCallbackCall(callback(show));
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
    
    NSArray *parameters = @[season.show.urlIdentifier, [NSString stringWithFormat:@"%ld", (long)season.seasonNumber.unsignedIntegerValue]];
    
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
        
        FATraktCallbackCall(callback(season));
    } onError:error];
}

#pragma mark Episodes

- (FATraktRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult *result))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Searching for episodes!");
    
    FATraktRequest *request = [FATraktRequest requestWithActivityName:FATraktActivityNotificationSearch];
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeEpisodes];
    [_cache.searches objectForKey:searchResult.cacheKey block:^(TMCache *cache, NSString *key, id object) {
        if (object) {
            FATraktSearchResult *cachedResult = object;
            
            DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
            FATraktCallbackCall(callback(object));
        }
        
        [self.connection getAPI:@"search/episodes.json" withParameters:@[query.URLEncodedString] withRequest:request onSuccess:^(FATraktConnectionResponse *response) {
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
            FATraktCallbackCall(callback(searchResult));
        } onError:error];
    }];
    
    return request;
}

- (FATraktRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    DDLogController(@"Fetching all information about episode with title: \"%@\"", episode.title);
    
    FATraktEpisode *cachedEpisode = [FATraktEpisode.backingCache objectForKey:episode.cacheKey];
    
    if (cachedEpisode && cachedEpisode.detailLevel >= FATraktDetailLevelDefault) {
        FATraktCallbackCall(callback([FATraktEpisode.backingCache objectForKey:episode.cacheKey]));
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
            FATraktCallbackCall(callback(episode));
        } onError:error];
    } else {
        if (error) {
            FATraktCallbackCall(error([FATraktConnectionResponse invalidRequestResponse]));
        }
        
        return nil;
    }
}

#pragma mark - content actions

- (FATraktRequest *)rate:(FATraktContent *)content simple:(BOOL)simple rating:(FATraktRatingScore)rating callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
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
        ratingString = [NSString stringWithFormat:@"%ld", (long)rating];
    }
    
    NSMutableDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
    
    [payload addEntriesFromDictionary:@{ @"rating": ratingString }];
    
    FATraktRating *oldRating = content.rating;
    
    if (simple) {
        oldRating.simpleRating = rating;
    } else {
        oldRating.advancedRating = rating;
    }
    
    [content commitToCache];
    
    return [self.connection postAPI:api payload:payload authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        content.rating = [[FATraktRating alloc] init];
        content.rating.simpleRating = rating;
        content.rating.advancedRating = rating;
        
        [content updateTimestamp];
        
        FATraktCallbackCall(callback());
    } onError:^(FATraktConnectionResponse *connectionError) {
        content.rating = oldRating;
        
        if (error) {
            FATraktCallbackCall(error(connectionError));
        }
    }];
}

- (FATraktRequest *)setContent:(id)idContent seenStatus:(BOOL)seen callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *api;
    NSDictionary *postData;
    
    if ([idContent isKindOfClass:[FATraktSeason class]]) {
        FATraktSeason *season = idContent;
        
        if (seen) {
            api = @"show/season/seen";
            postData = season.postDictInfo;
        } else {
            if (error) {
                FATraktCallbackCall(error([FATraktConnectionResponse invalidRequestResponse]));
            }
            
            return nil;
        }
    }
    
    if ([idContent isKindOfClass:[FATraktContent class]]) {
        FATraktContent *content = idContent;
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
                FATraktCallbackCall(error(response));
            }
        } else if (content.contentType == FATraktContentTypeEpisodes) {
            if (seen) {
                api = @"show/episode/seen";
            } else {
                api = @"show/episode/unseen";
            }
            
            postData = [self postDataContentTypeDictForContent:content multiple:YES containsType:NO];
        }
    }
    
    
    return [self.connection postAPI:api payload:postData authenticated:YES withActivityName:FATraktActivityNotificationDefault onSuccess:^(FATraktConnectionResponse *response) {
        
        if ([idContent isKindOfClass:[FATraktSeason class]]) {
            FATraktSeason *season = idContent;
            
            for (FATraktEpisode *episode in season.episodes) {
                episode.watched = seen;
            }
        }
        
        if ([idContent isKindOfClass:[FATraktContent class]]) {
            FATraktContent *content = idContent;
            
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
        }
        
        
        FATraktCallbackCall(callback());
    } onError:error];
}

- (FATraktRequest *)checkIn:(FATraktContent *)content callback:(void (^)(FATraktCheckin *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (content && (content.contentType == FATraktContentTypeMovies ||
                    content.contentType == FATraktContentTypeEpisodes)) {
        NSMutableDictionary *payload = [self postDataContentTypeDictForContent:content multiple:NO containsType:NO];
        [payload setObject:[FAZapt versionNumberString] forKey:@"app_version"];
        [payload setObject:[FAZapt buildString] forKey:@"app_date"];
        
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
                    FATraktCallbackCall(callback(checkinResponse));
                } else if (error) {
                    FATraktCallbackCall(error([FATraktConnectionResponse invalidDataResponse]));
                }
            } else {
                if (error) {
                    FATraktCallbackCall(error([FATraktConnectionResponse invalidDataResponse]));
                }
            }
        } onError:error];
    } else {
        if (error) {
            FATraktCallbackCall(error([FATraktConnectionResponse invalidRequestResponse]));
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
            
            FATraktCallbackCall(callback(traktStatus));
        } onError:^(FATraktConnectionResponse *connectionError) {
            FATraktCallbackCall(callback(FATraktStatusFailed));
        }];
    } else {
        FATraktCallbackCall(callback(FATraktStatusFailed));
        
        return nil;
    }
}

#pragma mark - Lists

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
        
        FATraktRequest *request = [FATraktRequest requestWithActivityName:FATraktActivityNotificationLists];
        
        [self.connection getURL:list.url withRequest:request onSuccess:^(FATraktConnectionResponse *response) {
            NSDictionary *data = response.jsonData;
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:data.count];
            
            for (NSDictionary * dictitem in data) {
                if (type == FATraktContentTypeEpisodes) {
                    FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:dictitem];
                    
                    if (show) {
                        for (NSDictionary * episodeDict in show.episodes) {
                            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:show];
                            episode.in_watchlist = [NSNumber numberWithBool:YES];
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
            
            FATraktCallbackCall(callback(list));
        } onError:^(FATraktConnectionResponse *response) {
            // We need to add the key again because the request failed
            if (key) {
                [self.changedLastActivityKeys addObject:key];
            }
        }];
        
        return request;
    };
    
    FATraktList *cachedList = [_cache.lists objectForKey:list.cacheKey];
    
    if (cachedList) {
        FATraktCallbackCall(callback(cachedList));
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

#pragma mark Watchlists

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
        
        content.in_watchlist = [NSNumber numberWithBool:add];
        [content updateTimestamp];
        
        FATraktCallbackCall(callback());
    } onError:error];
}

- (FATraktRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:YES callback:callback onError:error];
}

- (FATraktRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self addToWatchlist:content add:NO callback:callback onError:error];
}

#pragma mark Libraries

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
        
        content.in_collection = [NSNumber numberWithBool:add];
        [content updateTimestamp];
        
        FATraktCallbackCall(callback());
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

#pragma mark Custom lists

- (FATraktRequest *)allCustomListsCallback:(void (^)(NSArray *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error]) {
        return nil;
    }
    
    // Load the cached versions first
    NSArray *cachedCustomLists = FATraktList.cachedCustomLists;
    
    if (cachedCustomLists.count > 0) {
        FATraktCallbackCall(callback(cachedCustomLists));
    }
    
    return [self.connection getAPI:@"user/lists.json" withParameters:@[self.connection.apiUser] withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        NSArray *data = response.jsonData;
        NSMutableArray *lists = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        NSMutableArray *listCacheKeys = [NSMutableArray arrayWithCapacity:data.count];
        
        for (NSDictionary *listData in data) {
            FATraktList *list = [[FATraktList alloc] initWithJSONDict:listData];
            
            if (list) {
                list.isCustom = YES;
                list.detailLevel = FATraktDetailLevelMinimal;
                [lists addObject:list];
                [list commitToCache];
                [listCacheKeys addObject:list.cacheKey];
            }
        }
        
        [[FATraktCache sharedInstance].misc setObject:listCacheKeys forKey:@"customListKeys"];
        
        lists = [lists sortedArrayUsingKey:@"name" ascending:YES];
        FATraktCallbackCall(callback(lists));
    } onError:error];
}

- (FATraktRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (![self.connection usernameSetOrDieAndError:error] || !list.slug) {
        return nil;
    }
    
    // Load the cached list first
    FATraktList *cachedList = [FATraktList.backingCache objectForKey:list.cacheKey];
    
    if (cachedList) {
        FATraktCallbackCall(callback(cachedList));
    }
    
    return [self.connection getAPI:@"user/list.json" withParameters:@[self.connection.apiUser, list.slug] withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        NSDictionary *data = response.jsonData;
        FATraktList *list = [[FATraktList alloc] initWithJSONDict:data];
        
        if (list) {
            list.isCustom = YES;
            list.detailLevel = FATraktDetailLevelDefault;
            [list commitToCache];
        }
        
        FATraktCallbackCall(callback(list));
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
        FATraktCallbackCall(callback());
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

- (FATraktRequest *)addNewCustomListWithName:(NSString *)name description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    NSString *privacyString = nil;
    
    if (privacy == FATraktListPrivacyPublic) {
        privacyString = @"public";
    } else if (privacy == FATraktListPrivacyFriends) {
        privacyString = @"friends";
    } else {
        // Default to private. It's safer if anything should happen with this argument
        privacyString = @"private";
    }
    
    NSMutableDictionary *postData = [@{@"name": name, @"privacy": privacyString, @"show_numbers": [NSNumber numberWithBool:ranked], @"allow_shouts": [NSNumber numberWithBool:allowShouts]} mutableCopy];

    if (description) {
        [postData setObject:description forKey:@"description"];
    }
    
    return [self.connection postAPI:@"lists/add" payload:postData authenticated:YES withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        
        NSDictionary *responseDict = response.jsonData;
        if ([responseDict[@"status"] isEqualToString:@"success"]) {
            FATraktCallbackCall(callback());
        } else if (error) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse unkownErrorResponse];
            FATraktCallbackCall(error(response));
        }
    } onError:error];
}

- (FATraktRequest *)editCustomList:(FATraktList *)list newName:(NSString *)name description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *))error
{
    return [self editCustomListWithSlug:list.slug newName:name description:description privacy:privacy ranked:ranked allowShouts:allowShouts callback:callback onError:error];
}

- (FATraktRequest *)editCustomListWithSlug:(NSString *)slug newName:(NSString *)name description:(NSString *)description privacy:(FATraktListPrivacy)privacy ranked:(BOOL)ranked allowShouts:(BOOL)allowShouts callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *))error
{
    NSString *privacyString = nil;
    
    if (privacy == FATraktListPrivacyPublic) {
        privacyString = @"public";
    } else if (privacy == FATraktListPrivacyFriends) {
        privacyString = @"friends";
    } else {
        // Default to private. It's safer if anything should happen with this argument
        privacyString = @"private";
    }
    
    NSMutableDictionary *postData = [@{@"slug": slug, @"name": name, @"privacy": privacyString, @"show_numbers": [NSNumber numberWithBool:ranked], @"allow_shouts": [NSNumber numberWithBool:allowShouts]} mutableCopy];
    
    if (description) {
        [postData setObject:description forKey:@"description"];
    }
    
    return [self.connection postAPI:@"lists/update" payload:postData authenticated:YES withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
        
        NSDictionary *responseDict = response.jsonData;
        if ([responseDict[@"status"] isEqualToString:@"success"]) {
            FATraktCallbackCall(callback());
        } else if (error) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse unkownErrorResponse];
            FATraktCallbackCall(error(response));
        }
    } onError:error];
}

- (FATraktRequest *)removeCustomList:(FATraktList *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    return [self removeCustomListWithSlug:list.slug callback:callback onError:error];
}

- (FATraktRequest *)removeCustomListWithSlug:(NSString *)list callback:(void (^)(void))callback onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (list) {
        NSDictionary *payload = @{@"slug": list};
        
        return [self.connection postAPI:@"lists/delete" payload:payload authenticated:YES withActivityName:FATraktActivityNotificationLists onSuccess:^(FATraktConnectionResponse *response) {
            
            NSDictionary *responseDict = response.jsonData;
            if ([responseDict[@"status"] isEqualToString:@"success"]) {
                FATraktCallbackCall(callback());
            } else if (error) {
                FATraktConnectionResponse *response = [FATraktConnectionResponse unkownErrorResponse];
                FATraktCallbackCall(error(response));
            }
        } onError:error];
    }
    
    return nil;
}

@end
