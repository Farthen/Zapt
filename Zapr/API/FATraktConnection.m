//
//  FATraktConnection.m
//  Zapr
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktConnection.h"
#import "FAActivityDispatch.h"
#import "FAAppDelegate.h"
#import "FATraktConnectionResponse.h"
#import "SFHFKeychainUtils.h"
#import <JSONKit/JSONKit.h>

#import <CommonCrypto/CommonDigest.h>

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_CONTROLLER

NSString *const FATraktConnectionKeychainKeyCredentials = @"TraktCredentials";
NSString *const FATraktConnectionDefaultsKeyTraktUsername = @"TraktUsername";

@interface FATraktConnection ()
@property NSString *apiKey;
@property NSString *apiUser;
@property NSString *apiPasswordHash;
@property NSString *traktBaseURL;
@end

@implementation FATraktConnection

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static FATraktConnection *instance;
    dispatch_once(&once, ^ { instance = [[FATraktConnection alloc] init]; });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        [self loadUsernameAndPassword];
        [[LRResty client] setGlobalTimeout:60 handleWithBlock:^(LRRestyRequest *request) {
            [(FAAppDelegate *)[[UIApplication sharedApplication] delegate] handleTimeout];
        }];
        self.traktBaseURL = @"http://api.trakt.tv";
    }
    return self;
}

- (void)loadUsernameAndPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.apiUser = [defaults stringForKey:FATraktConnectionDefaultsKeyTraktUsername];
    if ([self.apiUser isEqualToString:@""]) {
        self.apiUser = nil;
    }
    
    self.apiPasswordHash = [SFHFKeychainUtils getPasswordForUsername:self.apiUser andServiceName:FATraktConnectionKeychainKeyCredentials error:nil];
    if ([self.apiPasswordHash isEqualToString:@""]) {
        self.apiPasswordHash = nil;
    }
    
    if (self.apiUser && self.apiPasswordHash) {
        [[LRResty client] setUsername:self.apiUser password:self.apiPasswordHash];
    }
}

- (BOOL)usernameSetOrDieAndError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    if (!self.apiUser) {
        // Needs to be authenticated
        FATraktConnectionResponse *response = [[FATraktConnectionResponse alloc] init];
        response.responseType = FATraktConnectionResponseTypeInvalidCredentials;
        if (error) {
            error(response);
        }
        return NO;
    }
    return YES;
}

- (BOOL)usernameAndPasswordSaved
{
    [self loadUsernameAndPassword];
    if (self.apiUser && self.apiPasswordHash) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([passwordHash isEqualToString:@""]) {
        passwordHash = nil;
    }
    if ([username isEqualToString:@""]) {
        username = nil;
    }
    
    self.apiUser = username;
    self.apiPasswordHash = passwordHash;
    
    if (username != nil) {
        [defaults setObject:username forKey:FATraktConnectionDefaultsKeyTraktUsername];
        if (passwordHash != nil) {
            [SFHFKeychainUtils storeUsername:username andPassword:passwordHash forServiceName:FATraktConnectionKeychainKeyCredentials updateExisting:YES error:nil];
            [[LRResty client] setUsername:username password:passwordHash];
        } else {
            // Password is unset, remove it from the database
            [SFHFKeychainUtils deleteItemForUsername:username andServiceName:FATraktConnectionKeychainKeyCredentials error:nil];
        }
    } else {
        // Username is unset, remove it from the defaults
        [defaults removeObjectForKey:FATraktConnectionDefaultsKeyTraktUsername];
    }
}

+ (NSString *)passwordHashForPassword:(NSString *)password
{
    // Convert string to utf8 data bytes
    NSData *passwordBytes = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reserve memory for the sha1 hash
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    // Create SHA1 hash
    if (CC_SHA1([passwordBytes bytes], [passwordBytes length], digest)) {
        // If successful
        // Create an output string
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        // Shift the sha1 bytes in
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];
        
        // Return the output
        return output;
    }
    
    // Return nothing and cry silently
    return nil;
}

- (NSString *)urlForAPI:(NSString *)api
{
    return [NSString stringWithFormat:@"%@/%@/%@", self.traktBaseURL, api, self.apiKey];
}

- (NSString *)urlForAPI:(NSString *)api withParameters:(NSArray *)parameters
{
    if (parameters) {
        NSMutableString *url = [self urlForAPI:api].mutableCopy;
        for (NSString *parameter in parameters) {
            [url appendFormat:@"/%@", parameter];
        }
        return url;
    } else {
        return [self urlForAPI:api];
    }
}

- (NSMutableDictionary *)postDataAuthDict
{
    NSMutableDictionary *authDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [self postDataDictAddingAuthToDict:authDict];
    return authDict;
}

- (NSDictionary *)postDataDictAddingAuthToDict:(NSDictionary *)dict
{
    if (![self usernameAndPasswordSaved]) {
        return nil;
    }
    NSDictionary *authDict = @{@"username:": _apiUser, @"password": _apiPasswordHash};
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict addEntriesFromDictionary:authDict];
    return mutableDict;
}

- (void)handleResponse:(LRRestyResponse *)response onSuccess:(LRRestyResponseBlock)success onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    FATraktConnectionResponse *connectionResponse = [FATraktConnectionResponse connectionResponseWithResponse:response];
    FAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if (connectionResponse.responseType == FATraktConnectionResponseTypeSuccess) {
        if (success) {
            success(response);
        }
    } else if (connectionResponse.responseType == FATraktConnectionResponseTypeCancelled) {
        // We cancelled this request. We don't need to do anything anymore
    } else if (connectionResponse.responseType & FATraktConnectionResponseTypeAnyError) {
        // Check if we handle errors. If we don't, let the application delegate handle it
        if (error) {
            error(connectionResponse);
        } else {
            [delegate handleConnectionErrorResponse:connectionResponse];
        }
    }
}

- (LRRestyRequest *)postURL:(NSString *)urlString
                    payload:(NSDictionary *)payload
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(LRRestyResponse *response))success
                    onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // First we start the activity
    [[FAActivityDispatch sharedInstance] startActivityNamed:activityName];
    
    // Convert the payload to an NSData object
    NSData *payloadData = [[payload JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Is the url set?
    if (![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        if (error) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse connectionResponseWithResponse:nil];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            error(response);
            return nil;
        }
    }
    
    // Then we do the HTTP POST request
    DDLogController(@"HTTP POST %@", urlString);
    LRRestyRequest *request = [[LRResty client] post:urlString payload:payloadData withBlock:^(LRRestyResponse *response) {
        // Handle the response
        [self handleResponse:response onSuccess:success onError:error];
        
        // Finish the activity
        [[FAActivityDispatch sharedInstance] finishActivityNamed:activityName];
    }];
    
    // Return the request for convenience
    return request;
}

- (LRRestyRequest *)postAPI:(NSString *)api
             withParameters:(NSArray *)parameters
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(__strong LRRestyResponseBlock)success
                    onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    
    // Set the url with the specified parameters
    NSString *urlString = [self urlForAPI:api withParameters:parameters];
    
    // If this is an authenticated call we need to add auth data
    if (authenticated) {
        if (!payload) {
            payload = [[NSMutableDictionary alloc] init];
        }
        payload = [self postDataDictAddingAuthToDict:payload];
    }
    
    return [self postURL:urlString payload:payload withActivityName:activityName onSuccess:success onError:error];
}

- (LRRestyRequest *)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(LRRestyResponse *))success
                    onError:(void (^)(FATraktConnectionResponse *))error
{
    return [self postAPI:api withParameters:nil payload:payload authenticated:authenticated withActivityName:activityName onSuccess:success onError:error];
}

- (LRRestyRequest *)getURL:(NSString *)urlString
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *response))success
                   onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // First we start the activity
    [[FAActivityDispatch sharedInstance] startActivityNamed:activityName];
    
    
    // Is the url set?
    if (![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        if (error) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse connectionResponseWithResponse:nil];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            error(response);
            return nil;
        }
    }
    
    // Do the HTTP GET request
    DDLogController(@"HTTP GET %@", urlString);
    LRRestyRequest *request = [[LRResty client] get:urlString withBlock:^(LRRestyResponse *response) {
        // Handle the response
        [self handleResponse:response onSuccess:success onError:error];
        
        // Finish the activity
        [[FAActivityDispatch sharedInstance] finishActivityNamed:activityName];
    }];
    
    // Return the request for convenience
    return request;
}

- (LRRestyRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       withActivityName:(NSString *)activityName
              onSuccess:(__strong LRRestyResponseBlock)success
                onError:(void (^)(FATraktConnectionResponse *connectionError))error
{
    // Set the url with the specified parameters
    NSString *urlString = [self urlForAPI:api withParameters:parameters];
    
    return [self getURL:urlString withActivityName:activityName onSuccess:success onError:error];
}

- (LRRestyRequest *)getAPI:(NSString *)api
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *))success
                   onError:(void (^)(FATraktConnectionResponse *))error
{
    return [self getAPI:api withParameters:nil withActivityName:activityName onSuccess:success onError:error];
}

@end
