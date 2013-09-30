//
//  FATraktConnection.h
//  Zapr
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LRResty/LRResty.h>
@class FATraktConnectionResponse;

extern NSString *const FATraktUsernameAndPasswordValidityChangedNotification;

@interface FATraktConnection : NSObject

+ (instancetype)sharedInstance;

// Main POST method
- (LRRestyRequest *)postURL:(NSString *)urlString
                    payload:(NSDictionary *)payload
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(LRRestyResponse *response))success
                    onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)postAPI:(NSString *)api
             withParameters:(NSArray *)parameters
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(LRRestyResponse *response))success
                    onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)postAPI:(NSString *)api
                    payload:(NSDictionary *)payload
              authenticated:(BOOL)authenticated
           withActivityName:(NSString *)activityName
                  onSuccess:(void (^)(LRRestyResponse *response))success
                    onError:(void (^)(FATraktConnectionResponse *connectionError))error;

// Main GET method
- (LRRestyRequest *)getURL:(NSString *)urlString
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *response))success
                   onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *response))success
                   onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (LRRestyRequest *)getAPI:(NSString *)api
            withParameters:(NSArray *)parameters
       forceAuthentication:(BOOL)forceAuthentication
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *))success
                   onError:(void (^)(FATraktConnectionResponse *))error;

- (LRRestyRequest *)getAPI:(NSString *)api
          withActivityName:(NSString *)activityName
                 onSuccess:(void (^)(LRRestyResponse *response))success
                   onError:(void (^)(FATraktConnectionResponse *connectionError))error;

- (NSString *)urlForAPI:(NSString *)api withParameters:(NSArray *)parameters;

+ (NSString *)passwordHashForPassword:(NSString *)password;
- (void)loadUsernameAndPassword;
- (BOOL)usernameAndPasswordSaved;
@property BOOL usernameAndPasswordValid;
- (BOOL)usernameSetOrDieAndError:(void (^)(FATraktConnectionResponse *connectionError))error;
- (void)setUsername:(NSString *)username andPasswordHash:(NSString *)passwordHash;
@property (readonly) NSString *apiUser;
@property (readonly) NSString *apiPasswordHash;

@end
