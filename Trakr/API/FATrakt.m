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

NSString *const kFADefaultsKeyTraktUsername = @"TraktUsername";
NSString *const kFADefaultsKeyTraktPasswordHash = @"TraktPasswordHash";

@implementation FATrakt

@synthesize apiUser = apiUser;
@synthesize apiPasswordHash = apiPasswordHash;

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
        traktBaseURL = @"http://api.trakt.tv";
        apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        apiUser = [defaults stringForKey:kFADefaultsKeyTraktUsername];
        if (!apiUser) apiUser = @"";
        apiPasswordHash = [defaults stringForKey:kFADefaultsKeyTraktPasswordHash];
        if (!apiPasswordHash) apiPasswordHash = @"";
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

- (id)initWithUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    self = [FATrakt sharedInstance];
    if (self) {
        [self setUsername:username andPasswordHash:passwordHash];
    }
    return self;
}

- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (username) apiUser = username;
    [defaults setValue:username forKey:kFADefaultsKeyTraktUsername];
    if (passwordHash) apiPasswordHash = passwordHash;
    [defaults setValue:passwordHash forKey:kFADefaultsKeyTraktPasswordHash];
    [defaults synchronize];
}

#pragma mark API

- (NSString *)urlForAPI:(NSString *)api
{
    return [NSString stringWithFormat:@"%@/%@/%@", traktBaseURL, api, apiKey];
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
    NSDictionary *data = @{ @"username" : apiUser, @"password" : apiPasswordHash };
    [[LRResty client] post:[self urlForAPI:@"account/test"] payload:data withBlock:^(LRRestyResponse *response) {
        NSLog(@"%@", [response asString]);
        NSDictionary *data = [[response asString] objectFromJSONString];
        NSString *statusResponse = [data objectForKey:@"status"];
        if ([statusResponse isEqualToString:@"success"]) {
            block(YES);
        } else {
            block(NO);
        }
        NSLog(@"finishing…");
    }];
}

- (void)searchMovies:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for movies!");
    NSString *url = [self urlForAPI:@"search/movies.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        NSLog(@"%@", [response asString]);
        NSArray *data = [[response asString] objectFromJSONString];
        block(data);
    }];
}

- (void)searchShows:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for shows!");
    NSString *url = [self urlForAPI:@"search/shows.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        NSLog(@"%@", [response asString]);
        NSArray *data = [[response asString] objectFromJSONString];
        block(data);
    }];
}

- (void)searchEpisodes:(NSString *)query callback:(void (^)(NSArray* result))block
{
    NSLog(@"Searching for episodes!");
    NSString *url = [self urlForAPI:@"search/episodes.json" withParameters:[query URLEncodedString]];
    [[LRResty client] get:url withBlock:^(LRRestyResponse *response) {
        NSLog(@"%@", [response asString]);
        NSArray *data = [[response asString] objectFromJSONString];
        block(data);
    }];
}

@end