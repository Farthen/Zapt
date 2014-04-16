//
//  FATraktConnection.h
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "FATraktRequest.h"
@class FATraktConnectionResponse;

extern NSString *const FATraktUsernameAndPasswordValidityChangedNotification;

@interface FATraktConnection : NSObject

+ (instancetype)sharedInstance;

// Main POST method for JSON Data
- (void)            postURL:(NSString *)urlString
                    payload:(NSDictionary *)payload
                withRequest:(FATraktRequest *)request
                  onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (void)            postAPI:(NSString *)api
             withParameters:(NSArray *)parameters
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
                withRequest:(FATraktRequest *)request
                  onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (void)            postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
                withRequest:(FATraktRequest *)request
                  onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (FATraktRequest *)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                    onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

// Main GET method for JSON Data
- (void)            getURL:(NSString *)urlString
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

// GET Method for image data
- (void)            getImageURL:(NSString *)urlString
                    withRequest:(FATraktRequest *)request
                      onSuccess:(void (^)(FATraktConnectionResponse *))successCallback
                        onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (void)            getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (void)            getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (FATraktRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (void)            getAPI:(NSString *)api
               withRequest:(FATraktRequest *)request
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (FATraktRequest *)getAPI:(NSString *)api
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(FATraktConnectionResponse *response))successCallback
                   onError:(void (^)(FATraktConnectionResponse *connectionError))errorCallback;

- (NSString *)urlForAPI:(NSString *)api withParameters:(NSArray *)parameters;

@property BOOL useHTTPS;

+ (NSString *)passwordHashForPassword:(NSString *)password;
- (void)loadUsernameAndPassword;
- (BOOL)usernameAndPasswordSaved;
@property BOOL usernameAndPasswordValid;
- (BOOL)usernameSetOrDieAndError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;
@property (readonly) NSString *apiUser;
@property (readonly) NSString *apiPasswordHash;

@end
