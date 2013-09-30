//
//  FATraktConnectionError.m
//  Zapr
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktConnectionResponse.h"

@interface FATraktConnectionResponse ()
@property LRRestyResponse *response;
@end

@implementation FATraktConnectionResponse

- (instancetype)initWithResponseType:(FATraktConnectionResponseType)responseType
{
    self = [super init];
    if (self) {
        self.responseType = responseType;
    }
    return  self;
}

+ (instancetype)connectionResponseWithResponse:(LRRestyResponse *)response
{
    FATraktConnectionResponse *connectionResponse = [[FATraktConnectionResponse alloc] init];
    if (connectionResponse) {
        connectionResponse.response = response;
        connectionResponse.responseType = FATraktConnectionResponseTypeUnknown;
        
        if (response.status == 200) {
            connectionResponse.responseType = FATraktConnectionResponseTypeSuccess;
        } else if (response.status == 401) {
            connectionResponse.responseType = FATraktConnectionResponseTypeInvalidCredentials;
        } else if (response.status == 0) {
            if (response.originalRequest.connectionError) {
                connectionResponse.responseType = FATraktConnectionResponseTypeNetworkUnavailable;
            } else {
                // The request was canceled on purpose
                connectionResponse.responseType = FATraktConnectionResponseTypeCancelled;
            }
        } else if(response.status == 503) {
            connectionResponse.responseType = FATraktConnectionResponseTypeServiceUnavailable;
        } else if(response.responseData.length == 0) {
            connectionResponse.responseType = FATraktConnectionResponseTypeNoData;
        }
    }
    return connectionResponse;
}

+ (instancetype)invalidRequestResponse
{
    static dispatch_once_t once;
    static FATraktConnectionResponse *instance;
    dispatch_once(&once, ^ {
        instance = [[FATraktConnectionResponse alloc] initWithResponseType:FATraktConnectionResponseTypeInvalidRequest];
    });
    return instance;
}

+ (instancetype)invalidCredentialsResponse
{
    static dispatch_once_t once;
    static FATraktConnectionResponse *instance;
    dispatch_once(&once, ^ {
        instance = [[FATraktConnectionResponse alloc] initWithResponseType:FATraktConnectionResponseTypeInvalidCredentials];
    });
    return instance;
}

@end
