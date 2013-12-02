//
//  FATraktConnectionError.m
//  Zapr
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktConnectionResponse.h"

@interface FATraktConnectionResponse ()
@property NSHTTPURLResponse *response;
@property UIImage *imageData;
@property id jsonData;
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

+ (instancetype)connectionResponseWithHTTPResponse:(NSHTTPURLResponse *)response
{
    return [self connectionResponseWithHTTPResponse:response responseData:nil];
}

+ (instancetype)connectionResponseWithHTTPResponse:(NSHTTPURLResponse *)response responseData:(id)responseData
{
    FATraktConnectionResponse *connectionResponse = [[FATraktConnectionResponse alloc] init];
    if (connectionResponse) {
        connectionResponse.response = response;
        connectionResponse.responseType = FATraktConnectionResponseTypeUnknown;
        
        if (!responseData) {
            connectionResponse.responseType = FATraktConnectionResponseTypeNoData;
        }
        
        if (response.statusCode == 200) {
            connectionResponse.responseType = FATraktConnectionResponseTypeSuccess;
        } else if (response.statusCode == 401) {
            connectionResponse.responseType = FATraktConnectionResponseTypeInvalidCredentials;
        } else if (response.statusCode == 0) {
            // TODO: find out what happens when request is cancelled on purpose
            // TODO: find out what happens when network is not available
        } else if(response.statusCode == 503) {
            connectionResponse.responseType = FATraktConnectionResponseTypeServiceUnavailable;
        }
    }
    
    connectionResponse.responseData = responseData;
    
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

+ (instancetype)invalidDataResponse
{
    static dispatch_once_t once;
    static FATraktConnectionResponse *instance;
    dispatch_once(&once, ^ {
        instance = [[FATraktConnectionResponse alloc] initWithResponseType:FATraktConnectionResponseTypeInvalidData];
    });
    return instance;
}

- (void)setResponseData:(id)data
{
    if ([data isKindOfClass:[UIImage class]]) {
        self.imageData = data;
    } else if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
        self.jsonData = data;
    } else if (data) {
        NSLog(@"Invalid response data type!");
    }
}

@end
