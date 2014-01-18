//
//  FATraktConnection.m
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktConnection.h"
#import "FAActivityDispatch.h"
#import "FATraktConnectionResponse.h"
#import "SFHFKeychainUtils.h"

#import "FAGlobalEventHandler.h"

#import <CommonCrypto/CommonDigest.h>

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_CONTROLLER

NSString *const FATraktConnectionKeychainKeyCredentials = @"TraktCredentials";
NSString *const FATraktConnectionDefaultsKeyTraktUsername = @"TraktUsername";
NSString *const FATraktUsernameAndPasswordValidityChangedNotification = @"FATraktUsernameAndPasswordValidityChangedNotification";

@interface FATraktConnection ()
@property NSString *apiKey;
@property NSString *apiUser;
@property NSString *apiPasswordHash;
@property NSString *traktBaseURL;

@property AFHTTPRequestOperationManager *manager;
@property AFHTTPRequestOperationManager *imageManager;
@end

@implementation FATraktConnection {
    BOOL _usernameAndPasswordValid;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static FATraktConnection *instance;
    dispatch_once(&once, ^{ instance = [[FATraktConnection alloc] init]; });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        [self loadUsernameAndPassword];
        
        if (self.usernameAndPasswordSaved) {
            self.usernameAndPasswordValid = YES;
        } else {
            self.usernameAndPasswordValid = NO;
        }
        
        if (self.useHTTPS) {
            self.traktBaseURL = @"https://api.trakt.tv";
        } else {
            self.traktBaseURL = @"http://api.trakt.tv";
        }
        
        self.manager = [AFHTTPRequestOperationManager manager];
        
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html", @"text/json", @"application/json"]];
        
        self.imageManager = [AFHTTPRequestOperationManager manager];
        self.imageManager.responseSerializer = [AFImageResponseSerializer serializer];
        self.imageManager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];
        
        //[[LRResty client] setGlobalTimeout:60 handleWithBlock:^(LRRestyRequest *request) {
        //[[FAGlobalEventHandler handler] handleTimeout];
        //}];
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
        [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.apiUser password:self.apiPasswordHash];
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

- (BOOL)usernameAndPasswordValid
{
    return self.usernameAndPasswordSaved && _usernameAndPasswordValid;
}

- (void)setUsernameAndPasswordValid:(BOOL)usernameAndPasswordValid
{
    if (_usernameAndPasswordValid != usernameAndPasswordValid) {
        _usernameAndPasswordValid = usernameAndPasswordValid;
        [[NSNotificationCenter defaultCenter] postNotificationName:FATraktUsernameAndPasswordValidityChangedNotification object:self];
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
            [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:passwordHash];
        } else {
            // Password is unset, remove it from the database
            [SFHFKeychainUtils deleteItemForUsername:username andServiceName:FATraktConnectionKeychainKeyCredentials error:nil];
            self.usernameAndPasswordValid = NO;
        }
    } else {
        // Username is unset, remove it from the defaults
        [defaults removeObjectForKey:FATraktConnectionDefaultsKeyTraktUsername];
        self.usernameAndPasswordValid = NO;
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
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        // Shift the sha1 bytes in
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
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
    
    NSDictionary *authDict = @{ @"username": _apiUser, @"password": _apiPasswordHash };
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict addEntriesFromDictionary:authDict];
    
    return mutableDict;
}

- (void)handleResponse:(id)responseData forOperation:(AFHTTPRequestOperation *)operation onSuccess:(void (^)(FATraktConnectionResponse *))successCallback onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    FATraktConnectionResponse *connectionResponse = [FATraktConnectionResponse connectionResponseWithHTTPResponse:operation.response responseData:responseData];
    
    if (connectionResponse.responseType == FATraktConnectionResponseTypeSuccess) {
        if (successCallback) {
            successCallback(connectionResponse);
        }
    } else if (connectionResponse.responseType == FATraktConnectionResponseTypeCancelled) {
        // We cancelled this request. We don't need to do anything anymore
    } else if (connectionResponse.responseType & FATraktConnectionResponseTypeAnyError) {
        // Check if we handle errors. If we don't, let the application delegate handle it
        DDLogController(@"HTTP RESPONSE Error %i", connectionResponse.response.statusCode);
        
        if (connectionResponse.responseType == FATraktConnectionResponseTypeInvalidCredentials) {
            self.usernameAndPasswordValid = NO;
        }
        
        if (errorCallback) {
            errorCallback(connectionResponse);
        } else {
            [[FAGlobalEventHandler handler] handleConnectionErrorResponse:connectionResponse];
        }
    }
}

- (void)handleError:(NSError *)error forRequestOperation:(AFHTTPRequestOperation *)operation callback:(void (^)(FATraktConnectionResponse *connectionError))callback
{
    FATraktConnectionResponse *response = [FATraktConnectionResponse connectionResponseWithHTTPResponse:operation.response];
    
    if (callback) {
        callback(response);
    }
}

- (FATraktRequest *)postURL:(NSString *)urlString
                    payload:(NSDictionary *)payload
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Is the url set?
    if (![NSURL URLWithString:urlString] || ![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        if (errorCallback) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse invalidRequestResponse];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            
            DDLogController(@"Payload was: %@", payload);
            
            errorCallback(response);
        }
        
        return nil;
    }
    
    FATraktRequest *traktRequest = [FATraktRequest requestWithActivityName:activityName];
    [traktRequest startActivity];
    
    // Then we do the HTTP POST request
    DDLogController(@"HTTP POST %@", urlString);
    
    AFHTTPRequestOperation *operation = [self.manager POST:urlString parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Finish the activity
        [traktRequest finishActivity];
        
        NSDictionary *responseDict = responseObject;
        
        // Handle the response
        [self handleResponse:responseDict forOperation:operation onSuccess:successCallback onError:errorCallback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [traktRequest finishActivity];
        
        [self handleError:error forRequestOperation:operation callback:errorCallback];
    }];
    
    traktRequest.operation = operation;
    
    // Return the request
    return traktRequest;
}

- (FATraktRequest *)postAPI:(NSString *)api
             withParameters:(NSArray *)parameters
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
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
    
    return [self postURL:urlString payload:payload withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                    onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    return [self postAPI:api withParameters:nil payload:payload authenticated:authenticated withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getURL:(NSString *)urlString
               withManager:(AFHTTPRequestOperationManager *)manager
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Is the url set?
    if (![NSURL URLWithString:urlString] || ![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        if (errorCallback) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse invalidRequestResponse];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            errorCallback(response);
        }
        
        return nil;
    }
    
    // Start the activity
    FATraktRequest *traktRequest = [FATraktRequest requestWithActivityName:activityName];
    [traktRequest startActivity];
    
    // Do the HTTP GET request
    DDLogController(@"HTTP GET %@", urlString);
    AFHTTPRequestOperation *operation = [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Finish the activity
        [traktRequest finishActivity];
        
        // Handle the response
        [self handleResponse:responseObject forOperation:operation onSuccess:successCallback onError:errorCallback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Finish the activity
        [traktRequest finishActivity];
        
        // Handle the response
        [self handleError:error forRequestOperation:operation callback:errorCallback];
    }];
    
    traktRequest.operation = operation;
    
    // Return the request
    return traktRequest;
}

- (FATraktRequest *)getImageURL:(NSString *)urlString
               withActivityName:(NSString *)activityName
                      onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                        onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    return [self getURL:urlString withManager:self.imageManager withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getURL:(NSString *)urlString
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    return [self getURL:urlString withManager:self.manager withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Set the url with the specified parameters
    NSString *urlString = [self urlForAPI:api withParameters:parameters];
    
    return [self getURL:urlString withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    if (forceAuthentication && !self.usernameAndPasswordValid) {
        if (errorCallback) {
            errorCallback([FATraktConnectionResponse invalidCredentialsResponse]);
        }
        
        return nil;
    }
    
    return [self getAPI:api withParameters:parameters withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    return [self getAPI:api withParameters:nil withActivityName:activityName onSuccess:successCallback onError:errorCallback];
}

@end
