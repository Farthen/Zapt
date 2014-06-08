//
//  FATraktConnection.m
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktConnection.h"
#import "FATraktConnectionResponse.h"

#import "FAGlobalEventHandler.h"

#import <CommonCrypto/CommonDigest.h>
#import <PDKeychainBindingsController/PDKeychainBindings.h>

NSString *const FATraktConnectionDefaultsKeyTraktUsername = @"TraktUsername";
NSString *const FATraktConnectionKeychainKeyPasswordHash = @"TraktPasswordHash";
NSString *const FATraktUsernameAndPasswordValidityChangedNotification = @"FATraktUsernameAndPasswordValidityChangedNotification";

@interface FATraktConnection ()
@property NSString *apiKey;
@property NSString *apiUser;
@property NSString *apiPasswordHash;
@property NSString *traktBaseURL;

@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) AFHTTPRequestOperationManager *imageManager;
@property (nonatomic) AFHTTPRequestOperationManager *rawManager;
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

+ (void)initialize
{
    // Initialize this. Otherwise this will be a race condition. Nobody likes race conditions.
    [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TraktAPIKey"];
        [self loadUsernameAndPassword];
        
        if (self.usernameAndPasswordSaved) {
            _usernameAndPasswordValid = YES;
        } else {
            _usernameAndPasswordValid = NO;
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
        
        self.rawManager = [AFHTTPRequestOperationManager manager];
        self.rawManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.rawManager.responseSerializer.acceptableContentTypes = nil;
        self.rawManager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];
    }
    
    return self;
}

- (BOOL)delegateCallShouldSendRequest:(FATraktRequest *)request
{
    if ([self.delegate respondsToSelector:@selector(traktConnection:shouldSendRequest:)]) {
        return [self.delegate traktConnection:self shouldSendRequest:request];
    }
    
    return YES;
}

- (void)delegateCallDidSendRequest:(FATraktRequest *)request
{
    if ([self.delegate respondsToSelector:@selector(traktConnection:didSendRequest:)]) {
        [self.delegate traktConnection:self didSendRequest:request];
    }
}

- (void)delegateCallRequest:(FATraktRequest *)request succeededWithResponse:(FATraktConnectionResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(traktConnection:request:succeededWithResponse:)]) {
        [self.delegate traktConnection:self request:request succeededWithResponse:response];
    }
}

- (void)delegateCallRequest:(FATraktRequest *)request failedWithResponse:(FATraktConnectionResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(traktConnection:request:failedWithResponse:)]) {
        [self.delegate traktConnection:self request:request failedWithResponse:response];
    }
}

- (void)delegateCallHandleInvalidCredentials
{
    if ([self.delegate respondsToSelector:@selector(traktConnectionHandleInvalidCredentials:)]) {
        [self.delegate traktConnectionHandleInvalidCredentials:self];
    }
}

- (void)delegateCallHandleUnhandledErrorResponse:(FATraktConnectionResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(traktConnection:handleUnhandledErrorResponse:)]) {
        [self.delegate traktConnection:self handleUnhandledErrorResponse:response];
    }
}

- (void)loadUsernameAndPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.apiUser = [defaults stringForKey:FATraktConnectionDefaultsKeyTraktUsername];
    
    if ([self.apiUser isEqualToString:@""]) {
        self.apiUser = nil;
    }
    
    self.apiPasswordHash = [[PDKeychainBindings sharedKeychainBindings] stringForKey:FATraktConnectionKeychainKeyPasswordHash];
    
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
            [[PDKeychainBindings sharedKeychainBindings] setString:passwordHash forKey:FATraktConnectionKeychainKeyPasswordHash];
            [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:passwordHash];
        } else {
            // Password is unset, remove it from the database
            [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:FATraktConnectionKeychainKeyPasswordHash];
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
    if (CC_SHA1([passwordBytes bytes], (int)[passwordBytes length], digest)) {
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

- (void)handleResponse:(id)responseData forRequest:(FATraktRequest *)request onSuccess:(void (^)(FATraktConnectionResponse *))successCallback onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    FATraktConnectionResponse *connectionResponse = [FATraktConnectionResponse connectionResponseWithHTTPResponse:request.operation.response responseData:responseData];
    
    if (request.requestState == FATraktRequestStateCancelled) {
        [self delegateCallRequest:request failedWithResponse:connectionResponse];
        
        return;
    }
    
    if (connectionResponse.responseType == FATraktConnectionResponseTypeSuccess) {
        [self delegateCallRequest:request succeededWithResponse:connectionResponse];
        
        if (successCallback) {
            successCallback(connectionResponse);
        }
    } else {
        DDLogController(@"HTTP RESPONSE Error %ld", (long)connectionResponse.response.statusCode);
        
        [self handleError:nil forRequest:request response:(FATraktConnectionResponse *)connectionResponse callback:errorCallback];
    }
}

- (void)handleError:(NSError *)error forRequest:(FATraktRequest *)request callback:(void (^)(FATraktConnectionResponse *connectionError))callback
{
    [self handleError:error forRequest:request response:nil callback:callback];
}

- (void)handleError:(NSError *)error forRequest:(FATraktRequest *)request response:(FATraktConnectionResponse *)response callback:(void (^)(FATraktConnectionResponse *connectionError))callback
{
    if (!response) {
        response = [FATraktConnectionResponse connectionResponseWithHTTPResponse:request.operation.response];
    }
    
    [self delegateCallRequest:request failedWithResponse:response];
    
    if (response.responseType == FATraktConnectionResponseTypeInvalidCredentials) {
        self.usernameAndPasswordValid = NO;
        
        [self delegateCallHandleInvalidCredentials];
    } else if (response.responseType & FATraktConnectionResponseTypeAnyError && !request.operation.isCancelled) {
        if (callback) {
            callback(response);
        } else {
            [self delegateCallHandleUnhandledErrorResponse:response];
        }
    }
}

- (void)postURL:(NSString *)urlString
                    payload:(NSDictionary *)payload
                withRequest:(FATraktRequest *)request
                  onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Is the url set?
    if (![NSURL URLWithString:urlString] || ![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        [request invalidate];
        
        if (errorCallback) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse invalidRequestResponse];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            
            DDLogController(@"Payload was: %@", payload);
            
            errorCallback(response);
        }
        
        return;
    }
    
    
    if ([self delegateCallShouldSendRequest:request]) {
        // Then we do the HTTP POST request
        DDLogController(@"HTTP POST %@", urlString);
        
        AFHTTPRequestOperation *operation = [self.manager POST:urlString parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *responseDict = responseObject;
            
            // Handle the response
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleResponse:responseDict forRequest:request onSuccess:successCallback onError:errorCallback];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleError:error forRequest:request callback:errorCallback];
        }];
        
        request.operation = operation;
        [self delegateCallDidSendRequest:request];
    }
    
}

- (void)postAPI:(NSString *)api
             withParameters:(NSArray *)parameters
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
                withRequest:(FATraktRequest *)request
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
    
    [self postURL:urlString payload:payload withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (void)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
                withRequest:(FATraktRequest *)request
                  onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    [self postAPI:api withParameters:nil payload:payload authenticated:authenticated withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                    onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    FATraktRequest *request = [FATraktRequest requestWithActivityName:activityName];
    [self postAPI:api payload:payload authenticated:authenticated withRequest:request onSuccess:successCallback onError:errorCallback];
    
    return request;
}

- (void)getURL:(NSString *)urlString
               withManager:(AFHTTPRequestOperationManager *)manager
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Is the url set?
    if (![NSURL URLWithString:urlString] || ![urlString hasPrefix:@"http"]) {
        // The url is not set and/or does not contain http.
        // bail out
        
        [request invalidate];
        
        if (errorCallback) {
            FATraktConnectionResponse *response = [FATraktConnectionResponse invalidRequestResponse];
            response.responseType = FATraktConnectionResponseTypeUnknown;
            errorCallback(response);
        }
        
        return;
    }
    
    if ([self delegateCallShouldSendRequest:request]) {
        // Do the HTTP GET request
        DDLogController(@"HTTP GET %@", urlString);
        AFHTTPRequestOperation *operation = [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Handle the response
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleResponse:responseObject forRequest:request onSuccess:successCallback onError:errorCallback];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Handle the response
            [self handleError:error forRequest:request callback:errorCallback];
        }];
        
        request.operation = operation;
        [self delegateCallDidSendRequest:request];
    }
}

- (void)getImageURL:(NSString *)urlString
        withRequest:(FATraktRequest *)request
          onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
            onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    [self getURL:urlString withManager:self.rawManager withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (void)getURL:(NSString *)urlString
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    [self getURL:urlString withManager:self.manager withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (void)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    // Set the url with the specified parameters
    NSString *urlString = [self urlForAPI:api withParameters:parameters];
    
    [self getURL:urlString withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    FATraktRequest *request = [FATraktRequest requestWithActivityName:activityName];
    [self getAPI:api withParameters:parameters withRequest:request onSuccess:successCallback onError:errorCallback];
    
    return request;
}

- (void)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    if (forceAuthentication && !self.usernameAndPasswordValid) {
        [request invalidate];
        
        if (errorCallback) {
            errorCallback([FATraktConnectionResponse invalidCredentialsResponse]);
        }
        
        return;
    }
    
    [self getAPI:api withParameters:parameters withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    FATraktRequest *request = [FATraktRequest requestWithActivityName:activityName];
    [self getAPI:api withParameters:parameters forceAuthentication:forceAuthentication withRequest:request onSuccess:successCallback onError:errorCallback];
    
    return request;
}

- (void)getAPI:(NSString *)api
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback
{
    [self getAPI:api withParameters:nil withRequest:request onSuccess:successCallback onError:errorCallback];
}

- (FATraktRequest *)getAPI:(NSString *)api
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                   onError:(void (^)(FATraktConnectionResponse *))errorCallback
{
    FATraktRequest *request = [FATraktRequest requestWithActivityName:activityName];
    [self getAPI:api withRequest:request onSuccess:successCallback onError:errorCallback];
    
    return request;
}

@end
