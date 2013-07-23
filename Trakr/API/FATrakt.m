//
//  FATrakt.m
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import <JSONKit.h>
#import <LRResty.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

#import "NSString+URLEncode.h"
#import "NSString+StringByAppendingSuffixToFilename.h"
#import "NSObject+PerformBlock.h"

#import "FAAppDelegate.h"

#import "FATraktCache.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "SFHFKeychainUtils.h"
#import "FAStatusBarSpinnerController.h"
#import "FAActivityDispatch.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_WARN

NSString *const kFAKeychainKeyCredentials = @"TraktCredentials";
NSString *const kFADefaultsKeyTraktUsername = @"TraktUsername";

NSString *const FATraktRatingNone = nil;
NSString *const FATraktRatingLove = @"love";
NSString *const FATraktRatingHate = @"hate";

NSString *const FATraktActivityNotificationSearch = @"FATraktActivityNotificationSearch";
NSString *const FATraktActivityNotificationCheckAuth = @"FATraktActivityNotificationCheckAuth";
NSString *const FATraktActivityNotificationLists = @"FATraktActivityNotificationLists";
NSString *const FATraktActivityNotificationDefault = @"FATraktActivityNotificationDefault";

@implementation FATrakt {
    LRRestyClient *_restyClient;
    LRRestyClient *_authRestyClient;
    FATraktCache *_cache;
    FAActivityDispatch *_activity;
}

@synthesize apiUser = _apiUser;
@synthesize apiPasswordHash = _apiPasswordHash;

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
        _traktBaseURL = @"http://api.trakt.tv";
        _apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        _apiUser = [self storedUsername];
        if (!_apiUser) _apiUser = @"";
        _apiPasswordHash = [self storedPassword];
        if (!_apiPasswordHash) _apiPasswordHash = @"";
        
        [[LRResty client] setUsername:_apiUser password:_apiPasswordHash];
        
        _cache = [FATraktCache sharedInstance];
        
        _activity = [FAActivityDispatch sharedInstance];
        [_activity registerForAllActivity:[FAStatusBarSpinnerController sharedInstance]];
        
        /*[[LRResty client] setGlobalTimeout:15 handleWithBlock:^(LRRestyRequest *request) {
            [(FAAppDelegate *)[[UIApplication sharedApplication] delegate] handleTimeout];
        }];*/
    }
    return self;
}

- (id)initWithUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    self = [FATrakt sharedInstance];
    if (self) {
        [self setUsername:username andPasswordHash:passwordHash];
    }
    return self;
}

+ (NSString *)passwordHashForPassword:(NSString *)password
{
    NSData *passwordBytes = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1([passwordBytes bytes], [passwordBytes length], digest)) {
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];
        
        return output;
    }
    return nil;

}

- (BOOL)usernameAndPasswordSaved
{
    if (self.storedUsername && ![self.storedUsername isEqualToString:@""] &&
        self.storedPassword && ![self.storedPassword isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)storedUsername
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:kFADefaultsKeyTraktUsername];
}

- (NSString *)storedPassword
{
    NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:[self storedUsername] andServiceName:kFAKeychainKeyCredentials error:nil];
    return storedPassword;
}

- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    [SFHFKeychainUtils storeUsername:username andPassword:passwordHash forServiceName:kFAKeychainKeyCredentials updateExisting:YES error:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:username forKey:kFADefaultsKeyTraktUsername];
    _apiUser = username;
    _apiPasswordHash = passwordHash;
    [[LRResty client] setUsername:username password:passwordHash];
}

#pragma mark - Error Handling

- (BOOL)handleResponse:(LRRestyResponse *)response
{
    UIApplication *application = [UIApplication sharedApplication];
    FAAppDelegate *delegate = application.delegate;
    if (response.status == 200) {
        return YES;
    } else {
        DDLogWarn(@"Request for URL %@ failed:", response.originalRequest.URL);
        if (response.status == 401) {
            DDLogWarn(@"Invalid username/password");
            [delegate handleInvalidCredentials];
            return NO;
        } else if (response.status == 0) {
            if (response.originalRequest.connectionError) {
                DDLogWarn(@"Network Connection Problems!");
                [delegate handleNetworkNotAvailable];
                return NO;
            } else {
                // The request was canceled on purpose
                return NO;
            }
        } else if(response.status == 503) {
            DDLogWarn(@"Trakt is over capacity");
            [delegate handleOverCapacity];
            return NO;
        } else {
            DDLogWarn(@"HTTP status code %i received", response.status);
            return NO;
        }
    }
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


+ (NSString *)interfaceNameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized
{
    NSString *name;
    if (!plural) {
        if (type == FATraktContentTypeMovies) {
            name = NSLocalizedString(@"movie", nil);
        } else if (type == FATraktContentTypeShows) {
            name = NSLocalizedString(@"show", nil);
        } else if (type == FATraktContentTypeEpisodes) {
            name = NSLocalizedString(@"episode", nil);
        }
    } else {
        if (type == FATraktContentTypeMovies) {
            name = NSLocalizedString(@"movies", nil);
        } else if (type == FATraktContentTypeShows) {
            name = NSLocalizedString(@"shows", nil);
        } else if (type == FATraktContentTypeEpisodes) {
            name = NSLocalizedString(@"episodes", nil);
        }
    }
    if (capitalized) {
        name = [name capitalizedString];
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

#pragma mark - API

- (NSString *)urlForAPI:(NSString *)api
{
    return [NSString stringWithFormat:@"%@/%@/%@", _traktBaseURL, api, _apiKey];
}

- (NSString *)urlForAPI:(NSString *)api withParameters:(NSString *)parameters
{
    return [NSString stringWithFormat:@"%@/%@", [self urlForAPI:api], parameters];
}

- (NSString *)urlEncodeString:(NSString *)string
{
    NSString *encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    return encodedString;
}

- (BOOL)postDateAddAuthToDict:(NSMutableDictionary *)dict
{
    if (![self usernameAndPasswordSaved]) {
        return NO;
    }
    NSDictionary *authDict = @{@"username:": _apiUser, @"password": _apiPasswordHash};
    [dict addEntriesFromDictionary:authDict];
    return YES;
}

- (NSMutableDictionary *)postDataContentTypeDictForContent:(FATraktContent *)content
{
    NSDictionary *dict;
    if (content.contentType == FATraktContentTypeMovies) {
        FATraktMovie *movie = (FATraktMovie *)content;
        dict = @{@"movies": @[@{@"imdb_id": movie.imdb_id, @"title": content.title, @"year": movie.year}]};
    } else if (content.contentType == FATraktContentTypeShows) {
        FATraktShow *show = (FATraktShow *)content;
        dict = @{@"shows": @[@{@"tvdb_id": show.tvdb_id, @"title": content.title, @"year": show.year}]};
    } else if (content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        dict = @{@"imdb_id": episode.show.imdb_id, @"tvdb_id": episode.show.tvdb_id, @"title": content.title, @"year": episode.show.year, @"episodes": @[@{@"season": episode.season, @"episode": episode.episode}]};
    }
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [self postDateAddAuthToDict:mutableDict];
    return mutableDict;
}

- (void)verifyCredentials:(void (^)(BOOL valid))block
{
    DDLogController(@"Account test!");
    NSDictionary *data = @{ @"username" : _apiUser, @"password" : _apiPasswordHash };
    
    [_activity startActivityNamed:FATraktActivityNotificationCheckAuth];
    [[LRResty client] post:[self urlForAPI:@"account/test"] payload:data withBlock:^(LRRestyResponse *response) {
        if (![self handleResponse:response]) {
            block(NO);
        } else {
            NSDictionary *data = [[response asString] objectFromJSONString];
            NSString *statusResponse = [data objectForKey:@"status"];
            if ([statusResponse isEqualToString:@"success"]) {
                block(YES);
            } else {
                block(NO);
            }
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationCheckAuth];
    }];
}

- (LRRestyRequest *)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block onError:(void (^)(LRRestyResponse *response))error
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
        block([_cache.images objectForKey:imageURL]);
        return nil;
    }
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] get:imageURL withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            if (response.responseData.length == 0) {
                if (error) {
                    error(response);
                }
                return;
            }
            UIImage *image = [UIImage imageWithData:[response responseData]];
            
            if ([url isEqualToString:@"http://trakt.us/images/poster-small.jpg"] || [url isEqualToString:@"http://trakt.us/images/fanart-summary.jpg"]) {
                image = nil;
                if (error) {
                    error(response);
                }
                return;
                /*// Invert the colors to make it look good on black background
                UIGraphicsBeginImageContext(image.size);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
                CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
                CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();*/
            }
            
            [_cache.images setObject:image forKey:imageURL cost:response.responseData.length];
            block(image);
        } else {
            if (error) {
                error(response);
            }
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}

- (LRRestyRequest *)searchMovies:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block
{
    DDLogController(@"Searching for movies!");
    NSString *url = [self urlForAPI:@"search/movies.json" withParameters:[query URLEncodedString]];
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeMovies];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        block(cachedResult);
    }
    
    [_activity startActivityNamed:FATraktActivityNotificationSearch];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            //NSLog(@"%@", [response asString]);
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *movieDict in data) {
                FATraktMovie *movie = [[FATraktMovie alloc] initWithJSONDict:movieDict];
                [movies addObject:movie];
            }
            searchResult.results = movies;
            [searchResult commitToCache];
            block(searchResult);
        } else {
            block(nil);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationSearch];
    }];
}

- (LRRestyRequest *)detailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block
{
    DDLogController(@"Fetching all information about movie: \"%@\"", movie.description);
    if (!movie.imdb_id) {
        DDLogError(@"Trying to fetch information about movie without imdb_id");
    }
    
    FATraktMovie *cachedMovie = [_cache.movies objectForKey:movie.cacheKey];
    if (cachedMovie && cachedMovie.detailLevel >= FATraktDetailLevelDefault) {
        block([_cache.movies objectForKey:movie.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call block twice. Make sure it can handle this.
    }
    
    NSString *url = [self urlForAPI:@"movie/summary.json" withParameters:movie.imdb_id];
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [movie mapObjectsInDict:data];
            
            movie.detailLevel = FATraktDetailLevelDefault;
            [movie commitToCache];
            block(movie);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}

- (LRRestyRequest *)searchShows:(NSString *)query callback:(void (^)(FATraktSearchResult* result))block
{
    DDLogController(@"Searching for shows!");
    NSString *url = [self urlForAPI:@"search/shows.json" withParameters:[query URLEncodedString]];
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeShows];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        block(cachedResult);
    }
    
    [_activity startActivityNamed:FATraktActivityNotificationSearch];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            //NSLog(@"%@", [response asString]);
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *showDict in data) {
                FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
                [shows addObject:show];
            }
            searchResult.results = shows;
            [searchResult commitToCache];
            block(searchResult);
        } else {
            block(nil);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationSearch];
    }];
}

- (LRRestyRequest *)detailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))block
{
    return [self detailsForShow:show detailLevel:FATraktDetailLevelDefault callback:block];
}

- (LRRestyRequest *)detailsForShow:(FATraktShow *)show detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktShow *))block
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
                block(cachedShow);
                return nil;
            }
        } else {
            block(cachedShow);
        }
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call block twice. Make sure it can handle this.
        show = cachedShow;
    }
    
    NSString *url = [self urlForAPI:@"show/summary.json" withParameters:show.tvdb_id];
    if (detailLevel == FATraktDetailLevelExtended) {
        url = [url stringByAppendingString:@"/extended"];
    }
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [show mapObjectsInDict:data];
            
            if (detailLevel == FATraktDetailLevelExtended) {
                show.detailLevel = FATraktDetailLevelExtended;
            } else {
                show.detailLevel = MAX(show.detailLevel, FATraktDetailLevelDefault);
            }
            
            [show commitToCache];
            block(show);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}

- (LRRestyRequest *)loadProgressDataWithTitle:(NSString *)title callback:(void (^)(NSArray *data))block
{
    DDLogController(@"Getting progress data");
    // title can be tvdb-id or slug
    NSString *parameters = [NSString stringWithFormat:@"%@/%@", self.apiUser, title];
    NSString *url = [self urlForAPI:@"user/progress/watched.json" withParameters:parameters];
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *show in data) {
                FATraktShowProgress *progress = [[FATraktShowProgress alloc] initWithJSONDict:show];
                [shows addObject:progress];
            }
            block(shows);
            
            [_activity finishActivityNamed:FATraktActivityNotificationDefault];
        }
    }];
}

- (LRRestyRequest *)progressForShow:(FATraktShow *)show callback:(void (^)(FATraktShowProgress *progress))block
{
    DDLogController(@"Getting progress for show: %@", show.title);
    return [self loadProgressDataWithTitle:show.tvdb_id callback:^(NSArray *data){
        FATraktShowProgress *progress = data[0];
        progress.show = show;
        show.progress = progress;
        block(progress);
    }];
}

- (LRRestyRequest *)progressForAllShowsCallback:(void (^)(NSArray *result))block
{
    DDLogController(@"Getting progress for all shows");
    return [self loadProgressDataWithTitle:@"" callback:block];
}

- (LRRestyRequest *)searchEpisodes:(NSString *)query callback:(void (^)(FATraktSearchResult *result))block
{
    DDLogController(@"Searching for episodes!");
    NSString *url = [self urlForAPI:@"search/episodes.json" withParameters:[query URLEncodedString]];
    
    FATraktSearchResult *searchResult = [[FATraktSearchResult alloc] initWithQuery:query contentType:FATraktContentTypeEpisodes];
    FATraktSearchResult *cachedResult = [_cache.searches objectForKey:searchResult.cacheKey];
    
    if (cachedResult) {
        DDLogController(@"Using cached search result for key %@", cachedResult.cacheKey);
        block(cachedResult);
    }
    
    [_activity startActivityNamed:FATraktActivityNotificationSearch];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            //NSLog(@"%@", [response asString]);
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
            block(searchResult);
        } else {
            block(nil);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationSearch];
    }];
}

- (LRRestyRequest *)detailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))block
{
    DDLogController(@"Fetching all information about episode with title: \"%@\"", episode.title);
    if (!episode.show.tvdb_id) {
        DDLogController(@"Trying to fetch information about show without tvdb_id");
    }
    
    FATraktEpisode *cachedEpisode = [_cache.episodes objectForKey:episode.cacheKey];
    if (cachedEpisode && cachedEpisode.detailLevel >= FATraktDetailLevelDefault) {
        block([_cache.episodes objectForKey:episode.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call block twice. Make sure it can handle this.
    }
    
    NSString *url = [self urlForAPI:@"show/episode/summary.json" withParameters:[NSString stringWithFormat:@"%@/%@/%@", episode.show.tvdb_id, episode.season.stringValue, episode.episode.stringValue]];
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [episode mapObjectsInSummaryDict:data];
            
            episode.detailLevel = FATraktDetailLevelDefault;
            [episode commitToCache];
            block(episode);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}

- (LRRestyRequest *)loadDataForList:(FATraktList *)list callback:(void (^)(FATraktList *))block
{
    FATraktList *cachedList = [_cache.lists objectForKey:list.cacheKey];
    if (cachedList) {
        block(cachedList);
        // FIXME: check if it fixes crashbug?
        //list = cachedList;
    }
    
    NSString *url = list.url;
    FATraktContentType type = list.contentType;
    NSString *typeName = [FATrakt nameForContentType:type];
    
    [_activity startActivityNamed:FATraktActivityNotificationLists];
    return [[LRResty client] get:[url copy] withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
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
            
            [list commitToCache];
            block(list);
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationLists];
    }];
}

- (LRRestyRequest *)allCustomListsCallback:(void (^)(NSArray *))block
{
    // Load the cached versions first
    NSArray *cachedCustomLists = FATraktList.cachedCustomLists;
    if (cachedCustomLists.count > 0) {
        block(cachedCustomLists);
    }
    
    NSString *url = [self urlForAPI:@"user/lists.json" withParameters:self.apiUser];
    [_activity startActivityNamed:FATraktActivityNotificationLists];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *lists = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *listData in data) {
                FATraktList *list = [[FATraktList alloc] initWithJSONDict:listData];
                [lists addObject:list];
                [list commitToCache];
            }
            block(lists);
        }
        [_activity finishActivityNamed:FATraktActivityNotificationLists];
    }];
}

- (LRRestyRequest *)detailsForCustomList:(FATraktList *)list callback:(void (^)(FATraktList *))block;
{
    // Load the cached list first
    FATraktList *cachedList = [FATraktList.backingCache objectForKey:list.cacheKey];
    if (cachedList) {
        block(cachedList);
    }
    
    NSString *url = [self urlForAPI:@"user/list.json" withParameters:[NSString stringWithFormat:@"%@/%@", self.apiUser, list.slug]];
    [_activity startActivityNamed:FATraktActivityNotificationLists];
    return [[LRResty client] get:url withBlock:^(LRRestyResponse *response){
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            FATraktList *list = [[FATraktList alloc] initWithJSONDict:data];
            [list commitToCache];
            block(list);
        }
        [_activity finishActivityNamed:FATraktActivityNotificationLists];
    }];
}

- (LRRestyRequest *)watchlistForType:(FATraktContentType)contentType callback:(void (^)(FATraktList *))block
{
    // type can either be shows, episodes or movies
    NSString *watchlistName = [FATrakt nameForContentType:contentType withPlural:YES];
    NSString *url = [self urlForAPI:[NSString stringWithFormat:@"user/watchlist/%@.json", watchlistName] withParameters:[NSString stringWithFormat:@"%@", self.apiUser]];
    
    FATraktList *list = [[FATraktList alloc] init];
    list.isWatchlist = YES;
    list.name = @"watchlist";
    list.url = url;
    list.contentType = contentType;
    
    return [self loadDataForList:list callback:block];
}

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType detailLevel:(FATraktDetailLevel)detailLevel callback:(void (^)(FATraktList *))block
{
    // type can either be shows, episodes or movies
    NSString *libraryName = [FATrakt nameForContentType:contentType withPlural:YES];
    NSString *libraryTypeName = [FATrakt nameForLibraryType:libraryType];
    NSString *url;
    if (detailLevel == FATraktDetailLevelExtended) {
        url = [self urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:[NSString stringWithFormat:@"%@/extended", self.apiUser]];
    } else if (detailLevel == FATraktDetailLevelMinimal) {
        url = [self urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:[NSString stringWithFormat:@"%@/min", self.apiUser]];
    } else {
        url = [self urlForAPI:[NSString stringWithFormat:@"user/library/%@/%@.json", libraryName, libraryTypeName] withParameters:[NSString stringWithFormat:@"%@", self.apiUser]];
    }
    
    FATraktList *list = [[FATraktList alloc] init];
    list.isLibrary = YES;
    list.name = [NSString stringWithFormat:@"library"];
    list.url = url;
    list.contentType = contentType;
    list.libraryType = libraryType;
    
    return [self loadDataForList:list callback:block];
}

- (LRRestyRequest *)libraryForContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType callback:(void (^)(FATraktList *))block;
{
    // TODO: Check if I really need the extended information
    return [self libraryForContentType:contentType libraryType:libraryType detailLevel:FATraktDetailLevelExtended callback:block];
}

- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    return [self addToWatchlist:content add:YES callback:block onError:error];
}

- (LRRestyRequest *)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    return [self addToWatchlist:content add:NO callback:block onError:error];
}

- (LRRestyRequest *)addToWatchlist:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    NSString *watchlistName = [FATrakt watchlistNameForContentType:content.contentType];
    NSString *url;
    if (add) {
        url = [self urlForAPI:[NSString stringWithFormat:@"%@/watchlist", watchlistName]];
    } else {
        url = [self urlForAPI:[NSString stringWithFormat:@"%@/unwatchlist", watchlistName]];
    }
    
    NSDictionary *dict = [self postDataContentTypeDictForContent:content];
    
    NSData *data = [[dict JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] post:url payload:data withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            block();
        } else {
            if (error) {
                error(response);
            }
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}

- (LRRestyRequest *)addToLibrary:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    return nil;
}

- (LRRestyRequest *)addToLibrary:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    return nil;
}

- (LRRestyRequest *)rate:(FATraktContent *)content love:(NSString *)love callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    NSString *contentType = [FATrakt nameForContentType:content.contentType withPlural:YES];
    NSString *url = [self urlForAPI:[NSString stringWithFormat:@"rate/%@", contentType]];
    
    NSMutableDictionary *dict = [self postDataContentTypeDictForContent:content];
    if (love == nil) {
        [dict addEntriesFromDictionary:@{@"love": @"unrate"}];
    } else {
        [dict addEntriesFromDictionary:@{@"love": love}];
    }
    
    NSData *data = [[dict JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    [_activity startActivityNamed:FATraktActivityNotificationDefault];
    return [[LRResty client] post:url payload:data withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            block();
        } else {
            if (error) {
                error(response);
            }
        }
        
        [_activity finishActivityNamed:FATraktActivityNotificationDefault];
    }];
}


@end