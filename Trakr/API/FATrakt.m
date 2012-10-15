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
#import "NSDictionary+FAJSONRequest.h"
#import "NSString+URLEncode.h"
#import "FAAppDelegate.h"

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

NSString *const kFADefaultsKeyTraktUsername = @"TraktUsername";
NSString *const kFADefaultsKeyTraktPasswordHash = @"TraktPasswordHash";

@implementation FATrakt

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _traktBaseURL = @"http://api.trakt.tv";
        _apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        _apiUser = [defaults stringForKey:kFADefaultsKeyTraktUsername];
        if (!_apiUser) _apiUser = @"";
        _apiPasswordHash = [defaults stringForKey:kFADefaultsKeyTraktPasswordHash];
        if (!_apiPasswordHash) _apiPasswordHash = @"";
        
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
    if (![_apiUser isEqualToString:@""] && ![_apiPasswordHash isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (username) _apiUser = username;
    [defaults setValue:username forKey:kFADefaultsKeyTraktUsername];
    if (passwordHash) _apiPasswordHash = passwordHash;
    [defaults setValue:passwordHash forKey:kFADefaultsKeyTraktPasswordHash];
    [defaults synchronize];
}

#pragma mark - Error Handling

- (BOOL)handleResponse:(LRRestyResponse *)response
{
    UIApplication *application = [UIApplication sharedApplication];
    FAAppDelegate *delegate = application.delegate;
    if (response.status == 200) {
        return YES;
    } else if (response.status == 401) {
        // TODO: Trakt API Error Handling
        NSLog(@"Invalid username/password");
        [delegate handleInvalidCredentials];
        return NO;
    } else if (response.status == 0) {
        NSLog(@"Network Connection Problems!");
        [delegate handleNetworkNotAvailable];
        return NO;
    } else {
        NSLog(@"HTTP status code %i recieved", response.status);
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

- (void)verifyCredentials:(void (^)(BOOL valid))block
{
    NSLog(@"Account test!");
    NSDictionary *data = @{ @"username" : _apiUser, @"password" : _apiPasswordHash };
    [[LRResty client] post:[self urlForAPI:@"account/test"] payload:data withBlock:^(LRRestyResponse *response) {
        if (![self handleResponse:response]) {
            block(NO);
        } else {
            NSLog(@"%@", [response asString]);
            NSDictionary *data = [[response asString] objectFromJSONString];
            NSString *statusResponse = [data objectForKey:@"status"];
            if ([statusResponse isEqualToString:@"success"]) {
                block(YES);
            } else {
                block(NO);
            }
            NSLog(@"finishing…");
        }
    }];
}

- (void)searchMovies:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for movies!");
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

- (void)movieDetailsForMovie:(FATraktMovie *)movie callback:(void (^)(NSArray *result))block
{
    NSLog(@"Getting all information about movie with title: \"%@\"", movie.title);
    NSString *url = [self urlForAPI:@"movie/summary.json" withParameters:movie.imdb_id];
}

- (void)searchShows:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for shows!");
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

- (void)searchEpisodes:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for episodes!");
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

@end