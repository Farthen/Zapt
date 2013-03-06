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

#import "FAAppDelegate.h"

#import "FATraktCache.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktList.h"
#import "FATraktListItem.h"
#import "SFHFKeychainUtils.h"

NSString *const kFAKeychainKeyCredentials = @"TraktCredentials";
NSString *const kFADefaultsKeyTraktUsername = @"TraktUsername";

@implementation FATrakt {
    LRRestyClient *_restyClient;
    LRRestyClient *_authRestyClient;
    FATraktCache *_cache;
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
    } else if (response.status == 401) {
        [APLog error:@"Invalid username/password"];
        [delegate handleInvalidCredentials];
        return NO;
    } else if (response.status == 0) {
        [APLog error:@"Network Connection Problems!"];
        [delegate handleNetworkNotAvailable];
        return NO;
    } else if(response.status == 503) {
        [APLog error:@"Trakt is over capacity"];
        [delegate handleOverCapacity];
        return NO;
    } else {
        [APLog error:@"HTTP status code %i recieved", response.status];
        return NO;
    }
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

- (NSString *)contentTypeToName:(FAContentType)type withPlural:(BOOL)plural
{
    NSString *name;
    if (type == FAContentTypeMovies) {
        name = @"movie";
    } else if (type == FAContentTypeShows) {
        name = @"show";
    } else if (type == FAContentTypeEpisodes) {
        name = @"episode";
    }
    if (plural) {
        name = [name stringByAppendingString:@"s"];
    }
    return name;
}

- (NSString *)watchlistNameForContentType:(FAContentType)type
{
    if (type == FAContentTypeMovies) {
        return @"movie";
    } else if (type == FAContentTypeShows) {
        return @"show";
    } else if (type == FAContentTypeEpisodes) {
        return @"show/episode";
    }
    return nil;
}

- (void)verifyCredentials:(void (^)(BOOL valid))block
{
    [APLog fine:@"Account test!"];
    NSDictionary *data = @{ @"username" : _apiUser, @"password" : _apiPasswordHash };
    [[LRResty client] post:[self urlForAPI:@"account/test"] payload:data withBlock:^(LRRestyResponse *response) {
        if (![self handleResponse:response]) {
            block(NO);
        } else {
            [APLog tiny:@"%@", [response asString]];
            NSDictionary *data = [[response asString] objectFromJSONString];
            NSString *statusResponse = [data objectForKey:@"status"];
            if ([statusResponse isEqualToString:@"success"]) {
                block(YES);
            } else {
                block(NO);
            }
            [APLog fine:@"finishing…" ];
        }
    }];
}

- (void)loadImageFromURL:(NSString *)url withWidth:(NSInteger)width callback:(void (^)(UIImage *image))block
{
    NSString *suffix;
    if ([url hasPrefix:@"http://trakt.us/images/poster"]) {
        [APLog tiny:@"Loading image of type poster"];
        if (width <= 138) {
            suffix = @"-138";
        } else if (width <= 300) {
            suffix = @"-300";
        } else {
            suffix = @"";
        }
    } else if ([url hasPrefix:@"http://trakt.us/images/fanart"]) {
        [APLog tiny:@"Loading image of type fanart"];
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
    [APLog fine:@"Loading image with url \"%@\"", imageURL];
    
    if ([_cache.images objectForKey:imageURL]) {
        block([_cache.images objectForKey:imageURL]);
        return;
    }
    
    [[LRResty client] get:imageURL withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            UIImage *image = [UIImage imageWithData:[response responseData]];
            [_cache.images setObject:image forKey:imageURL];
            /*if ([url isEqualToString:@"http://trakt.us/images/poster-small.jpg"]) {
                // Invert the colors to make it look good on black background
                UIGraphicsBeginImageContext(image.size);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
                CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
                CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }*/
            block(image);
        }
    }];
}

- (void)searchMovies:(NSString *)query callback:(void (^)(NSArray* result))block
{
    [APLog fine:@"Searching for movies!"];
    NSString *url = [self urlForAPI:@"search/movies.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            //NSLog(@"%@", [response asString]);
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *movieDict in data) {
                FATraktMovie *movie = [[FATraktMovie alloc] initWithJSONDict:movieDict];
                [movies addObject:movie];
            }
            block(movies);
        } else {
            block(nil);
        }
    }];
}

- (void)movieDetailsForMovie:(FATraktMovie *)movie callback:(void (^)(FATraktMovie *))block
{
    [APLog fine:@"Fetching all information about movie: \"%@\"", movie.description];
    if (!movie.imdb_id) {
        [APLog error:@"Trying to fetch information about movie without imdb_id"];
    }
    
    FATraktMovie *cachedMovie = [_cache.movies objectForKey:movie.cacheKey];
    if (cachedMovie && cachedMovie.loadedDetailedInformation) {
        block([_cache.movies objectForKey:movie.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call block twice. Make sure it can handle this.
    }
    
    NSString *url = [self urlForAPI:@"movie/summary.json" withParameters:movie.imdb_id];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [movie mapObjectsInDict:data];
            
            movie.loadedDetailedInformation = YES;
            [_cache.movies setObject:movie forKey:movie.cacheKey];
            block(movie);
        }
    }];
}

- (void)searchShows:(NSString *)query callback:(void (^)(NSArray* result))block
{
    [APLog fine:@"Searching for shows!"];
    NSString *url = [self urlForAPI:@"search/shows.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            //NSLog(@"%@", [response asString]);
            NSArray *data = [[response asString] objectFromJSONString];
            NSMutableArray *shows = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *showDict in data) {
                FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:showDict];
                [shows addObject:show];
            }
            block(shows);
        } else {
            block(nil);
        }
    }];
}

- (void)showDetailsForShow:(FATraktShow *)show callback:(void (^)(FATraktShow *))block
{
    return [self showDetailsForShow:show extended:NO callback:block];
}

- (void)showDetailsForShow:(FATraktShow *)show extended:(BOOL)extended callback:(void (^)(FATraktShow *))block
{
    [APLog fine:@"Fetching all information about show with title: \"%@\"", show.title];
    if (!show.tvdb_id) {
        [APLog error:@"Trying to fetch information about show without tbdb_id"];
    }
    
    FATraktShow *cachedShow = [_cache.shows objectForKey:show.cacheKey];
    if (cachedShow && cachedShow.loadedDetailedInformation) {
        if (extended) {
            if (show.requestedExtendedInformation) {
                // Don't request extended information twice, this is definitely overkill
                extended = NO;
            }
        } else {
            block([_cache.shows objectForKey:show.cacheKey]);
            // Fall through and still make the request. It's not that much data and things could have changed
            // This will call block twice. Make sure it can handle this.
        }
    }
    
    NSString *url = [self urlForAPI:@"show/summary.json" withParameters:show.tvdb_id];
    if (extended) {
        url = [url stringByAppendingString:@"/extended"];
    }
    
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [show mapObjectsInDict:data];
            
            show.loadedDetailedInformation = YES;
            [_cache.shows setObject:show forKey:show.cacheKey];
            block(show);
        }
    }];
}

- (void)searchEpisodes:(NSString *)query callback:(void (^)(NSArray* result))block
{
    [APLog fine:@"Searching for episodes!"];
    NSString *url = [self urlForAPI:@"search/episodes.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
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
            block(episodes);
        } else {
            block(nil);
        }
    }];
}

- (void)showDetailsForEpisode:(FATraktEpisode *)episode callback:(void (^)(FATraktEpisode *))block
{
    [APLog fine:@"Fetching all information about episode with title: \"%@\"", episode.title];
    if (!episode.show.tvdb_id) {
        [APLog error:@"Trying to fetch information about show without tvdb_id"];
    }
    
    FATraktEpisode *cachedEpisode = [_cache.episodes objectForKey:episode.cacheKey];
    if (cachedEpisode && cachedEpisode.loadedDetailedInformation) {
        block([_cache.episodes objectForKey:episode.cacheKey]);
        // Fall through and still make the request. It's not that much data and things could have changed
        // This will call block twice. Make sure it can handle this.
    }
    
    NSString *url = [self urlForAPI:@"show/episode/summary.json" withParameters:[NSString stringWithFormat:@"%@/%@/%@", episode.show.tvdb_id, episode.season.stringValue, episode.episode.stringValue]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            [episode mapObjectsInDict:data];
            
            episode.loadedDetailedInformation = YES;
            [_cache.episodes setObject:episode forKey:episode.cacheKey];
            block(episode);
        }
    }];
}

- (void)watchlistForType:(FAContentType)type callback:(void (^)(FATraktList *))block
{
    // type can either be shows, episodes or movies
    NSString *watchlistName = [self contentTypeToName:type withPlural:YES];
    NSString *url = [self urlForAPI:[NSString stringWithFormat:@"user/watchlist/%@.json", watchlistName] withParameters:[NSString stringWithFormat:@"%@", self.apiUser]];
    [[LRResty client] get:[url copy] withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            NSDictionary *data = [[response asString] objectFromJSONString];
            FATraktList *list = [[FATraktList alloc] init];
            list.isWatchlist = YES;
            list.name = @"watchlist";
            NSString *typeName = [self contentTypeToName:type withPlural:NO];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *dictitem in data) {
                if (type == FAContentTypeEpisodes) {
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
            block(list);
        }
    }];
}

- (void)addToWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    [self addToWatchlist:content add:YES callback:block onError:error];
}

- (void)removeFromWatchlist:(FATraktContent *)content callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    [self addToWatchlist:content add:NO callback:block onError:error];
}

- (void)addToWatchlist:(FATraktContent *)content add:(BOOL)add callback:(void (^)(void))block onError:(void (^)(LRRestyResponse *response))error
{
    NSString *watchlistName = [self watchlistNameForContentType:content.contentType];
    NSString *url;
    if (add) {
        url = [self urlForAPI:[NSString stringWithFormat:@"%@/watchlist", watchlistName]];
    } else {
        url = [self urlForAPI:[NSString stringWithFormat:@"%@/unwatchlist", watchlistName]];
    }
    
    NSDictionary *dict;
    if (content.contentType == FAContentTypeMovies) {
        FATraktMovie *movie = (FATraktMovie *)content;
        dict = @{@"username": _apiUser, @"password": _apiPasswordHash, @"movies": @[@{@"imdb_id": movie.imdb_id, @"title": content.title, @"year": movie.year}]};
    } else if (content.contentType == FAContentTypeShows) {
        FATraktShow *show = (FATraktShow *)content;
        dict = @{@"username": _apiUser, @"password": _apiPasswordHash, @"shows": @[@{@"tvdb_id": show.tvdb_id, @"title": content.title, @"year": show.year}]};
    } else if (content.contentType == FAContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        dict = @{@"username": _apiUser, @"password": _apiPasswordHash, @"imdb_id": episode.show.imdb_id, @"tvdb_id": episode.show.tvdb_id, @"title": content.title, @"year": episode.show.year, @"episodes": @[@{@"season": episode.season, @"episode": episode.episode}]};
    }
    
    NSData *data = [[dict JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    [[LRResty client] post:url payload:data withBlock:^(LRRestyResponse *response) {
        if ([self handleResponse:response]) {
            block();
        } else {
            error(response);
        }
    }];
}


@end